extends RigidBody2D

var anchor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var timeStart = OS.get_ticks()
	die()
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	pass # Replace with function body.
	self.connect("body_entered", Callable(self,"_on_body_shape_entered"))
	
func _on_body_entered(body):
	if (body.get_collision_layer_value(2) or body.get_collision_layer_value(3) or body.get_collision_layer_value(5)):
		die_instant()
	
func die(deathTime=1.):
	# Do some action
	await get_tree().create_timer(deathTime).timeout # waits for 1 second
	# Do something afterwards
	queue_free() # Deletes this node (self) at the end of the frame

func die_instant():
	await get_tree().create_timer(0.).timeout
	queue_free() # Deletes this node (self) at the end of the frame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var toAnchor = anchor.position - position
	rotation = linear_velocity.angle() + PI/2
	apply_force(toAnchor.normalized() * 1000.0)
	#print('ahah')
	
	
	
	
	
	
	#apply_force(Vector2(1.0,1.0))
	pass
