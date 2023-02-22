extends Node

signal swipe

var swipe_start = null
var minimum_drag = 100

func _input(event):
	if event.is_action_pressed("click"):
		swipe_start = get_viewport().get_mouse_position()
	if event.is_action_released("click"):
		_calculate_swipe(get_viewport().get_mouse_position())
		
	if event.is_action_pressed("ui_up"):
		emit_signal("swipe", "up")
	elif event.is_action_pressed("ui_down"):
		emit_signal("swipe", "down")
	elif event.is_action_pressed("ui_right"):
		emit_signal("swipe", "right")
	elif event.is_action_pressed("ui_left"):
		emit_signal("swipe", "left")
		
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var swipe = swipe_end - swipe_start
	if abs(swipe.x) > minimum_drag:
		if swipe.x > 0:
			emit_signal("swipe", "right")
		else:
			emit_signal("swipe", "left")
	elif abs(swipe.y) > minimum_drag:
		if swipe.y < 0:
			emit_signal("swipe", "up")
		else:
			emit_signal("swipe", "down")
