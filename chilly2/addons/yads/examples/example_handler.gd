extends YadsHandler
## This is the node you attach to nodes which can trigger dialogue.
## Call start() on this node to show and process dialogue.
## When it's a scene root like here, press F6 to play the dialogue in-engine.

var your_dialogue_scene = preload("res://addons/yads/examples/example_dialogue_gui.tscn")
#var your_dialogue_scene = preload("res://addons/yads/examples/example_dialogue_gui_simple.tscn")

## Override this method to replace the default dialogue gui.
func _get_dialogue_scene():
	return your_dialogue_scene

## You can supply an object instance (e.g. a "Story" singleton)
## for Expression evaluation. This allows you to use your
## own functions (defined in that instance) in the dialogue code snippets.
## See Godot's docs for Expression for details.
## The instance needs to support the same functions as the Yads
## singleton in order for certain syntax to work.
##
## In this case, we will pass the singleton,
## which is the default used when this function is not overridden.
func _get_expression_executor_instance():
	return Yads

## We will print our variables at the end.
func _ready():
	super._ready()
	# Signal from base handler instance
	finished.connect(print_variables)

func print_variables():
	# Use JSON to indent the dict nicely
	print(JSON.stringify(Yads.dialogue_variables, '\t', false))
