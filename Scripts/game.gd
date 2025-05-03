class_name Game extends Node2D

@export var spawner: MultiplayerSpawner

func _ready():
	spawner.spawn_function = SpawnCharacter

func SpawnCharacter(id: int) -> Character:
	var shrimp: Shrimp = load("res://character_body_2d.tscn").instantiate()
	shrimp.id = id
	var client: Client = Main.Networker.clients[id]
	client.character = shrimp
	shrimp.client = client
	return shrimp


func _on_networker_client_spawn(id: int) -> void:
	if !Network.isServer:
		return
	await get_tree().create_timer(3)
	spawner.spawn(id)
