@icon("res://addons/yads/icons/handler_icon.svg")
extends Node
class_name YadsHandler

signal finished
signal character_changed(char_name: String, metadata: Array)

@export_file var dialogue_file
## The dialogue node name to start at.
@export var start_node: String
## Prints parsed node contents on node change.
@export var debug_print: bool = false
var dialogue_gui_scene = preload("res://addons/yads/examples/example_dialogue_gui.tscn")

@onready var parser = YadsParser.new()
var nodes: Dictionary = {}
var dialogue_blocks: Array = []  # from current node
var response_set: Dictionary = {} # reply hash -> reply block
var finish_flag: bool = false
var command_queue: Array = []
var dialogue_gui: Node

## Override this for customization
func _get_dialogue_scene():
	return dialogue_gui_scene

## Override this for customization
func _get_expression_executor_instance():
	return null

func _ready():
	nodes = parser.get_nodes_from_file(dialogue_file)
	# Play dialogue if node is started from the editor as a scene (press F6)
	if self == get_tree().current_scene:
		start()

func _process(_delta):
	if Input.is_action_just_pressed("debug_reload"):
		end()
		start()

func start():
	dialogue_gui = _get_dialogue_scene().instantiate()
	add_child(dialogue_gui)
	dialogue_gui.entry_finished.connect(_on_entry_finished)
	dialogue_gui.next_entry_requested.connect(_on_next_entry_requested)
	character_changed.connect(dialogue_gui._on_character_changed)
	dialogue_gui.response_selected.connect(_on_response_selected)
	
	finish_flag = false
	change_node(start_node)
	_on_next_entry_requested()

func end():
	if is_instance_valid(dialogue_gui):
		remove_child(dialogue_gui)
		dialogue_gui.queue_free()
		finished.emit()

## Inspects choices in next block to see if the wanted type can be returned.
func can_next_block_add_block_type(type):
	var next_block = dialogue_blocks[-1]
	if next_block["type"] == type:
		return true
	if next_block["type"] != parser.YADS_CHOICE:
		return false
	var conditions = next_block["conditions"]
	# If any of the blocks has the wanted type as the first block,
	# we must assume it can be returned and will have to evaluate the condition
	# In other words we can only return false if none of the choices have
	# an incompatible type at its start
	for cond in conditions:
		if cond["blocks"][0]["type"] == type:
			return true
	if next_block.has("default"):
		if next_block["default"]["blocks"][0]["type"] == type:
			return true
	return false

## Ran when full text is shown (e.g. when typing animation finishes)
func _on_entry_finished():
	# Upon finishing a regular block of text, we look ahead to spawn responses
	if dialogue_blocks.is_empty():
		# Exiting dialogue is left to the player (see _next_entry_finished)
		return
	# We lookahead to process if statements until we get all replies
	# (i.e. run into a text block) to spawn responses, if any
	#print("looking for replies")
	while not dialogue_blocks.is_empty() and can_next_block_add_block_type(parser.YADS_REPLY):
		next()
	if not response_set.is_empty():
		dialogue_gui.set_responses(response_set)

func _on_response_selected(response_id: String):
	var response = response_set[response_id]
	response_set = {}
	execute_commands(response.get("commands", []))
	_on_next_entry_requested()

## Ran when clicking the skip/continue button
func _on_next_entry_requested():
	execute_commands(command_queue)
	command_queue = []
	if finish_flag:
		# We only finish once the player interacts with the GUI (click or reply)
		# executing the finish command elsewhere results in invalid GUI calls
		end()
		return
	#if dialogue_gui.waiting_for_response:
	if not response_set.is_empty():
		# Don't proceed if the player is being shown replies to choose
		return
	if dialogue_blocks.is_empty():
		end()
		return
	# We lookahead to process if statements until we get regular text
	#print("looking for text")
	while not dialogue_blocks.is_empty() and dialogue_blocks[-1]["type"] != parser.YADS_TEXT:
		if dialogue_blocks.is_empty():
			end()
			return
		next()
	# ... and then actually display the actual text
	next()

func change_node(node_id: String):
	if not nodes.has(node_id):
		push_error("Node with ID %s not in dialogue file" % node_id)
		return
	character_changed.emit("", [])
	dialogue_blocks = parser.get_node_dialogue(nodes[node_id])
	if debug_print:
		for block in dialogue_blocks:
			print(JSON.stringify(block, '\t', false))
	# The blocks are chronologically reversed
	# and we visit them from the back of the array. This is because:
	# 1. there is no append_front() 2. pop_back is faster than pop_front
	dialogue_blocks.reverse()
	# Reset replies just in case
	response_set = {}

func next():
	if not dialogue_gui.is_inside_tree():
		# When the finish command is called before emptying dialogue_blocks,
		# we'll enter this function in _on_next_entry_requested again
		# and try to continue, possibly trying to use
		# dialogue_gui that's queued to be freed
		return
	if dialogue_blocks.is_empty():
		end()
		return
	# Take the next block off the list
	var block: Dictionary = dialogue_blocks.pop_back()
	var type: String = block["type"]
	#print(JSON.stringify(block, '\t', false))
	if type == parser.YADS_CHOICE:
		# We "refill" blocks
		var selected_blocks = evaluate_choice(block)
		# We need to reverse these too
		selected_blocks.reverse()
		dialogue_blocks.append_array(selected_blocks)
		#print(JSON.stringify(dialogue_blocks, '\t', false))
	elif type == parser.YADS_TEXT:
		if block.has("character_change"):
			character_changed.emit(block["character_change"], block.get("character_change_meta", []))
		dialogue_gui.play_dialogue(block["text"])
		# We have to let the player read the text before executing e.g. a goto command
		command_queue = block.get("commands", [])
	elif type == parser.YADS_DUMMY:
		# There's no text to read so we just execute now and proceed to next block
		execute_commands(block.get("commands", []))
	elif type == parser.YADS_REPLY:
		# Add response to set; commands are processed after choice
		response_set[str(hash(block))] = block

func execute_commands(commands: Array):
	for command in commands:
		var type = command.get("type", "")
		var expression = command.get("expression", "")
		if type == parser.YADS_GOTO:
			change_node(expression)
			return
		elif type == parser.YADS_FINISH:
			finish_flag = true
			return
		elif type == parser.YADS_COMMAND:
			run_command(expression)

func run_command(command: String):
	var exec_instance: Object = _get_expression_executor_instance()
	if not exec_instance:
		exec_instance = Yads
	var expression = Expression.new()
	var expression_str = command
	# Specific to = syntax:
	var var_name = ""
	var store_result = false
	# Support for assignment syntax - Expression does not allow this.
	# However, we convert the right side to their actual types by making it an expression
	# (that way we don't have to manually infer types from strings)
	if command.contains("?="):
		# null-coalescing assignment;
		# we only assign value if the var is not defined yet
		var split = command.split("?=")
		var_name = split[0].strip_edges()
		if var_name in exec_instance.get_variable_names():
			return
		expression_str = split[1].strip_edges()
		store_result = true
	elif command.contains("="):
		# Regular assignment
		var split = command.split("=")
		var_name = split[0].strip_edges()
		expression_str = split[1].strip_edges()
		store_result = true
	var result = -1
	expression.parse(expression_str, exec_instance.get_variable_names())
	result = expression.execute(exec_instance.get_variable_values(), exec_instance)
	if expression.has_execute_failed():
		push_error("""YADS error: expression %s
		failed to execute: %s""" % [expression_str, expression.get_error_text()])
		return
	if store_result:
		#print("assignment: '%s' '%s'" % [var_name, result])
		exec_instance.store(var_name, result)

func evaluate_choice(choice: Dictionary) -> Array:
	var exec_instance: Object = _get_expression_executor_instance()
	if not exec_instance:
		exec_instance = Yads
	if choice.get("type", "") != parser.YADS_CHOICE:
		push_error("Supplied a non-choice type to evaluate_choice(): %s" % choice)
		return []
	var conditions: Array = choice.get("conditions", [])
	for condition in conditions:
		var expression_txt = condition["condition"]["expression"]
		var expression = Expression.new()
		var result
		expression.parse(expression_txt, exec_instance.get_variable_names())
		result = expression.execute(exec_instance.get_variable_values(), exec_instance)
		if expression.has_execute_failed():
			push_error("""YADS error: expression %s
			failed to execute: %s""" % [expression_txt, expression.get_error_text()])
			return []
		#print("condition %s result: %s" % [expression_txt, result])
		if result:
			return condition.get("blocks", [])
	#print("returning default (else) blocks (can be empty)")
	return choice.get("default", {}).get("blocks", [])

func debug_print_blocks(blocks: Array):
	print("Printing blocks")
	for block in blocks:
		print(JSON.stringify(block, '\t', false))
	print("End.")
