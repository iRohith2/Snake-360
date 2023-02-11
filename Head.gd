extends CSGBox

export var extents := 5

var up_vec := Vector3.UP
var right_vec := Vector3.RIGHT

func project(vec: Vector3) -> Vector2:
	var axis := up_vec.cross(right_vec)
	axis.x = round(axis.x)
	axis.y = round(axis.y)
	axis.z = round(axis.z)
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
			up_vec = up_vec.rotated(right_vec,  -0.5*PI)
			rotate(right_vec,  -0.5*PI)
		Vector2.DOWN:
			up_vec = up_vec.rotated(right_vec, 0.5*PI)
			rotate(right_vec, 0.5*PI)
		Vector2.RIGHT:
			right_vec = right_vec.rotated(up_vec,  0.5*PI)
			rotate(up_vec,  0.5*PI)
		Vector2.LEFT:
			right_vec = right_vec.rotated(up_vec, -0.5*PI)
			rotate(up_vec, -0.5*PI)
		_: push_error("Invalid direction : " + String(dir))

func _process(_delta):
	var pos = project(transform.origin)
	
	if pos.x > extents:
		calc_next(Vector2.RIGHT)
	elif pos.x < -extents:
		calc_next(Vector2.LEFT)
	elif pos.y > extents:
		calc_next(Vector2.UP)
	elif pos.y < -extents:
		calc_next(Vector2.DOWN)
