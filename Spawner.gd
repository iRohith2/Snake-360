extends Node

export var extents := 5.0
export var offset := 0.5
export var max_spawns := 3
export var max_food := 5

onready var food_base := preload("res://Food.tscn")
onready var stone_base := preload("res://Stone.tscn")

var rng := RandomNumberGenerator.new()
var curr_num_food := 0

var params := PhysicsShapeQueryParameters.new()

func _ready():
	rng.seed = Time.get_ticks_usec()
	params.set_shape(food_base.instance().get_node("CollisionShape").shape)
	params.exclude = [food_base.instance().get_rid()]

func get_spawn_vec(space: PhysicsDirectSpaceState) -> Vector3:
	var axis := rng.randi_range(0, 5)
	var x := rng.randf_range(-extents + offset, extents - offset)
	var y := rng.randf_range(-extents + offset, extents - offset)
	
	var vec := Vector3()
	
	match axis:
		0:
			vec.x = extents
			vec.y = x
			vec.z = y
		1:
			vec.x = -extents
			vec.y = x
			vec.z = y
		2:
			vec.x = x
			vec.y = extents
			vec.z = y
		3:
			vec.x = x
			vec.y = -extents
			vec.z = y
		4:
			vec.x = x
			vec.y = y
			vec.z = extents
		5:
			vec.x = x
			vec.y = y
			vec.x = -extents
			
	params.transform = Transform.IDENTITY.translated(vec)
	if space.intersect_shape(params, 1).size() > 0:
		return get_spawn_vec(space)
	else:
		return vec

func spawn(space: PhysicsDirectSpaceState):
	if curr_num_food > max_food: return
	var s := rng.randi_range(2, max_spawns)
	
	for _i in range(s):
		var vec := get_spawn_vec(space)
		var dup := food_base.instance()
		dup.transform = Transform.IDENTITY.translated(vec)
		add_child(dup, true)
		curr_num_food += 1
		
	if rng.randi_range(0, 4) < 2:
		var vec := get_spawn_vec(space)
		var dup := stone_base.instance()
		dup.transform = Transform.IDENTITY.translated(vec)
		add_child(dup, true)
		yield(get_tree().create_timer(15), "timeout")
		if is_instance_valid(dup):
			dup.queue_free()
		
func reset():
	for f in get_children():
		if f != food_base: f.queue_free()
	curr_num_food = 0
