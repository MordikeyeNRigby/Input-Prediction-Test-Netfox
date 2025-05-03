class_name Shrimp extends Character

@export_group("Stats")
#region Character stats
@export var innerControlRad: float
@export var outerControlRad: float
@export var maxSpeed: float
#endregion


func _rollback_tick(delta: float, tick: int, is_fresh: bool):
	var dir: Vector2 = input.mousePos - global_position
	var move: Vector2 = Utils.ClampLerpVectRad(innerControlRad,outerControlRad,dir,maxSpeed)
	var newVel: Vector2 = move if gravity == 0 else velocity
	newVel = Grav(newVel)
	Apply(newVel)


func _draw():
	pass
	#Make a display on screen for the control ring radii as you vary them in the inspector. make the radii sliders too itll feel better.
