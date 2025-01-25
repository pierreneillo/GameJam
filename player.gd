extends RigidBody2D

@export var dirMultiplier = 500
@export var impulsMultiplier = 20000

var debugChurch
var bulletScene = preload("res://bullet.tscn")

var anchor
# Called when the node enters the scene tree for the first time.
func _ready():
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	debugChurch = get_tree().get_nodes_in_group("debugChurch")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	

	var toAnchor = anchor.position - position
	var toMouse = get_viewport().get_mouse_position() - position
	var anchorDist = toAnchor.length()
	var forceMultiplier = anchorDist
	
	# Gravity model for now, independant of the distance to the center of the bubble
	var anchorForce = toAnchor.normalized() * forceMultiplier
	
	var dir=Vector2.ZERO
	var impuls=Vector2.ZERO
	
	# Change direction so that the sprite is "standing" on the planet
	set_rotation(toAnchor.angle() - PI/2)
	
	var normalVector = (Vector2.UP.rotated( transform.get_rotation())).normalized()
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(position, position - normalVector*80 )
	debugChurch.position =  position - normalVector*80
	var result = space_state.intersect_ray(query)
	
	var isOnGround = (result != {})

	if Input.is_action_just_pressed("Inthebubble"): #need to check if is on the ground
		impuls=toAnchor
	if Input.is_action_just_pressed("Jump") and isOnGround: #need to check if is not in the air already
		impuls=-toAnchor
	if Input.is_action_pressed("Left") and (isOnGround):
		dir=-Vector2(toAnchor.y,-toAnchor.x)
	if Input.is_action_pressed("Right") and (isOnGround):
		dir=Vector2(toAnchor.y,-toAnchor.x)
		
	if Input.is_action_just_pressed("click"):
		var b = bulletScene.instantiate()
		get_tree().get_current_scene().add_child(b)
		

		
		# Set the position and impulse
		
		b.position = position + toMouse.normalized()*100
		b.rotation = toMouse.angle() + PI/2
		b.apply_force(toMouse.normalized()*100000)
	var dirForce=dir.normalized()*dirMultiplier
	var impulsForce=impuls.normalized()*impulsMultiplier
	
	var dragForce = -linear_velocity.normalized() * 10
	
	var totalForce = anchorForce + dirForce + impulsForce + dragForce
	apply_force(totalForce)
	
	
