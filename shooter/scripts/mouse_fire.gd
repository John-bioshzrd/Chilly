class_name Mouse_Fire
extends Marker2D

var bullet = preload("res://scenes/bullet.tscn")

func fire():
	var b_inst = bullet.instantiate()
	b_inst.global_position = global_position
	b_inst.dir = (get_global_mouse_position() - global_position).normalized()
	get_tree().current_scene.add_child(b_inst)
