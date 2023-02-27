extends Control

onready var swipe := get_node("/root/Swipe")

func _on_ButtonUp_pressed():
	swipe.emit_signal("swipe", "up")


func _on_ButtonDown_pressed():
	swipe.emit_signal("swipe", "down")


func _on_ButtonRight_pressed():
	swipe.emit_signal("swipe", "right")


func _on_ButtonLeft_pressed():
	swipe.emit_signal("swipe", "left")
