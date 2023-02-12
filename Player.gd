extends Spatial

export var speed := 2.0
export var steerSpeed := 180.0

onready var head := $Head

func _process(delta):
	head.translate_object_local(Vector3.UP * (speed * delta))
	
	if Input.is_action_pressed("ui_right"):
		head.rotate_object_local(Vector3.FORWARD,  deg2rad(steerSpeed) * delta)
	elif Input.is_action_pressed("ui_left"):
		head.rotate_object_local(Vector3.FORWARD, -deg2rad(steerSpeed) * delta)
