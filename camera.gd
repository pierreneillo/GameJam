extends Camera2D

@export var player : RigidBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = player.global_position

func fit_points_to_camera(points: Array):
	# Ensure there are points to fit
	if points.is_empty():
		print("ERROR: points list empty")
		return

	# Calculate bounding box of points
	points.sort_custom(func(p,q) : p.x < q.x)
	var min_x = points[0].x
	var max_x = points[-1].x
	points.sort_custom(func(p,q) : p.y < q.y)
	var min_y = points[0].y
	var max_y = points[-1].y
	# Calculate the center of the bounding box
	var center = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	#global_position = center

	# Calculate the size needed to fit all points
	var width = max_x - min_x
	var height = max_y - min_y

	# Get the screen aspect ratio
	var viewport_size = get_viewport().size
	var aspect_ratio = viewport_size.x / viewport_size.y

	# Determine the zoom level to fit all points, considering aspect ratio
	var zoom_x = width / viewport_size.x
	var zoom_y = height / viewport_size.y
	var padded_zoom = max(zoom_x, zoom_y) *.8
	#zoom = Vector2(padded_zoom * aspect_ratio, padded_zoom)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	# On doit faire en sorte de toujours voir une bulle et le joueur
	# On cherche la bulle la plus proche
	var bubbles = get_tree().get_nodes_in_group("anchor")
	bubbles.sort_custom(func (bulle1,bulle2): (bulle1.global_position - player.global_position).length() < (bulle2.global_position - player.global_position).length())
	var nearest_bubble = bubbles[0]
	var bubble_size = nearest_bubble.get_node("CollisionShape2D").shape.get_rect().size.x;
	var bubble_surface_point = nearest_bubble.global_position + (global_position - nearest_bubble.global_position).normalized() * bubble_size
	
	fit_points_to_camera([player.global_position,bubble_surface_point])
	print([player.global_position,bubble_surface_point])
	
func centerOnPlayer(target_position,delta,toBuwble):
	#return
	
	global_position = global_position.lerp(target_position, (15 * delta)) 
	#global_position = target_position + Vector2(200,200)
	#print('lol')
	#if global_position.distance_to(target_position) <= 1: 
	#	position = position.round()
	
	print(toBuwble.length())
	if toBuwble.length() > 1800.0:
		print('ajaj')
		
		var discrepancy = (toBuwble.length() - 1800)
		print(discrepancy)
		
		zoom = Vector2(1.0,1.0) * exp(-discrepancy*0.002)
		#zoom = Vector2(1.0,1.0)  * 0.5
	else:
		zoom = Vector2(1.0,1.0)
		#Vector2(1.0,1.0) 	
	#global_position += Vector2(100,100)
