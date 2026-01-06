extends CanvasLayer
## Base script for YADS GUIs.
## Things starting with _ are internal,
## and the rest is a part of the API used by the handler.

## Emitted when the entry is finished showing (necessary for typing animations)
signal entry_finished
## Emitted when the next entry should start to appear
signal next_entry_requested

signal response_selected(response: String)

@onready var _response_list: VBoxContainer = %ResponsesMenu
@onready var _response_template: Button = %ResponseExample

@onready var waiting_for_response: bool = false

func _ready():
	_response_list.remove_child(_response_template)

## This method should be overriden
func play_dialogue(dialogue_entry: String):
	pass

## This method should be overriden
func _on_character_changed(char_name: String, meta: Array):
	pass

func set_responses(responses: Dictionary):
	waiting_for_response = true
	for child in _response_list.get_children():
		_response_list.remove_child(child)
	for response_id in responses:
		var response_block = responses[response_id]
		var text = response_block["text"]
		var response_button: Button = _response_template.duplicate()
		_response_list.add_child(response_button)
		response_button.text = text
		response_button.button_down.connect(_on_response_button_down)
		response_button.set_meta("response_id", response_id)

func _on_response_button_down():
	waiting_for_response = false
	for child in _response_list.get_children():
		if child.button_pressed:
			var response_id = child.get_meta("response_id", "")
			response_selected.emit(response_id)
		child.queue_free()
