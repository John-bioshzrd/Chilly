extends Control

@export var dialogue_resource: DialogueResource
@export var balloon_scene: PackedScene = preload("res://dMan/balloon/balloon.tscn")

const CHI = preload("res://Resource experiment/chiikawa.tscn")
const CHI_DATA = preload("res://Resource experiment/chiikawa.tres")

var vn_char: VNCharacter

func _ready() -> void:
	# Instantiate VNCharacter
	vn_char = CHI.instantiate()
	vn_char.data = CHI_DATA.duplicate(true) # per-instance copy
	add_child(vn_char)
	vn_char.position = Vector2(400, 300)

	# CHANGED: Ensure DialogueManager singleton is available before calling
	if DialogueManager == null:
		push_error("DialogueManager singleton not found. Make sure it's added as an Autoload.")
		return

	# Start DM3 dialogue
	DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue_resource, "start")

	# Connect DM3 signals
	DialogueManager.mutated.connect(_on_dm_mutated)
	DialogueManager.dialogue_ended.connect(_on_dm_ended)

# Handle mutations
func _on_dm_mutated(mutation: String) -> void:
	match mutation:
		"move_char":
			await vn_char.move($TargetNode, 1.0) # Replace $TargetNode with your Node2D target
		"look_fright":
			vn_char.attr("fright")
		"look_fucked":
			vn_char.attr("fucked")
		"look_idle":
			vn_char.attr("") # back to default
		"say_hello":
			await vn_char.say("Hello!")
		_:
			print("Unhandled mutation: ", mutation)

# Optional: dialogue ended
func _on_dm_ended(resource) -> void:
	vn_char.attr("") # reset expression
	print("Dialogue finished")
