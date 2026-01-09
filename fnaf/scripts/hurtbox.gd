class_name Hurtbox
extends Area2D

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	collision_layer = 0
	collision_mask = 3

func _ready() -> void:
	# Godot 4 — pass a Callable or the method reference
	connect("area_entered", Callable(self, "_on_area_entered"))
	# or: connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area == null:
		return
	var hitbox := area as Hitbox
	if hitbox == null:
		return
	owner.take_damage(hitbox.damage)
