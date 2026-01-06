class_name VNCharacter
extends TextureRect

@export var data:VNCharacterData

signal garbage_error

func _ready() -> void:
	# CHANGED: read initial sprite from shared resource
	if data == null:
		push_error("VNCharacter data resource is not assigned")
		return
	texture = data.default_sprite


func attr(attribute:String = "") -> void:
	print("Getting attribute " + attribute)

	if data == null:
		push_error("VNCharacter data resource is not assigned")
		return

	# CHANGED: validate against data.tagged_sprites
	if !data.tagged_sprites.has(attribute):
		push_warning("Missing sprite tag: " + attribute)
		texture = data.default_sprite
		return

	texture = data.tagged_sprites[attribute]


func snap(targ:Node) -> void:
	if targ == null:
		return
	# keep using global coords for robustness
	global_position = targ.global_position + Vector2(-size.x / 2, 0)

func move(
	targ:Node,
	seconds:float = 1.0,
	trans:Tween.TransitionType = Tween.TRANS_QUAD
) -> Signal:
	var tween:Tween = get_tree().create_tween()

	if targ != null:
		var pos:Vector2 = targ.global_position + Vector2(-size.x / 2, 0)
		tween.tween_property(self, "global_position", pos, seconds).set_trans(trans)

	return tween.finished



func say(text:String, tag:String = "") -> Signal:
	if data == null:
		push_error("VNCharacter data resource is not assigned")
		emit_signal("garbage_error")
		return garbage_error

	var d := data.dialog_box.instantiate()
	if d == null:
		push_error("DialogBox PackedScene failed to instantiate")
		emit_signal("garbage_error")
		return garbage_error

	d.dialog = text
	get_tree().root.add_child(d)
	return d.complete
