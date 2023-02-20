extends Node

export var extents := 5.0
export var offset := 0.5
export var max_spawns := 2
export var max_apples := 5

onready var apple : StaticBody = $Food

var rng := RandomNumberGenerator.new()
var curr_num_apples := 0

var params := PhysicsShapeQueryParameters.new()

func _ready():
	params.set_shape(apple.get_node("CollisionShape").shape)
	params.exclude = [apple.get_rid()]

func get_spawn_vec(space: PhysicsDirectSpaceState) -> Vector3:
	var axis := rng.randi_range(-3, 2)
	var x := rng.randf_range(-extents + offset, extents - offset)
	var y := rng.randf_range(-extents + offset, extents - offset)
	
	var vec := Vector3()
	
	match axis:
		0:
			vec.x = extents
			vec.y = x
			vec.z = y
		-3:
			vec.x = -extents
			vec.y = x
			vec.z = y
		1:
			vec.x = x
			vec.y = extents
			vec.z = y
		-1:
			vec.x = x
			vec.y = -extents
			vec.z = y
		2:
			vec.x = x
			vec.y = y
			vec.z = extents
		-2:
			vec.x = x
			vec.y = y
			vec.x = -extents
			
	params.transform = Transform.IDENTITY.translated(vec)
	if space.intersect_shape(params, 1).size() > 0:
		return get_spawn_vec(space)
	else:
		return vec

func spawn(space: PhysicsDirectSpaceState):
	if curr_num_apples > max_apples:
		return
	var s := rng.randi_range(1, max_spawns)
	
	for i in range(s):
		var vec := get_spawn_vec(space)
		var dup : StaticBody = apple.duplicate()
		dup.transform = Transform.IDENTITY.translated(vec)
		dup.visible = true
		add_child(dup, true)
		curr_num_apples += 1
