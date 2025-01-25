extends RigidBody2D

@export var dirMultiplier = 500
@export var impulsMultiplier = 20000
@export var maxJumps = 2
@export var maxSpeed = 450
@export var k = 200
@export var marge = 30 

var debugChurch
var bulletScene = preload("res://bullet.tscn")

var anchor
var nbJumps=0

# Called when the node enters the scene tree for the first time.
func _ready():
	anchor = get_tree().get_nodes_in_group("anchor")[0]
	debugChurch = get_tree().get_nodes_in_group("debugChurch")[0]
	#$HUD.visible=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var toAnchor = anchor.position - position
	var toMouse = get_viewport().get_mouse_position() - position
	var anchorDist = toAnchor.length()
	var forceMultiplier = 1000 # k/anchorDist

	# Gravity model for now, independant of the distance to the center of the bubble
	var anchorForce = toAnchor.normalized() * forceMultiplier

	var dir=Vector2.ZERO
	var impuls=Vector2.ZERO

	# Change direction so that the sprite is "standing" on the planet
	set_rotation(toAnchor.angle() - PI/2)

	var normalVector = (Vector2.UP.rotated( transform.get_rotation())).normalized()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, position - normalVector*marge )
	debugChurch.position =  position - normalVector*80
	var result = space_state.intersect_ray(query)

	var bulletRecoil = Vector2(0,0)

	var frogAnim = 0
	var isOnGround = (result != {})

	if Input.is_action_just_pressed("Inthebubble"): #need to check if is on the ground
		impuls=toAnchor
	if Input.is_action_just_pressed("Jump") and (isOnGround or nbJumps<maxJumps): #need to check if is not in the air already
		impuls=-toAnchor
		nbJumps+=1
	if Input.is_action_pressed("Left"):
		dir=-Vector2(toAnchor.y,-toAnchor.x)
		frogAnim = 0
		
	if Input.is_action_pressed("Right"):
		frogAnim = 1
		dir=Vector2(toAnchor.y,-toAnchor.x)
	if isOnGround and nbJumps>=maxJumps:
		nbJumps=0

	if Input.is_action_just_pressed("click"):
		var b = bulletScene.instantiate()
		get_tree().get_current_scene().add_child(b)
		# Set the position and impulse
		b.position = position + toMouse.normalized().rotated((randf()-0.5)*0.5)*100
		b.rotation = toMouse.angle() + PI/2
		b.apply_force(toMouse.normalized()*50000)
		bulletRecoil = -toMouse.normalized()*10000
	
	
	if not isOnGround:
		frogAnim = 2
	
	if frogAnim == 0:
		# Left
		get_child(0).get_child(0).flip_h = true
		
		get_child(0).get_child(0).visible = true
		get_child(0).get_child(1).visible = false
	elif frogAnim == 1:
		# Right
		get_child(0).get_child(0).flip_h = false
		
		get_child(0).get_child(0).visible = true
		get_child(0).get_child(1).visible = false
	else: 
		get_child(0).get_child(0).visible = false
		get_child(0).get_child(1).visible = true
		get_child(0).get_child(1).rotation = toMouse.angle() - rotation + PI/2
		
		
		# Flying
		
		
		
		
	var dirForce=dir.normalized()*dirMultiplier
	var impulsForce=impuls.normalized()*impulsMultiplier
	var dragForce = -linear_velocity.normalized() * 10
	
	var totalForce = anchorForce + dirForce + impulsForce + dragForce + bulletRecoil
	apply_force(totalForce)
	if linear_velocity.length() > maxSpeed:
		# Calcule une force opposée proportionnelle au dépassement
		var excess_speed = linear_velocity.length() - maxSpeed
		var braking_force = -linear_velocity.normalized() * excess_speed * 10
		apply_force(braking_force)
	
