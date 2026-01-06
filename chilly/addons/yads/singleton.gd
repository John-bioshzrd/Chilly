extends Node

var dialogue_variables: Dictionary = {}

## You don't have to store dialogue data as a dictionary,
## but the plugin needs to be able to retrieve variable names and values
## in order to bind the variables in scripts
func get_variable_names() -> PackedStringArray:
	return dialogue_variables.keys()

func get_variable_values() -> Array:
	return dialogue_variables.values()

## This function enables support for "x=7" syntax,
## which is not normally supported by Expressions.
func store(key, val):
	dialogue_variables[key] = val

# This is a debug function but it's also an example of custom functions in dialogue.
# Variables are evaluated before reaching this function, so we don't manually
# retrieve them through the dictionary.
func dprint(value):
	print("dprint: ", value)

# A showcase function.
func get_four():
	return 4
