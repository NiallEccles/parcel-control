extends CharacterBody3D

@export_category('Movement')
@export var walk_speed: float = 4.0
@export var crouch_speed: float = 3.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 3.0

@export var interaction_ray: RayCast3D
@export var dynamic_crosshair: DynamicCrosshair

@export var flashlight_on_sound: AudioStream
@export var flashlight_off_sound: AudioStream

var current_speed = walk_speed

const MOUSE_SENSITIVITY = 0.1
var lerp_speed = 10.0
var direction: Vector3 = Vector3.ZERO
var crouching_depth: float = -0.5
var head_height: float

@onready var standing_collison_shape = $StandingCollisonShape
@onready var crouching_collison_shape = $CrouchingCollisonShape
@onready var can_stand_raycast: RayCast3D = $CanStandRaycast
@onready var camera: Camera3D = $Head/Camera3D
@export var head: Node3D

@export var hold_point: Marker3D
@export var pickup_range: float = 3.0
@export var throw_speed: float = 12.0

var current_target = null
var flashlight_on = false
var zoom_tween: Tween

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	head_height = head.position.y
	
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))


func _physics_process(delta: float) -> void:
			
 #for logic about interacting with the switch and showing text
	if interaction_ray.is_colliding():
		dynamic_crosshair.set_crosshair(dynamic_crosshair.CROSSHAIRS.OPEN)
		var collider = interaction_ray.get_collider()
		if collider != current_target and collider.has_method('interact'):
			if current_target:
				#current_target.get_node("InteractLabel").visible = false
				dynamic_crosshair.hide_crosshair()

			#collider.get_node("InteractLabel").visible = true
			current_target = collider
			dynamic_crosshair.show_crosshair()
	else:
		if current_target:
			#current_target.get_node("InteractLabel").visible = false
			current_target = null
			dynamic_crosshair.hide_crosshair()
	
	if Input.is_action_just_pressed("interact"):
		if !interaction_ray.is_colliding():
			return
		
		print('is colliding..')
		var collider = interaction_ray.get_collider()

	if Input.is_action_pressed('crouch'):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y, (head_height + crouching_depth), delta * lerp_speed)
		standing_collison_shape.disabled = true
		crouching_collison_shape.disabled = false
	elif can_stand_raycast and !can_stand_raycast.is_colliding():
		head.position.y = lerp(head.position.y, head_height, delta * lerp_speed)
		standing_collison_shape.disabled = false
		crouching_collison_shape.disabled = true
		if Input.is_action_pressed('sprint'):
			current_speed = sprint_speed
		else:
			current_speed = walk_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	#footsteps.update(input_dir, is_on_floor(), current_speed, delta)
