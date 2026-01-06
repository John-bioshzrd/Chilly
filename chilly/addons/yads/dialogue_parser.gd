extends RefCounted
class_name YadsParser

const YADS_TEXT = "YADS_TEXT"
const YADS_REPLY = "YADS_REPLY"
const YADS_COMMAND = "YADS_COMMAND"
const YADS_CHARACTER = "YADS_CHARACTER"
const YADS_GOTO = "YADS_GOTO"
const YADS_FINISH = "YADS_FINISH"
const YADS_IF = "YADS_IF"
const YADS_ELIF = "YADS_ELIF"
const YADS_ELSE = "YADS_ELSE"
const YADS_ENDIF = "YADS_ENDIF"
const YADS_DUMMY = "YADS_DUMMY" # commands with no text block
const YADS_CHOICE = "YADS_CHOICE" # if-(elif-)(else-) tree

func get_node_dialogue(node: Array) -> Array:
	var tokens = tokenize_node(node)
	var lexemes = get_lexemes(tokens)
	var blocks = get_blocks(lexemes)
	return get_tree(blocks)

func get_nodes_from_file(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Got a file access error: ", FileAccess.get_open_error())
		return {}
	var nodes: Dictionary = {}
	var node_name: String
	var multiline_comment_opened = false
	while file.get_position() < file.get_length():
		var line: String = file.get_line().strip_edges()
		# Skip comment lines
		if line.begins_with("#"):
			continue
		if line.begins_with("{#"):
			multiline_comment_opened = true
			continue
		if line.ends_with("#}"):
			multiline_comment_opened = false
			continue
		if multiline_comment_opened:
			continue
		# Begin node
		if line.begins_with("==="):
			node_name = line.replace("===", "").strip_edges()
			nodes[node_name] = []
			continue
		nodes[node_name].append(line)
	return nodes

# Internal

func tokenize_node(node_text: Array) -> Array:
	var tokens = []
	var current_token: String = ""
	for line in node_text:
		line = line.strip_edges()
		if line.begins_with("{%"):
			# Command types
			if not current_token.is_empty():
				# Commit previous token if one was started
				tokens.append(current_token)
			tokens.append(line)
			current_token = ""
		elif line.begins_with("->"):
			# Start reply
			if not current_token.is_empty():
				tokens.append(current_token)
			current_token = line
		elif line.ends_with(":"):
			# Character name
			if current_token.is_empty():
				# We only commit this if it's on a separate line
				tokens.append(line)
				current_token = ""
			else:
				# Otherwise we treat this as part of previous text block
				current_token += " " + line
		elif line.is_empty():
			# Finish continuous text on line break
			if not current_token.is_empty():
				tokens.append(current_token)
			current_token = ""
		else:
			# Line with regular text - add to text block or reply
			if current_token.is_empty():
				current_token = line
			else:
				current_token += " " + line
	# Add last token
	if not current_token.is_empty():
		tokens.append(current_token)
	return tokens

func get_code_lexeme(token: String) -> Dictionary:
	var lexeme: Dictionary = {}
	var content = token.replace("{%", "").replace("%}", "").strip_edges()
	if content.begins_with("if"):
		lexeme["type"] = YADS_IF
		lexeme["expression"] = content.replace("if", "").strip_edges()
	elif content.begins_with("elif"):
		lexeme["type"] = YADS_ELIF
		lexeme["expression"] = content.replace("elif", "").strip_edges()
	elif content.begins_with("else"):
		lexeme["type"] = YADS_ELSE
	elif content.begins_with("endif"):
		lexeme["type"] = YADS_ENDIF
	elif content.begins_with("goto"):
		lexeme["type"] = YADS_GOTO
		lexeme["expression"] = content.replace("goto", "").strip_edges()
	elif content.begins_with("finish"):
		lexeme["type"] = YADS_FINISH
	else:
		lexeme["type"] = YADS_COMMAND
		lexeme["expression"] = content
	return lexeme

func get_lexemes(tokens: Array) -> Array:
	var lexemes: Array = []
	var lexeme: Dictionary = {}
	for token in tokens:
		if token.begins_with("{%"):
			if not token.ends_with("%}"):
				push_error("Code token opened but closed improperly: ", token)
				continue
			lexemes.append(get_code_lexeme(token))
		elif token.begins_with("->"):
			token = token.replace("->", "").strip_edges()
			lexemes.append({"type": YADS_REPLY, "text": token})
		elif token.ends_with(":"):
			var regex = RegEx.new()
			regex.compile("\\((.*?)\\)")
			var result = regex.search(token)
			if result != null:
				# e.g. "CharacterName (abc, def):"
				var meta_raw = result.get_string()
				meta_raw = meta_raw.replace("(", "").replace(")", "")
				meta_raw = meta_raw.replace(" ", "")
				var meta = meta_raw.split(",", false)
				var open_bracket_pos = token.find("(")
				var char_name = token.substr(0, open_bracket_pos).strip_edges()
				var new_lexeme = {
					"type": YADS_CHARACTER,
					"text": char_name,
					"meta": meta
				}
				lexemes.append(new_lexeme)
			else:
				# e.g. "CharacterName:"
				token = token.replace(":", "").strip_edges()
				lexemes.append({"type": YADS_CHARACTER, "text": token})
		else:
			lexemes.append({"type": YADS_TEXT, "text": token})
	return lexemes

## Attach commands and character changes to text blocks and replies
func get_blocks(lexemes: Array):
	# Godot doesn't support erasing while iterating
	# so we recreate the array by selectively adding elements
	const command_types = [YADS_GOTO, YADS_COMMAND, YADS_FINISH]
	const condition_types = [YADS_IF, YADS_ELIF, YADS_ELSE, YADS_ENDIF]
	var blocks: Array = []
	var character_change: Dictionary = {}
	for lexeme in lexemes:
		if lexeme["type"] in command_types:
			# Attach commands to blocks
			if blocks.is_empty():
				# Command at start; create a dummy
				var block = {
					"type": YADS_DUMMY,
					"commands": [lexeme]
				}
				blocks.append(block)
				continue
			var last_lexeme = blocks.back()
			if last_lexeme["type"] in condition_types:
				# Trying to add command to a conditional block;
				# create dummy instead
				var block = {
					"type": YADS_DUMMY,
					"commands": [lexeme]
				}
				blocks.append(block)
				continue
			elif last_lexeme["type"] in command_types:
				push_error("""Trying to append a command (%s) to a command (%s).
					This could be an error in the parser""" % [lexeme, last_lexeme]
				)
				continue
			else:
				if last_lexeme.has("commands"):
					last_lexeme["commands"].append(lexeme)
				else:
					last_lexeme["commands"] = [lexeme]
		elif lexeme["type"] == YADS_CHARACTER:
			character_change = lexeme
		else:
			# Conditionals syntax and regular blocks
			if not character_change.is_empty() and lexeme["type"] == YADS_TEXT:
				# Attach character changes to text blocks
				lexeme["character_change"] = character_change["text"]
				if character_change.has("meta"):
					lexeme["character_change_meta"] = character_change["meta"]
				character_change = {}
			blocks.append(lexeme)
	return blocks

func get_tree(blocks: Array) -> Array:
	const direct_types = [YADS_DUMMY, YADS_TEXT, YADS_REPLY]
	var tree: Array = []
	var choice: Dictionary = {} # holds if-elif-else blocks
	var current_condition: Dictionary = {} # contents of an if block
	for block in blocks:
		if block["type"] in direct_types:
			if choice.is_empty():
				tree.append(block)
				continue
			else:
				# Collapse blocks into conditional branches
				current_condition.get_or_add("blocks", []).append(block)
		if block["type"] == YADS_IF:
			if not choice.is_empty():
				push_error("If block in an open if block: %s" % block)
				continue
			choice["type"] = YADS_CHOICE
			current_condition = {"condition": block}
			choice["conditions"] = [current_condition]
		elif block["type"] == YADS_ELIF:
			if choice.is_empty():
				push_error("Elif block in without an if block: %s" % block)
				continue
			current_condition = {"condition": block}
			choice["conditions"].append(current_condition)
		elif block["type"] == YADS_ELSE:
			if choice.is_empty():
				push_error("Dangling else block found")
				continue
			current_condition = {} # still need to append blocks to it
			choice["default"] = current_condition
		elif block["type"] == YADS_ENDIF:
			tree.append(choice)
			choice = {}
	return tree
