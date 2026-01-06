@tool
extends EditorTranslationParserPlugin

func _get_recognized_extensions():
	return ["txt"]

func _parse_file(path):
	var translations: Array[PackedStringArray] = []
	var parser = YadsParser.new()
	var translatable_types = [
		parser.YADS_TEXT,
		parser.YADS_REPLY,
		parser.YADS_CHARACTER,
	]
	var nodes = parser.get_nodes_from_file(path)
	for node_id in nodes:
		var tokens = parser.tokenize_node(nodes[node_id])
		var lexemes = parser.get_lexemes(tokens)
		for lexeme in lexemes:
			#print(lexeme)
			if lexeme["type"] not in translatable_types:
				continue
			var entry: PackedStringArray = []
			entry.append(lexeme["text"]) # msgid = main text
			translations.append(entry)
	return translations
