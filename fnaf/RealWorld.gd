extends Node2D

var cursor = preload("res://sprites/Cursor6.png")
@onready var office = $Office
@onready var doorL = $DoorL

@onready var enemy: PackedScene = preload("res://scenes/enemies/baseEnemy.tscn")

var enemy1: PackedScene

var gun = 1
var scroll_accum = 0.0
const SCROLL_SENS = 0.25 # lower = less sensitive

func _ready():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	spawn_enemy()

func spawn_enemy():
	var e = enemy.instantiate()
	e.global_position = doorL.global_position
	add_child(e)
	


func _input(event):
	handle_scroll(event)

func handle_scroll(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_accum -= SCROLL_SENS
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_accum += SCROLL_SENS
		
		#print("increment", scroll_accum)
		# clamp accumulator so it doesn’t grow unbounded
		scroll_accum = clamp(scroll_accum, 1, 6)

		# only update gun when we cross whole number boundaries
		var new_gun = int(scroll_accum)
		
		if new_gun != gun:
			gun = new_gun
			print("gun:", gun)
	
