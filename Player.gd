extends Spatial

export var speed := 2.0
export var max_speed := 10.0
export var steer_speed := 180.0
export var max_steer_speed := 360.0
export var extents := 5.0
export var min_gap := 0.3
export var smooth_turns := false

onready var root 			:= get_node("/root/MainGame")
onready var ui 				:= get_node("/root/MainGame/Control")
onready var ui_play 		:= get_node("/root/MainGame/UI_play")
onready var spawner 		:= root.get_node("Spawner")
onready var score 			:= ui_play.get_node("Score")
onready var score_board 	:= ui.get_node("ScoreBoard")
onready var score1 			:= score_board.get_node("Score")
onready var high_score 		:= score_board.get_node("HighScore")
onready var head 			:= $Head
onready var body_base 		:= $Body
onready var body_parts 		:= [body_base]
onready var diameter : float = $Body/CSGSphere.radius*2

var position_history := []
var prev_input = null

func _ready():
	get_node("/root/Swipe").connect("swipe", self, "my_input")

func _process(delta):
	head.translate_object_local(Vector3.UP * (speed * delta))
	
	if smooth_turns:
		if Input.is_action_pressed("ui_right"):
			head.rotate_object_local(Vector3.FORWARD,  deg2rad(steer_speed) * delta)
		elif Input.is_action_pressed("ui_left"):
			head.rotate_object_local(Vector3.FORWARD, -deg2rad(steer_speed) * delta)
	else:
		if prev_input != null:
			var t := diameter / speed
			var b : Basis = prev_input[0]
			var init_time : float = prev_input[1]
			t = (Time.get_ticks_msec() - init_time) / (1000 * t)
			head.transform = head.transform.interpolate_with(Transform(b, head.transform.origin), t)
			if t >= 1:
				prev_input = null
				head.transform.basis = b
		
	for part in body_parts: remove_child(part)
	
	var pos : Vector3 = head.transform.origin
	
	if pos.x > extents:
		rotate(transform.basis.y, 0.5*PI)
		pos.x -= 2*extents
	elif pos.x < -extents:
		rotate(transform.basis.y, -0.5*PI)
		pos.x += 2*extents
	elif pos.y > extents:
		rotate(transform.basis.x, -0.5*PI)
		pos.y -= 2*extents
	elif pos.y < -extents:
		rotate(transform.basis.x, 0.5*PI)
		pos.y += 2*extents
	
	head.transform.origin = pos

	for part in body_parts: add_child(part)
	
	pos = head.global_translation
	position_history.insert(0, pos)
	
	var i : int = 1
	
	for part in body_parts:
		var dst := 0.0
		
		while i < position_history.size() and dst < min_gap:
			dst += position_history[i].distance_to(position_history[i-1])
			i += 1
		
		pos = position_history[i] if i < position_history.size() else position_history[position_history.size()-1]
		part.global_translation = pos
		
	if i < int(0.5*position_history.size()):
		position_history.resize(i)
		
func my_input(event):
	if smooth_turns or ui.visible: return
	
	var b : Basis = head.transform.basis

	match event:
		"up":
			if b.y == Vector3.UP or b.y == Vector3.DOWN: return
			b.x = Vector3.RIGHT
			b.y = Vector3.UP
		"down":
			if b.y == Vector3.UP or b.y == Vector3.DOWN: return
			b.x = Vector3.LEFT
			b.y = Vector3.DOWN
		"right":
			if b.y == Vector3.LEFT or b.y == Vector3.RIGHT: return
			b.x = Vector3.DOWN
			b.y = Vector3.RIGHT
		"left":
			if b.y == Vector3.LEFT or b.y == Vector3.RIGHT: return
			b.x = Vector3.UP
			b.y = Vector3.LEFT
		
	if head.transform.basis != b:
		if prev_input != null:
			yield(get_tree().create_timer((diameter / speed) - 0.001 * (Time.get_ticks_msec() - prev_input[1])), "timeout")
			
		prev_input = [b, Time.get_ticks_msec()]
		
func _physics_process(delta):
	var collision : KinematicCollision = head.move_and_collide((head.global_transform.basis.y) * (speed * delta), true, true, true)
	if collision != null and collision.collider != null:
		var node := collision.collider as Spatial
		if node.name.begins_with("Food"):
			spawner.curr_num_food -= 1
			if speed < max_speed:
				speed += 0.1
			if steer_speed < max_steer_speed:
				steer_speed += 5
			spawner.spawn(get_world().direct_space_state)
			score.text = str(int(score.text)+1)
			if int(score.text) > int(high_score.text):
				high_score.text = score.text
				ui.save_hs()
			grow()
			node.get_node("CollisionShape").queue_free()
			node.get_node("CSGSphere").queue_free()
			node.get_node("Particles").emitting = true
			get_tree().create_timer(1).connect("timeout", node, "queue_free")
		elif node.name.begins_with("Body") and Time.get_ticks_msec() > 1000:
			$Head/Particles.emitting = true
			get_tree().paused = true
			ui.visible = true
			score_board.visible = true
			score1.text = score.text
			ui_play.visible = false
			

func grow():
	var dup : Spatial = body_base.duplicate()
	add_child(dup, true)
	body_parts.append(dup)

func reset():
	for i in range(1, body_parts.size()):
		body_parts[i].queue_free()
	body_parts.resize(1)
	transform = Transform.IDENTITY
	head.transform = Transform.IDENTITY.translated(Vector3(0, 0, extents))
	body_base.transform = Transform.IDENTITY.translated(Vector3(0, -min_gap, extents))
	speed = 2.0
	steer_speed = 180.0
	score.text = "0"
	prev_input = null
	spawner.reset()
	spawner.spawn(get_world().direct_space_state)
