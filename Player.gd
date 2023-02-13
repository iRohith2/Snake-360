extends CharacterBody3D

@export var speed := 2.0
@export var steerSpeed := 180.0
@export var extents := 5.0

var up_vec := Vector3.UP
var right_vec := Vector3.RIGHT

var position_history := []
@onready var root := get_node("/root/MainGame")
@onready var body_base := root.get_node("Body1")
@onready var body_parts := [root.get_node("Body0"), body_base]

func project(vec: Vector3) -> Vector2:
	var axis := up_vec.cross(right_vec).round()
	
	match axis:
		Vector3.UP      : transform.origin.y = -extents
		Vector3.DOWN    : transform.origin.y =  extents
		Vector3.RIGHT   : transform.origin.x = -extents
		Vector3.LEFT    : transform.origin.x =  extents
		Vector3.FORWARD : transform.origin.z =  extents
		Vector3.BACK    : transform.origin.z = -extents
	
	return Vector2(right_vec.dot(vec), up_vec.dot(vec))

func calc_next(dir: Vector2):
	match dir:
		Vector2.UP:
			up_vec = up_vec.rotated(right_vec, -0.5*PI)
			rotate(right_vec, -0.5*PI)
		Vector2.DOWN:
			up_vec = up_vec.rotated(right_vec,  0.5*PI)
			rotate(right_vec,  0.5*PI)
		Vector2.RIGHT:
			right_vec = right_vec.rotated(up_vec,  0.5*PI)
			rotate(up_vec,  0.5*PI)
		Vector2.LEFT:
			right_vec = right_vec.rotated(up_vec, -0.5*PI)
			rotate(up_vec, -0.5*PI)

func grow():
	var dup : CharacterBody3D = body_base.duplicate()
	root.add_child(dup, true)
	body_parts.append(dup)

var itr := 0
func _process(delta):
	if Time.get_ticks_msec()/1000 % 5 == 0:
		if itr == 0:
			grow()
			itr += 1
	else:
		itr = 0
		
	#translate_object_local(Vector3.UP * (speed * delta))
	
	if Input.is_action_pressed("ui_right"):
		rotate_object_local(Vector3.FORWARD,  deg_to_rad(steerSpeed) * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate_object_local(Vector3.FORWARD, -deg_to_rad(steerSpeed) * delta)
		
	var pos = project(transform.origin)
	
	if pos.x > extents:
		calc_next(Vector2.RIGHT)
	elif pos.x < -extents:
		calc_next(Vector2.LEFT)
	elif pos.y > extents:
		calc_next(Vector2.UP)
	elif pos.y < -extents:
		calc_next(Vector2.DOWN)
		
	var gap : float = 40 / speed
		
	position_history.insert(0, [transform.origin, transform.basis])
	
	if int(body_parts.size()*gap) < position_history.size():
		position_history.resize(int(body_parts.size()*gap))
	
	var i : int = 1
	for part in body_parts:
		var pt = position_history[min(int(i * gap), position_history.size()-1)]
		part.transform.origin = pt[0]
		part.transform.basis = pt[1]
		i += 1

func _physics_process(delta):
	var kb = move_and_collide((transform.basis.y) * (speed * delta))
	if kb != null && kb.get_collision_count() > 0:
		var name : String = kb.get_collider().name
		print(name.substr(0, 5))
