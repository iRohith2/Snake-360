extends Camera

var noise = OpenSimplexNoise.new()
export var wiggle_amount: = 0.5
export var z_offset: = 8.5

onready var target = get_node("/root/Spatial/Player/Head")

func _ready():
	noise.period = 7.0
	noise.persistence = 0.8
	noise.octaves = 3

func _process(_delta):
	
	var target_xform = target.global_transform
	
	var origin = target_xform.xform(Vector3(0.0, 0.0, z_offset))
	
	var noise_offset = wiggle_amount * 3.0 * Vector3(noise.get_noise_1d(OS.get_ticks_msec() / 1000.0), 0.3 + 0.5 * noise.get_noise_1d(OS.get_ticks_msec() / 1000.0 + 1522.63), 0.0)
	
	noise_offset = target_xform.basis.xform(noise_offset)
	origin += noise_offset
	
	var new_xform = Transform.IDENTITY.translated(origin).looking_at(target_xform.xform(Vector3.ZERO), target.up_vec)
	
	self.transform = self.transform.interpolate_with(new_xform, 0.05)
	
