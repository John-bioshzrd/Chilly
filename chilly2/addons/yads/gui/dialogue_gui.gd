extends "res://addons/yads/gui/base_dialogue_gui.gd"

@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var character_label: RichTextLabel = %CharacterLabel

func _ready():
	# It is important to call the base class _ready()
	super()
	# Note: we re-emit signals from the label, which is not a good pattern,
	# however it is necessary to keep the API flexible
	# (this way the handler has no dependency on dialogue_label)
	# A somewhat cleaner alternative might be to move the label code here.
	dialogue_label.entry_finished.connect(_on_entry_finished)
	dialogue_label.next_entry_requested.connect(_on_next_entry_requested)

func _on_entry_finished():
	entry_finished.emit()

func _on_next_entry_requested():
	next_entry_requested.emit()

func play_dialogue(dialogue_entry: String):
	dialogue_label.play_dialogue(dialogue_entry)

func _on_character_changed(char_name: String, meta: Array):
	character_label.text = char_name
