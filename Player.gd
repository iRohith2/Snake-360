extends CharacterBody3D

@export var speed := 2.0
@export var max_speed := 10.0
@export var steer_speed := 180.0
@export var max_steer_speed := 360.0
@export var extents := 5.0

var up_vec := Vector3.UP
var right_vec := Vector3.RIGHT

var position_history := []
@onready var root := get_node("/root/MainGame")
@onready var apple_spawner := root.get_node("AppleSpawner")
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

func _ready():
	apple_spawner.spawn()
	apple_spawner.spawn()

func _process(delta):
	translate_object_local(Vector3.UP * (speed * delta))
	
	if Input.is_action_pressed("ui_right"):
		rotate_object_local(Vector3.FORWARD,  deg_to_rad(steer_speed) * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate_object_local(Vector3.FORWARD, -deg_to_rad(steer_speed) * delta)
		
	var pos = project(transform.origin)
	
	if pos.x > extents:
		calc_next(Vector2.RIGHT)
	elif pos.x < -extents:
		calc_next(Vector2.LEFT)
	elif pos.y > extents:
		calc_next(Vector2.UP)
	elif pos.y < -extents:
		calc_next(Vector2.DOWN)
		
	var gap : float = min(40 / speed, 20)
		
	position_history.insert(0, [transform.origin, transform.basis])
	
	if int(body_parts.size()*gap) < position_history.size():
		position_history.resize(int(body_parts.size()*gap))
	
	var i : int = 1
	for part in body_parts:
		var pt = position_history[min(int(i * gap), position_history.size()-1)]
		part.transform.origin = pt[0]
		part.transform.basis = pt[1]
		i += 1

var collision := KinematicCollision3D.new()

func _physics_process(delta):
	if Time.get_ticks_msec() < 1000:
		return
	
	if test_move(transform, (transform.basis.y) * (speed * delta), collision):
		var node := collision.get_collider() as Node
		var name : String = node.name
		if name.begins_with("Apple"):
			node.queue_free()
			apple_spawner.curr_num_apples -= 1
			if speed < max_speed:
				speed += 0.1
			if steer_speed < max_steer_speed:
				steer_speed += 5
			apple_spawner.spawn()
			grow()
