extends Node

var IsAttemptedServer: bool:
	get():
		var args: PackedStringArray = OS.get_cmdline_args()
		if args.has("--Server"):
			return true
		return false




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
