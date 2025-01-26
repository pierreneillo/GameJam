extends RigidBody2D

@export var dirMultiplier = 500
@export var impulsMultiplier = 20000
@export var impulsInBubble = 1000
@export var maxJumps = 2
@export var maxSpeed = 450
@export var k = 500000
@export var marge = 30 
@export var maxSlopeAngle = TAU/6
@export var invicibilityTimeMax=3
@export var animDelay=0.1
@export var gunBubblesSeconds = 3
@export var maxGunBubbles=4 #number of bullets authorized per gunBubblesSeconds seconds
@export var maxTimerAfterBubble=.5
var gunBubbles=0

var debugChurch
var bulletScene = preload("res://bullet.tscn")

var bubble1
var bubble2
var nbJumps=0
var on_floor: bool = false
var on_floor_time=0
var hearts: int = 3
var invicibility: = false
var invicibilityTime=0
var spriteDefault
var spriteFlying
var bubbles
var gunTimer=0
var camera
var audioStreams

var inBubble=false
var currentR
var impulsSens=1
var tempMult=1
var timerAfterInBubble=0
# Called when the node enters the scene tree for the first time.
func _ready():
	bubbles=get_tree().get_nodes_in_group("anchor")
	debugChurch = get_tree().get_nodes_in_group("debugChurch")[0]
	
	audioStreams = get_tree().get_nodes_in_group("audioStreams")
	camera = get_tree().get_nodes_in_group("camera")[0]
	$"../HUD".visible=true
	self.connect("body_entered", Callable(self,"_on_body_shape_entered"))
	spriteDefault=get_node("LR")
	spriteFlying=get_node("flyin")
	spriteDefault.material.set_shader_parameter("solid_color",Color(0,0,0,0))
	spriteFlying.material.set_shader_parameter("solid_color",Color(0,0,0,0))

	
func _on_body_shape_entered(body):
	if (body.get_collision_layer_value(2) or body.get_collision_layer_value(4)) and invicibility==false and hearts!=0:  # Vérifie si l'objet appartient à la layer 3
		var H=get_node("../HUD/Heart"+str(hearts))
		H.visible=false
		hearts-=1
		invicibility=true
		spriteDefault.material.set_shader_parameter("solid_color",Color(255.,0.,0.,.5))
		spriteFlying.material.set_shader_parameter("solid_color",Color(255.,0.,0.,.5))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var i := 0
	var up = (global_position - bubble1.global_position).normalized()
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
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dist1=INF
	var dist2=INF
	
	for i in bubbles:
		var dist=(i.position-position).length()
		if dist<dist1:
			dist1=dist
			bubble2=bubble1
			bubble1=i
		elif dist<dist2:
			dist2=dist
			bubble2=i
				
	var tobubble1 = bubble1.position - position

	var toMouse = get_global_mouse_position() - position

	var forceMultiplier1 = k/dist1
	# Gravity model for now, independant of the distance to the center of the bubble
	var bubble1Force = tobubble1.normalized() * forceMultiplier1
	
	var tobubble2 = bubble2.position - position
	var forceMultiplier2 = k/dist2
	var bubble2Force = tobubble2.normalized() * forceMultiplier2
	
	var dir=Vector2.ZERO
	var impuls=Vector2.ZERO
	draw_line(position,  get_viewport().get_mouse_position() , Color.RED)
	# Change direction so that the sprite is "standing" on the planet
	set_rotation(tobubble1.angle() - PI/2)
	'''
	var normalVector = (Vector2.UP.rotated( transform.get_rotation())).normalized()
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, position - normalVector*marge )
	debugChurch.position =  position - normalVector*80
	var result = space_state.intersect_ray(query)
	var isOnGround = (result != {}) '''
	var bulletRecoil = Vector2(0,0)

	var frogAnim = 0


	if Input.is_action_just_pressed("Inthebubble") and on_floor and inBubble==false: #need to check if is on the ground
		impuls=tobubble1
		collision_mask &= ~(1 << 4)
		inBubble=true
		currentR=dist1
	if Input.is_action_just_pressed("Jump") and (on_floor or nbJumps<maxJumps): #need to check if is not in the air already
		impuls=-tobubble1
		nbJumps+=1
	if Input.is_action_pressed("Left"):
		dir=-Vector2(tobubble1.y,-tobubble1.x)
		frogAnim = 0
		
	if Input.is_action_pressed("Right"):
		frogAnim = 1
		dir=Vector2(tobubble1.y,-tobubble1.x)
	if on_floor and nbJumps>=maxJumps:
		nbJumps=0
	if Input.is_action_just_pressed("click") and gunBubbles<=maxGunBubbles:
		if gunTimer==0:
			gunTimer+=delta
		var b = bulletScene.instantiate()
		get_tree().get_current_scene().add_child(b)
		# Set the position and impulse
		b.position = position + toMouse.normalized().rotated((randf()-0.5)*0.5)*100
		var angle=toMouse.dot(Vector2(1,0))/toMouse.length()
		print(toMouse,angle)
		b.rotation = angle + PI/2
		b.apply_force(toMouse.normalized()*50000)
		bulletRecoil = -toMouse.normalized()*10000
		gunBubbles+=1
	if gunTimer>0 and gunTimer<gunBubblesSeconds:
		gunTimer+=delta
	if gunTimer>=gunBubblesSeconds and on_floor:
		gunTimer=0
		gunBubbles=0
	if on_floor:
		on_floor_time=0
	else:
		on_floor_time+=delta
	
	if on_floor_time>animDelay:
		frogAnim = 2

		# Flying
	if inBubble:
		if dist1>100:
			impuls=tobubble1*impulsSens
		elif dist1<100 and impulsSens==1:
			impulsSens=-1
		bubble1Force=Vector2.ZERO
		bubble2Force=Vector2.ZERO
		frogAnim=2
		if dist1>currentR:
			print(dist1,"a",currentR)
			inBubble=false
			collision_mask |= (1 << 4)
			impulsSens=1
			tempMult=100
		
	if frogAnim == 0:
		# Left
		spriteDefault.flip_h = true
		
		spriteDefault.visible = true
		spriteFlying.visible = false
	elif frogAnim == 1:
		# Right
		spriteDefault.flip_h = false
		
		spriteDefault.visible = true
		spriteFlying.visible = false
	else: 
		spriteDefault.visible = false
		spriteFlying.visible = true
		spriteFlying.rotation = toMouse.angle() - rotation + PI/2
		
		
	var dirForce=dir.normalized()*dirMultiplier
	var impulseForce
	if inBubble:
		impulseForce=impuls.normalized()*impulsInBubble
	else:
		impulseForce=impuls.normalized()*impulsMultiplier
	var dragForce = -linear_velocity.normalized() * 10
	
	var totalForce = bubble1Force + bubble2Force + dirForce + impulseForce + dragForce + bulletRecoil
	apply_force(totalForce)
	if tempMult==100 and on_floor==false and timerAfterInBubble<maxTimerAfterBubble:
		timerAfterInBubble+=delta
	elif tempMult==100 and on_floor==false:
		linear_velocity=-linear_velocity.length()*Vector2.ONE*2
		tempMult=1
	if linear_velocity.length() > maxSpeed:
		# Calcule une force opposée proportionnelle au dépassement
		var excess_speed = linear_velocity.length() - maxSpeed
		var braking_force = -linear_velocity.normalized() * excess_speed * 10
		apply_force(braking_force)
	if invicibility and invicibilityTime<invicibilityTimeMax:
		invicibilityTime+=delta
	if invicibility and invicibilityTime>=invicibilityTimeMax:
		invicibilityTime=0
		invicibility=false
		spriteDefault.material.set_shader_parameter("solid_color",Color(0,0,0,0))
		spriteFlying.material.set_shader_parameter("solid_color",Color(0,0,0,0))
	
	var toBuwble
	if tobubble1.length() < tobubble2.length():
		toBuwble = tobubble1
	else:
		toBuwble = tobubble2
	
	camera.centerOnPlayer(position,delta,toBuwble)
	
	# musicStuffs
	

	# Piano
	var discrepancyOne = ((bubbles[0].position - position).length() - 1800)
	if (bubbles[0].position - position).length() > 1800:
		audioStreams[0].volume_db = - discrepancyOne * 0.01 #Vector2(1.0,1.0) * exp(-discrepancy*0.002)
	else:
		audioStreams[0].volume_db = 0.0
	
	# Synth Chords
	var discrepancyTwo = ((bubbles[1].position - position).length() - 1800)
	if (bubbles[1].position - position).length() > 1800:
		audioStreams[1].volume_db = - discrepancyTwo * 0.01 #Vector2(1.0,1.0) * exp(-discrepancy*0.002)
	else:
		audioStreams[1].volume_db = 0.0
	
	
	var airMax = min(discrepancyOne,discrepancyTwo)
	# Melody
	var newDB = -exp(-(airMax-400)*0.007)
	audioStreams[2].volume_db = newDB
	if hearts==0:
		var endScreen=get_node("../../../Camera2D/GameOver")
		var level=get_node("../")
		level.visible=false
		var display=get_node("../../../Display")
		display.visible=false
		endScreen.visible=true
		
