extends Camera2D

var bSize
const SPEED = 2000
var xBounds = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bg = get_parent().get_node("Background")
	# texture size adjusted for the node's scale
	var bg_size = bg.texture.get_size() * bg.scale
	var half_bg_w = bg_size.x * 0.5

	# visible viewport size adjusted by camera zoom
	var viewport_size = get_viewport_rect().size * zoom
	var half_view_w = viewport_size.x * 0.5

	# compute min/max for camera center so the viewport stays inside the background
	var min_x = bg.global_position.x - half_bg_w + half_view_w
	var max_x = bg.global_position.x + half_bg_w - half_view_w

	# handle case where viewport is larger than background: lock to background center
	if min_x > max_x:
		min_x = bg.global_position.x
		max_x = bg.global_position.x

	xBounds = [min_x, max_x]
	print_debug("Camera xBounds:", xBounds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir = Input.get_axis("ui_left", "ui_right")
	position.x += dir * SPEED * delta
	position.x = clamp(position.x, xBounds[0], xBounds[1])
