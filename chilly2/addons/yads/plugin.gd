@tool
extends EditorPlugin

const DialogueFileTranslationPlugin = preload("res://addons/yads/translation_plugin.gd")
const DialogueHighlighter = preload("res://addons/yads/highlighter.gd")

var translation_parser_plugin: DialogueFileTranslationPlugin
var dialogue_highlighter: DialogueHighlighter

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# Highlighter
	dialogue_highlighter = DialogueHighlighter.new()
	var script_editor = EditorInterface.get_script_editor()
	script_editor.register_syntax_highlighter(dialogue_highlighter)
	# Translations
	translation_parser_plugin = DialogueFileTranslationPlugin.new()
	add_translation_parser_plugin(translation_parser_plugin)
	# Singleton
	add_autoload_singleton("Yads", "res://addons/yads/singleton.gd")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if is_instance_valid(dialogue_highlighter):
		var script_editor = EditorInterface.get_script_editor()
		script_editor.unregister_syntax_highlighter(dialogue_highlighter)
		dialogue_highlighter = null
	if is_instance_valid(dialogue_highlighter):
		remove_translation_parser_plugin(translation_parser_plugin)
		translation_parser_plugin = null
	remove_autoload_singleton("Yads")
