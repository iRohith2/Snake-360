extends Spatial

onready var worlds := [
	preload("res://World0.tscn"), 
	preload("res://World1.tscn"), 
	preload("res://World2.tscn")
]

var curr_world_idx := 0
	
func switch_world(idx: int):
	remove_child(get_node("Box"))
	while idx < 0: idx += worlds.size()
	curr_world_idx = idx % worlds.size()
	add_child(worlds[curr_world_idx].instance())
	
