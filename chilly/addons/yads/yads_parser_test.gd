extends Node

# run this as scene with F6
func _ready() -> void:
	pass
	var parser = preload("res://addons/yads/dialogue_parser.gd").new()
	var node_dict = parser.get_nodes_from_file("res://addons/yads/examples/demo.yads.txt")
	#print(node_dict)
	for node_name in node_dict:
		print(node_name)
		var tokens = parser.tokenize_node(node_dict[node_name])
		#print(tokens)
		#for token in tokens:
			#print(token)
		var lexemes = parser.get_lexemes(tokens)
		#for lexeme in lexemes:
			#print(lexeme)
			
		var blocks = parser.get_blocks(lexemes)
		for block in blocks:
			print(JSON.stringify(block, '\t'))
			#print(block)
			pass
		
		var tree = parser.get_tree(blocks)
		for branch in tree:
			#print(branch)
			#print(JSON.stringify(branch, '\t', false))
			pass
		
		var dialogue = parser.get_node_dialogue(node_dict[node_name])
		for block in dialogue:
			#print(branch)
			#print(JSON.stringify(block, '\t', false))
			pass
	
	get_tree().quit()
