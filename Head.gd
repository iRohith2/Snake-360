extends CSGBox

export var extents := 5.0
export var gap : int = 18

#onready var player = get_node("/root/Spatial/Player")

var up_vec := Vector3.UP
var right_vec := Vector3.RIGHT

const position_history := []
onready var player := get_node("/root/Spatial/Player")
onready var body_base := get_node("/root/Spatial/Player/Body")
onready var body_parts := [body_base, get_node("/root/Spatial/Player/Tail")]

func project(vec: Vector3) -> Vector2:
	var axis := up_vec.cross(right_vec).round()
	
	match axis:
		Vector3.UP      : transform.origin.y = -extents
		Vector3.DOWN    : transform.origin.y =  extents
		Vector3.RIGHT   : transform.origin.x = -extents
		Vector3.LEFT    : transform.origin.x =  extents
		Vector3.FORWARD : transform.origin.z =  extents
		Vector3.BACK    : transform.origin.z = -extents
		_: push_error("Invalid axis : " + String(axis))
	
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
		_: push_error("Invalid direction : " + String(dir))

func grow():
	var dup := body_base.duplicate(15)
	player.add_child(dup)
	body_parts.insert(body_parts.size()-1, dup)

var it := 0

func _process(delta):
	if it < 5:
		grow()
		it += 1
	
	var pos = project(transform.origin)
	
	if pos.x > extents:
		calc_next(Vector2.RIGHT)
	elif pos.x < -extents:
		calc_next(Vector2.LEFT)
	elif pos.y > extents:
		calc_next(Vector2.UP)
	elif pos.y < -extents:
		calc_next(Vector2.DOWN)
		
	position_history.insert(0, [transform.origin, transform.basis])
	
	if body_parts.size()*gap < position_history.size():
		position_history.resize(body_parts.size()*gap)
	
	var i : int = 1
	for part in body_parts:
		var pt = position_history[min(i * gap, position_history.size()-1)]
		part.transform.origin = pt[0]
		part.transform.basis = pt[1]
		i += 1
