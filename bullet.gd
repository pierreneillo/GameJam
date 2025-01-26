extends RigidBody2D

var anchor
@export var timeToDeath=1.
var timer=0.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var timeStart = OS.get_ticks()
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	self.connect("body_entered", Callable(self,"_on_body_shape_entered"))
	
func _on_body_shape_entered(body):
	die()
	
func die():
	queue_free() # Deletes this node (self) at the end of the frame



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer+=delta
	var toAnchor = anchor.position - position
	rotation = linear_velocity.angle() + PI/2
	apply_force(toAnchor.normalized() * 1000.0)
	#print('ahah')
	if timer>timeToDeath:
		die()
