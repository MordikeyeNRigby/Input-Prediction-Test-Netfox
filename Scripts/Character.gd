class_name Character extends CharacterBody2D
#Eyo booch, i set up a basic character controller for seahorse and shrimp that you can use as a base. 
#i included in this parent class what i thought would be universal to every single character.

@export_group("Dependencies")
#region Dependencies
@export var input: CharacterInput
@export var synchronizer: RollbackSynchronizer
#endregion

#region physics vars
#this gets modified by an Area2D script Gravity.gd on entered & exited. No need to determine when gravity should be applicable.
var gravityCache: float = 0
var gravity: float = 0
#endregion

var client: Client
var id: int

func _ready():
	await get_tree().process_frame
	
	set_multiplayer_authority(1)
	input.set_multiplayer_authority(id)
	synchronizer.set_multiplayer_authority(1)
	synchronizer.process_settings()#not sure this is necessary but hey im not touching it.
	synchronizer.process_authority()

#implement this gravity thing wherever you think is necessary in the individual character child class.
func Grav(vel: Vector2) -> Vector2:
	var r: Vector2 = vel
	if gravityCache != gravity:
		gravity = gravityCache
	r += Vector2.DOWN * gravity
	return r

#call this whenever you are done modifying the physics state in the individual character child class.
#the physics_factor thing is to let the physics engine compensate for the different tick rates. To keep the same velocity value as we actually assigned, we divide by the same physics factor after move_and_slide().
func Apply(vel: Vector2):
	velocity = vel
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

#region Static functions
#Use to create new characters.
static func Instantiate(type: int, c: Client) -> Character:
	if type < 0:
		printerr("Character type %s is fucking negative what are you doing rartard mannnnnn the fuck is wrong with you" % type)
		return
	var p: Character 
	p = _GetCharacterScene(type)
	p.client = c
	p.id = c.id
	return p

#Use locally only, this is only separated out from Instantiate for readability
static func _GetCharacterScene(type: int) -> Character:
	match type:
		0:
			return null
		1:
			return null
		_:
			return null
#endregion
