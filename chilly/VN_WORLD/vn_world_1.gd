extends "res://addons/yads/dialogue_handler.gd"

#@export var dialogue_resource: DialogueResource = preload("res://dMan/scripts/chiikawa.dialogue")
#@export var balloon_scene: PackedScene = preload("res://dMan/balloon/balloon.tscn")
#@export var target_node_path: NodePath = NodePath("")

const CHI = preload("res://VN_WORLD/characters/chiikawa.tscn")
const CHI_DATA = preload("res://VN_WORLD/characters/chiikawa.tres")

var vn_char: VNCharacter

var Story = "res://yads/story.gd"

var dialogue_scene = preload("res://example_dialogue_gui.tscn")

func _get_dialogue_scene():
	return dialogue_scene

func _get_expression_executor_instance():
	return Story

#func _ready() -> void:
	## Instantiate VNCharacter
	#vn_char = CHI.instantiate()
	#if vn_char == null:
		#push_error("Failed to instantiate VNCharacter.")
		#return
	#vn_char.data = CHI_DATA.duplicate(true)
	#add_child(vn_char)
	#vn_char.position = Vector2(400, 300)
#
	## Validate dialogue_resource
	#if dialogue_resource == null:
		#push_error("dialogue_resource is null. Assign a valid DialogueResource.")
		#return
#
	## Validate DialogueManager
	#if DialogueManager == null:
		#push_error("DialogueManager autoload missing.")
		#return
#
	## Start DM3 dialogue safely
	#DialogueManager.show_dialogue_balloon_scene(balloon_scene, dialogue_resource, "start")
#
	## Safe signal connections
	#if DialogueManager.has_signal("mutated"):
		#DialogueManager.mutated.connect(_on_dm_mutated)
	#else:
		#push_error("DialogueManager missing mutated signal.")
	#if DialogueManager.has_signal("dialogue_ended"):
		#DialogueManager.dialogue_ended.connect(_on_dm_ended)
	#else:
		#push_error("DialogueManager missing dialogue_ended signal.")
#
#func _on_dm_mutated(mutation: String) -> void:
	#match mutation:
		#"move_char":
			#var target_node := get_node_or_null(target_node_path)
			#if vn_char == null:
				#push_error("vn_char is null on move_char mutation.")
			#elif target_node == null:
				#push_error("Target node not found at path: %s" % target_node_path)
			#else:
				#await vn_char.move(target_node, 1.0)
		#"look_fright":
			#if vn_char: vn_char.attr("fright")
		#"look_fucked":
			#if vn_char: vn_char.attr("fucked")
		#"look_idle":
			#if vn_char: vn_char.attr("")
		#"say_hello":
			#if vn_char: await vn_char.say("Hello!")
		#_:
			#print("Unhandled mutation: ", mutation)
#
#func _on_dm_ended(resource) -> void:
	#if vn_char:
		#vn_char.attr("") # reset expression
	#print("Dialogue finished")
