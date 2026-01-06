extends "res://addons/yads/gui/base_dialogue_gui.gd"

@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var character_label: RichTextLabel = %CharacterLabel

func play_dialogue(dialogue_entry: String) -> void:
	dialogue_label.text = dialogue_entry
	entry_finished.emit()
#
#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#next_entry_requested.emit()

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		next_entry_requested.emit()

func _on_character_changed(char_name: String, meta: Array):
	character_label.text = char_name
