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
	var anchorPos = anchor.position
	
	var toAnchor = anchorPos - position
	
	
	
	var anchorDist = toAnchor.length()
	print(anchorDist)
	var forceMultiplier = exp(-anchorDist/10.0)
	print(forceMultiplier)
	var anchorForce = toAnchor.normalized() * forceMultiplier
	
	apply_force(toAnchor*3.0)
	#move_and_slide()
	pass
