extends Camera

export var wiggle_amount := 0.5
export var z_offset := 8.5

onready var player : Spatial = get_node("/root/MainGame/Player")
onready var target : Spatial = player.get_node("Head")
onready var dir_light : Spatial = get_node("/root/MainGame/DirectionalLight")

var noise := OpenSimplexNoise.new()

func _ready():
	noise.period = 7.0
	noise.persistence = 0.8
	noise.octaves = 3

func _process(_delta):
	var target_xform := target.global_transform
	var origin := target_xform * Vector3(0.0, 0.0, z_offset)

	var noise_offset := wiggle_amount * 3.0 * Vector3(noise.get_noise_1d(Time.get_ticks_msec() / 1000.0), 0.3 + 0.5 * noise.get_noise_1d(Time.get_ticks_msec() / 1000.0 + 1522.63), 0.0)
	noise_offset = target_xform.basis * noise_offset
	origin += noise_offset
	
	var new_xform := Transform.IDENTITY.translated(origin).looking_at(target_xform*(Vector3.ZERO), player.transform.basis.y)
	transform = transform.interpolate_with(new_xform, 0.05)
	
	var b := dir_light.global_transform.basis
	b.x = player.transform.basis.x
	b.y = player.transform.basis.y
	b.z = b.x.cross(b.y)
	dir_light.global_transform.basis = b
