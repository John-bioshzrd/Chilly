extends Button



func _on_button_down() -> void:
	$"../AudioStreamPlayer".play()
