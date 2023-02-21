extends Control

export var duration := 1.0
export var min_alpha := 0.0
export var max_alpha := 1.0

onready var player := get_node("/root/MainGame/Player")
onready var spawner := get_node("/root/MainGame/Spawner")
onready var ui_play := get_node("/root/MainGame/UI_play")

var first_run := true

func _ready():
	var tween := create_tween()
	tween.tween_property($TapToPlay, "modulate", Color(0, 0, 0, min_alpha), duration/2)
	tween.chain().tween_property($TapToPlay, "modulate", Color(1, 1, 1, max_alpha), duration/2)
	tween.set_loops()
	load_hs()

func _input(event):
	if visible and (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left")):
		spawner.spawn(player.get_world().direct_space_state)
		if first_run:
			first_run = false
		else:
			player.reset()
		visible = false
		ui_play.visible = true
		get_tree().paused = false
		
func load_hs():
	var file := File.new()
	if not file.file_exists("user://hs"): return
	file.open("user://hs", File.READ)
	$ScoreBoard/HighScore.text = str(file.get_32())
	file.close()

func save_hs():
	var file := File.new()
	file.open("user://hs", File.WRITE)
	file.store_32(int($ScoreBoard/HighScore.text))
	file.close()

