extends RichTextLabel
## Dialogue label with typing animation and sounds

## Emitted when the entry is finished showing (necessary for typing animations)
signal entry_finished
## Emitted when the next entry should start to appear
signal next_entry_requested

## The action to press to skip typing.
@export var skip_action: String = "ui_cancel"
## The speed with which the text types out.
@export var seconds_per_step: float = 0.04
## Automatically have a brief pause when these characters are encountered.
@export var pause_at_characters: String = ".?!"
## The amount of time to pause when exposing a character present in pause_at_characters.
@export var seconds_per_pause_step: float = 0.3
## Characters for which no sound is played.
@export var skip_sound_characters: String = " ()"
## Time after which to automatically continue the dialogue.
## Set below zero to disable.
@export var auto_continue_time: float = -1.0

@onready var timer: Timer = $Timer
@onready var autocomplete_timer: Timer = $AutocompleteTimer
## Prompts player to click to continue.
@onready var prompt_texture: TextureRect = $PromptTexture
## Speech sounds
@onready var spoke_sound: AudioStreamPlayer = $Spoke
@onready var finished_sound: AudioStreamPlayer = $Finished

# Text without bbcode
var ctext: String
var current_char := 0

func play_dialogue(dialogue_entry: String) -> void:
	prompt_texture.hide()
	text = dialogue_entry
	ctext = get_parsed_text()
	visible_characters = 0
	timer.start(seconds_per_pause_step)

func is_dialogue_finished() -> bool:
	return visible_characters == ctext.length() or visible_characters == -1

func _on_timer_timeout():
	if is_dialogue_finished():
		prompt_texture.show()
		finished_sound.play()
		entry_finished.emit()
		if auto_continue_time > 0.0:
			autocomplete_timer.start(auto_continue_time)
		return
	if ctext[visible_characters] in pause_at_characters:
		timer.start(seconds_per_pause_step)
	else:
		timer.start(seconds_per_step)
	if not ctext[visible_characters] in skip_sound_characters + pause_at_characters:
		spoke_sound.play()
	visible_characters += 1

func _on_autocomplete_timer_timeout() -> void:
	check_skip_or_finish()

func _unhandled_input(_event):
	if Input.is_action_just_pressed(skip_action):
		check_skip_or_finish()

func _gui_input(event):
	if event.is_action_pressed("left_mouse"):
		check_skip_or_finish()

func check_skip_or_finish():
	# There can be a moment (eg when ending on a longer pause)
	# between finishing display and _on_timer_timeout
	# where is_dialogue_finished returns true;
	# we shouldn't emit next_entry_requested before entry_finished
	# so we check the timer as well
	if is_dialogue_finished() and timer.is_stopped():
		next_entry_requested.emit()
	else:
		# We force the dialogue to show immediately
		visible_characters = -1
		timer.start(0.01)
		get_viewport().set_input_as_handled()
