class_name CharacterInput extends BaseNetInput

@onready var character: Character = $".."
@onready var synchronizer: RollbackSynchronizer = $"../RollbackSynchronizer"

var buffer: Array[Dictionary] = [#starter packet so when the mouse state is read it doesnt result in null trying to read buffer[1]. the buffer will be updated before it is read
	{"LClick": false, "RClick": false, "Pause": false} 
]
#absolute world coordinates mouse position.
var mousePos: Vector2 = Vector2.ZERO


#add whatever the fuck other variables for input you plan to use here, and then add them to the rollback synchronizer



func _ready():
	super()
	
	#predict input on 'after_prepare_tick'
	NetworkRollback.after_prepare_tick.connect(_predict)

func _gather():
	mousePos = get_mouse_world_position()
	


#Grok gave me this dirty shiznaz (couldnt remember how to properly get world space mouse position, apparently this is how you can do it)
func get_mouse_world_position() -> Vector2:
	var screen_pos: Vector2 = get_viewport().get_mouse_position()
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos



#INPUT PREDICTION stupidly important to handling dropped frames.
func _predict(tick: int):
	if !synchronizer.is_predicting():#if ur not predicting dont predict it xD
		return#THIS IS ALWAYS RETURNING TRUE
	if !synchronizer.has_input(): #cant trust a thing without input recieved.
		mousePos = character.global_position
		return
	var current: Vector2 = mousePos - character.global_position
	var length: float = current.length()
	mousePos = current.normalized() * length * 0.95 + character.global_position#reduce how far away the character is from the mouse by 5% each predicted frame.
	print("PREDICTED FOR %S\n mousePos: %s" % [character.id,mousePos])
	
