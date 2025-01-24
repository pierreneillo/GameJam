extends RigidBody2D

var anchor
# Called when the node enters the scene tree for the first time.
func _ready():
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#normal
	#apply_force()
	#var anchor = Vector2(200,200)
	var mousePos = get_viewport().get_mouse_position()
	var toMouse = (mousePos - position).normalized()
	
	var a = 0.5
	rotation = wrapf(rotation+PI/2,-PI,PI)*(1-a) + a*toMouse.angle()
	
	var anchorPos = anchor.position
	var toAnchor = anchorPos - position
	var anchorDist = toAnchor.length()
	var forceMultiplier = anchorDist
	var anchorForce = toAnchor.normalized() * forceMultiplier
	
	var thrustOn = 1.0
	if Input.is_action_pressed("click"):
		print('jahaha')
		thrustOn = 1.0
	else:
		thrustOn = 0.0
	
	
	
	
	var thrustForce = toMouse * 400 * thrustOn
	
	var dragForce = -linear_velocity.normalized() * 100.0
	
	var totalForce = anchorForce + thrustForce + dragForce
	apply_force(totalForce)
	pass
