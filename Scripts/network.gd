class_name Network extends Node

signal SessionStart()
signal SessionDisconnect()
signal ConnectionFailed()

signal ConnectingToServer()
signal ConnectedToServer()
signal NewPeer(id: int)
signal PeerDisconnect(id: int)

signal ClientSpawn(c: Client)

static var clients: Dictionary[int,Client] = {}
@onready var clientSpawner: MultiplayerSpawner = $ClientSpawner

#DO NOT MODIFY THIS VALUE ANYWHERE ELSE BUT IN THIS SCRIPT PLEASE THANK YOU :) this is why i like private variables from c#
var connected: bool = false

#region Usefuls
var connecting: bool:
	get():
		if !multiplayer.multiplayer_peer: return false
		return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING
#this variable is more reliable than multiplayer.is_server() in my experience. sometimes certain behavior's gonna be active before & after a game is active but is going to want to know if you are a server or not.
static var isServer: bool:
	get():
		var me: Network = Main.Networker
		if me.multiplayer.multiplayer_peer == null || me.multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
			return false
		return me.multiplayer.is_server()

#endregion


#region Initialization
func _ready():
	AssignSignals()
	if LaunchArgs.IsAttemptedServer:
		OnCreateServer()
	else:
		OnJoinServer()


func AssignSignals():
	multiplayer.connected_to_server.connect(_ConnectedToServer)
	multiplayer.server_disconnected.connect(_ServerDisconnected)
	multiplayer.connection_failed.connect(_ConnectionFailed)
	multiplayer.peer_connected.connect(_OnPeerConnected)
	multiplayer.peer_disconnected.connect(_OnPeerDisconnected)
	clientSpawner.spawn_function = SpawnClient
#endregion


#region Peer Creation
func OnCreateServer():
	var peer := WebSocketMultiplayerPeer.new()
	var err: Error = peer.create_server(3934,"127.0.0.1")
	if err:
		printerr("wtf happened cmon man")
		printerr(err)
		return
	multiplayer.multiplayer_peer = peer
	SessionStart.emit()
	NetworkTime.start()

func OnJoinServer():
	var peer := WebSocketMultiplayerPeer.new()
	var err: Error = peer.create_client("127.0.0.1:3934")
	if err:
		printerr("wtf happened cmon man")
		printerr(err)
		return
	multiplayer.multiplayer_peer = peer
#endregion

#region Multiplayer Signal functions
func _ConnectedToServer():
	ConnectedToServer.emit()
	NetworkTime.start()
	if !connected:
		connected = true
		SessionStart.emit()

func _ServerDisconnected():
	Close()

func _ConnectionFailed():
	ConnectionFailed.emit()

func _OnPeerConnected(id: int):
	NewPeer.emit(id)
	if isServer:
		clientSpawner.spawn(id)
		ClientSpawn.emit(id)
	NetworkTime.start()

func _OnPeerDisconnected(id: int):
	PeerDisconnect.emit(id)
	RemoveClient(id)
#endregion

#region Client Management
#server & client, server first. this is the official creation of a client across all peers, which 
func SpawnClient(id: int) -> Client:
	if clients.has(id): 
		printerr("Tried to create a client of id %s that already exists! wtf happened?" % id)
		return
	var c: Client = Client.Instantiate(id)#custom static function that spawns a scene of itself. 
	clients.get_or_add(id,c)
	return c

#To be ran upon _OnPeerDisconnected. 
func RemoveClient(id: int):
	if !isServer: return
	if !clients.has(id):
		print_debug("peer %s disconnected, but no client exists with that id on peer %s! wack" % [id,multiplayer.get_unique_id()])
		return 
	_removeClient.rpc(id)
	print_debug("peer %s disconnected & peer's client queued for deletion across all clients")

@rpc("authority","call_local","reliable")
func _removeClient(id: int):
	if !clients.has(id): return
	clients[id].Delete()
	clients.erase(id)
#endregion

#region Connection Management functions
#This is for the server alone.
func DisconnectPeer(id: int):
	if !isServer: return #Cant disconnect a peer if you arent the server bro
	if multiplayer.get_peers().has(id):
		multiplayer.multiplayer_peer.disconnect_peer(id)

#this function has double-call protection, since if this method is called directly on a client itll run twice via ServerDisconnected(). 
#that is the purpose of the connected boolean, to make sure we only do final disconnection handling like deletion of clients & signal emmision once.
func Close():
	if multiplayer.multiplayer_peer: 
		multiplayer.multiplayer_peer.close()
		NetworkTime.stop()
	multiplayer.multiplayer_peer = null
	if connected:
		for id: int in clients:
			var client: Client = clients[id]
			client.Delete()
		clients.clear()
		connected = false
		SessionDisconnect.emit()
#endregion
