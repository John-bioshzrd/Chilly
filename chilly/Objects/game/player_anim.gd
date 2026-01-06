extends Node2D
@export var animation_tree: AnimationTree
@onready var player = get_owner()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#if player.
	animation_tree.set("parameters/Push/blend_position", player.velocity.normalized())
