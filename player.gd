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
	var forceMultiplier = anchorDist
	var anchorForce = toAnchor.normalized() * forceMultiplier
	
	var dir=Vector2.ZERO
	var impuls=Vector2.ZERO
	var distMultiplier = 500
	var impulsMultiplier = 20000
	if Input.is_action_just_pressed("Inthebubble"): #need to check if is on the ground
		impuls=toAnchor
	if Input.is_action_just_pressed("Jump") : #need to check if is not in the air already
		impuls=-toAnchor
	if Input.is_action_pressed("Left"):
		dir=-Vector2(toAnchor.y,-toAnchor.x)
	if Input.is_action_pressed("Right"):
		dir=Vector2(toAnchor.y,-toAnchor.x)
	var dirForce=dir.normalized()*distMultiplier
	var impulsForce=impuls.normalized()*impulsMultiplier
	var totalForce = anchorForce + dirForce + impulsForce
	apply_force(totalForce)
