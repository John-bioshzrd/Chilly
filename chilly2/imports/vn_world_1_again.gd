extends Control


# Example: trigger script on an Area2D
func _on_body_entered(body):
	var handler = get_node("Handler")
	handler.start(handler.dialogue_file)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
