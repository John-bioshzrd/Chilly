extends YadsHandler

var dialogue_scene = preload("res://addons/yads/examples/example_dialogue_gui.tscn")



func _get_dialogue_scene():
	return dialogue_scene

func _get_expression_executor_instance():
	return Story
