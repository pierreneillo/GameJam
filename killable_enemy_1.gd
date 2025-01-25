extends RigidBody2D


@export var speed = 50
@export var k = 200

var anchor
var direction = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	self.connect("body_entered", Callable(self,"_on_body_entered"))
	
func _on_body_entered(body):
	if body.get_collision_layer_value(3):  # Vérifie si l'objet appartient à la layer 3
		print("truc")
		direction = - direction
	

func _physics_process(delta: float) -> void:
	var toAnchor = anchor.position - position
	var toMouse = get_viewport().get_mouse_position() - position
	var anchorDist = toAnchor.length()
	var forceMultiplier = k/anchorDist

	# Gravity model for now, independant of the distance to the center of the bubble
	var anchorForce = toAnchor.normalized() * forceMultiplier

	var dir=Vector2.ZERO

	# Change direction so that the sprite is "standing" on the planet
	set_rotation(toAnchor.angle() - PI/2)

	var normalVector = (Vector2.UP.rotated( transform.get_rotation())).normalized()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, position - normalVector*80 )
	var result = space_state.intersect_ray(query)

	var bulletRecoil = Vector2(0,0)

	var isOnGround = (result != {})
	

	var dragForce = -linear_velocity.normalized() * 10
	
	var movement_force = Vector2.ZERO
	if isOnGround:
		var tangeant_right = Vector2(-toAnchor.y, toAnchor.x).normalized()
		movement_force = speed * tangeant_right * direction

	var totalForce = anchorForce*10 + dragForce + movement_force
	apply_force(totalForce)
