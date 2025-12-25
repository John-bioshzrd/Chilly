class_name Hitbox
extends Area2D


func _init() -> void:
	collision_layer = 3
	
#	Hurtbox layer
	collision_mask = 0 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
