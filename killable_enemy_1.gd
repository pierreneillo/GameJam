extends RigidBody2D


@export var speed = 100
@export var k = 100000
@export var maxSpeed = 450
@export var maxSlopeAngle=TAU/6
var anchor
var direction = 1
var on_floor: bool = false

# Called when the node enters the scene tree for the first time.

func _ready():
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	self.connect("body_entered", Callable(self,"_on_body_shape_entered"))
	
func _on_body_shape_entered(body):
	if body.get_collision_layer_value(3):  # Vérifie si l'objet appartient à la layer 3
		direction = - direction

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var i := 0
	var up = (global_position - anchor.global_position).normalized()
	on_floor=false
	while i < state.get_contact_count():
		var normal := state.get_contact_local_normal(i)
		on_floor = normal.dot(up) > cos(maxSlopeAngle) # this can be dialed in
		#  1.0 would be perfectly straight up
		#  0.0 is a wall
		# -1.0 is a ceiling
		i += 1
		if on_floor:
			break
			
		

func _physics_process(delta: float) -> void:
	var toAnchor = anchor.global_position - global_position
	var anchorDist = toAnchor.length()
	var forceMultiplier =k/anchorDist

	# Gravity model for now, independant of the distance to the center of the bubble
	var anchorForce = toAnchor.normalized() * forceMultiplier


	# Change direction so that the sprite is "standing" on the planet
	set_rotation(toAnchor.angle() - PI/2)

	'''var normalVector = (Vector2.UP.rotated( transform.get_rotation())).normalized()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, position - normalVector*80 )
	var result = space_state.intersect_ray(query)

	var isOnGround = (result != {})'''

	var dragForce = -linear_velocity.normalized() * 10
	
	var movement_force = Vector2.ZERO
	if on_floor:
		var tangeant_right = Vector2(-toAnchor.y, toAnchor.x).normalized()
		movement_force = speed * tangeant_right * direction
	var totalForce = anchorForce + dragForce + movement_force
	apply_force(totalForce)
	if linear_velocity.length() > maxSpeed:
		# Calcule une force opposée proportionnelle au dépassement
		var excess_speed = linear_velocity.length() - maxSpeed
		var braking_force = -linear_velocity.normalized() * excess_speed * 10
		apply_force(braking_force)
