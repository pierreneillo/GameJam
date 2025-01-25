extends Area2D

var player
var dir = Vector2.UP
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var toPlayer = player.position - position
	rotation = dir.angle() + PI/2
	
	if (randf() < 0.05):
		dir = toPlayer.normalized().rotated(randf())
	position += dir
	 
	pass
