extends Camera2D

@export var displayer : Sprite2D = null
@export var sv : SubViewport = null
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Zoom and move to fit the sub viewport to the screen
	var size = get_viewport().size
	var subsize = sv.size
	var x_ratio = size.x / subsize.x
	var y_ratio = size.y / subsize.y
	var scale = max(x_ratio,y_ratio)
	print(x_ratio,y_ratio)
	displayer.set_scale(Vector2(scale,scale))
	print(displayer.scale)
	displayer.global_position = size/2
	global_position = size/2
