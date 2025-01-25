extends RigidBody2D


@export var asideMultiplier = 200

var anchor
var inv=1
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Collision Layer:", collision_layer)
	print("Collision Mask:", collision_mask)
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	self.connect("body_entered", Callable(self,"_on_body_entered"))
	
func _on_body_entered(body):
	if body.collision_layer & (1 << 2):  # Vérifie si le corps appartient au layer 2
		inv *= -1  # Inverser la direction
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var toAnchor = anchor.position - position
	var anchorDist = toAnchor.length()
	var forceMultiplier = anchorDist
	var anchorForce = toAnchor.normalized() * forceMultiplier
	var asideVec=-Vector2(toAnchor.y,-toAnchor.x) #vector oriented toward the left
	var asideForce
	asideForce=asideVec.normalized()*asideMultiplier*inv
	var totalForce = anchorForce + asideForce
	apply_force(totalForce)
