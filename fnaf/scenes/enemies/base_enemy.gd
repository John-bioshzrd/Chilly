extends Node2D

var health = 3

func take_damage(dmg):
	health -= dmg
	if health < 0:
		die()
	else:
		print("I lived bitch")

func die():
	queue_free()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_lClick(event):
		take_damage(1)

func is_lClick(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			return true
		else:
			return false
