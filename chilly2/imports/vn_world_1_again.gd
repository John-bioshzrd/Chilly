extends Control

func _ready() -> void:
	print("VN Control ready")

	var handler = get_node_or_null("Handler")
	print("Handler:", handler)

	if handler == null:
		push_error("Handler not found")
		return

	print("Dialogue file:", handler.dialogue_file)
	print("Start node:", handler.start_node)

	handler.start()
	print("start() called")
