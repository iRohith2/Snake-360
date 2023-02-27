extends Spatial

onready var worlds := [
	preload("res://World0.tscn"), 
	preload("res://World1.tscn"), 
	preload("res://World2.tscn")
]

func worlds_count() -> int:
	return worlds.size()
	
func switch_world(idx: int):
	remove_child(get_node("Box"))
	while idx < 0: idx += worlds.size()
	add_child(worlds[idx % worlds.size()].instance())
	
