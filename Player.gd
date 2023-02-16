extends Node3D

@export var speed := 2.0
@export var max_speed := 10.0
@export var steer_speed := 180.0
@export var max_steer_speed := 360.0
@export var extents := 5.0
@export var min_gap := 0.3
@export var smooth_turns := true

@onready var root := get_node("/root/MainGame")
@onready var apple_spawner := root.get_node("AppleSpawner")
@onready var head : CharacterBody3D = $Head
@onready var body_base : CharacterBody3D = $Body
@onready var body_parts : Array[CharacterBody3D] = [body_base]
@onready var diameter : float = $Head/CSGSphere3D.radius*2

var position_history := []
var input_history := []
var collision := KinematicCollision3D.new()

func _ready():
	apple_spawner.spawn(get_world_3d().direct_space_state)
	
var k := 0
func _process(delta):
	while k < 10:
		grow()
		k += 1
		
	head.translate_object_local(Vector3.UP * (speed * delta))
	
	if smooth_turns:
		if Input.is_action_pressed("ui_right"):
			head.rotate_object_local(Vector3.FORWARD,  deg_to_rad(steer_speed) * delta)
		elif Input.is_action_pressed("ui_left"):
			head.rotate_object_local(Vector3.FORWARD, -deg_to_rad(steer_speed) * delta)
	else:
		if not input_history.is_empty():
			var t := diameter / speed
			var b : Basis = input_history[0][0]
			var init_time : float = input_history[0][1]
			t = (Time.get_ticks_msec() - init_time) / (1000 * t)
			head.transform = head.transform.interpolate_with(Transform3D(b, head.position), t)
			if t >= 1:
				input_history.remove_at(0)
				head.basis = b
		
	for part in body_parts: remove_child(part)
		
	if head.position.x > extents:
		rotate(basis.y, 0.5*PI)
		head.position.x -= 2*extents
	elif head.position.x < -extents:
		rotate(basis.y, -0.5*PI)
		head.position.x += 2*extents
	elif head.position.y > extents:
		rotate(basis.x, -0.5*PI)
		head.position.y -= 2*extents
	elif head.position.y < -extents:
		rotate(basis.x, 0.5*PI)
		head.position.y += 2*extents

	for part in body_parts: add_child(part)

	position_history.insert(0, [head.global_transform, delta])
	
	var i : int = 0
	var t := min_gap / speed
	
	for part in body_parts:
		var st := 0.0
		
		while st < t and i < position_history.size():
			var p = position_history[i]
			st += p[1]
			i += 1
		
		if i >= position_history.size():
			part.global_transform = position_history[position_history.size()-1][0]
		else:
			part.global_transform = position_history[i][0]
		
	if i < int(0.5*position_history.size()):
		position_history.resize(i)
		
func _input(event):
	if smooth_turns: return
	
	var b := head.transform.basis

	if event.is_action_pressed("ui_up"):
		if b.y == Vector3.UP or b.y == Vector3.DOWN: return
		b.x = Vector3.RIGHT
		b.y = Vector3.UP
		input_history.append([b, Time.get_ticks_msec()])
	elif event.is_action_pressed("ui_down"):
		if b.y == Vector3.UP or b.y == Vector3.DOWN: return
		b.x = Vector3.LEFT
		b.y = Vector3.DOWN
		input_history.append([b, Time.get_ticks_msec()])
	elif event.is_action_pressed("ui_right"):
		if b.y == Vector3.LEFT or b.y == Vector3.RIGHT: return
		b.x = Vector3.DOWN
		b.y = Vector3.RIGHT
		input_history.append([b, Time.get_ticks_msec()])
	elif event.is_action_pressed("ui_left"):
		if b.y == Vector3.LEFT or b.y == Vector3.RIGHT: return
		b.x = Vector3.UP
		b.y = Vector3.LEFT
		input_history.append([b, Time.get_ticks_msec()])
		
	#head.basis = b

func _physics_process(delta):
	if head.test_move(head.global_transform, (head.global_transform.basis.y) * (speed * delta), collision):
		var node := collision.get_collider() as Node3D
		if node.name.begins_with("Apple"):
			node.queue_free()
			apple_spawner.curr_num_apples -= 1
			if speed < max_speed:
				speed += 0.1
			if steer_speed < max_steer_speed:
				steer_speed += 5
			apple_spawner.spawn(get_world_3d().direct_space_state)
			grow()
		elif node.name.begins_with("Body") and Time.get_ticks_msec() > 1000:
			process_mode = Node.PROCESS_MODE_DISABLED

func grow():
	var dup : CharacterBody3D = body_base.duplicate()
	add_child(dup, true)
	body_parts.append(dup)
