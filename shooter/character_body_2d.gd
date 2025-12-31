extends CharacterBody2D


const SPEED = 400.0
const TRACT = 90.0

@onready var barrel = $CollisionShape2D/Marker2D
var b = preload("res://scenes/bullet.tscn")

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir != Vector2.ZERO:
		velocity = (dir.normalized() * SPEED)
	else:
		#velocity = Vector2.ZERO
		velocity = velocity.move_toward(Vector2.ZERO,TRACT)

	move_and_slide()
	
	if Input.is_action_just_pressed("fire"):
		barrel.fire()
		#print("piss")
		#var bullet = b.instantiate()
		#bullet.global_position = barrel.global_position
		#bullet.dir = (get_global_mouse_position() - global_position).normalized()
		#get_tree().current_scene.add_child(bullet)
		#
