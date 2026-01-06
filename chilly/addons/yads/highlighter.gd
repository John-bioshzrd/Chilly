@tool
extends EditorSyntaxHighlighter

const COLOR_NODE = Color.LIGHT_GREEN
const COLOR_COMMENT = Color.DIM_GRAY
const COLOR_COMMAND_BRACKET = Color.WEB_GRAY
const COLOR_COMMAND = Color.STEEL_BLUE
const COLOR_REPLY = Color.HOT_PINK
const COLOR_REPLY_TXT = Color.LIGHT_GRAY
const COLOR_CHARACTER = Color.MEDIUM_SEA_GREEN
const COLOR_KEYWORD = Color.MEDIUM_PURPLE

# First line -> Last line
var multiline_comments: Dictionary = {}

func _get_name() -> String:
	return "YADS"

func _get_supported_languages() -> PackedStringArray:
	return ["txt"]

func _clear_highlighting_cache():
	multiline_comments.clear()

func _get_line_syntax_highlighting(line_num: int) -> Dictionary:
	var color_map = {}
	var text_editor = get_text_edit()
	# Current line cannot be stripped because it misaligns result color positions
	var str = text_editor.get_line(line_num)
	var prev = text_editor.get_line(line_num-1).strip_edges()
	
	# Comments
	if str.strip_edges().begins_with("#"):
		color_map[0] = { "color": COLOR_COMMENT }
		return color_map
	if str.strip_edges().begins_with("{#"):
		multiline_comments[line_num] = TYPE_MAX # assume comment doesn't end
		var idx = line_num
		# Find multiline comment end and cache it
		while idx < text_editor.get_line_count():
			idx += 1
			var str2 = text_editor.get_line(idx).strip_edges()
			# Comments also end on blank line because
			# this is how the parser will behave
			if str2.ends_with("#}") or str2.is_empty():
				multiline_comments[line_num] = idx
				break
		color_map[0] = { "color": COLOR_COMMENT }
		return color_map
	for multiline_start in multiline_comments:
		if line_num >= multiline_start and line_num <= multiline_comments[multiline_start]:
			color_map[0] = { "color": COLOR_COMMENT }
			return color_map
	
	# Node start
	if str.begins_with("==="):
		color_map[0] = { "color": COLOR_NODE }
	
	# Commands
	var code_open_separator = str.find("{%")
	var code_end_separator = str.find("%}")

	if code_open_separator > -1:
		#color_map[0] = { "color": Color.GRAY }
		color_map[code_open_separator] = { "color": COLOR_COMMAND_BRACKET }
		
		var regex = RegEx.new()
		regex.compile("if|elif|else|endif|goto|finish")
		var result = regex.search(str)
		if result:
			color_map[result.get_start()] = { "color": COLOR_KEYWORD }
			color_map[result.get_end()] = { "color": COLOR_COMMAND }
		else:
			# After {%
			color_map[code_open_separator + 2] = { "color": COLOR_COMMAND }
	if code_end_separator > -1:
		color_map[code_end_separator] = { "color": COLOR_COMMAND_BRACKET }
	
	# Replies
	var reply_separator = str.find("->")
	if reply_separator > -1:
		color_map[reply_separator] = { "color": COLOR_REPLY }
		color_map[reply_separator + 2] = { "color": COLOR_REPLY_TXT }
	
	# Character names
	var char_separator = str.find(":")
	var prev_is_command = prev.begins_with("{%")
	var prev_is_node = prev.begins_with("===")
	var prev_is_comment = prev.begins_with("#")
	if str.strip_edges().ends_with(":"):
		# Find first alphanumeric character (ie skip spaces and tabs)
		var regex = RegEx.new()
		regex.compile("[a-zA-Z0-9_]")
		var result = regex.search(str)
		if prev.is_empty() or prev_is_command or prev_is_node or prev_is_comment:
			color_map[result.get_start()] = { "color": COLOR_CHARACTER }
	return color_map
