extends Node3D

## Node references -- assign these in the Inspector.
@export var camera: Camera3D
@export var ray: RayCast3D
@export var hold_point: Marker3D
@export var player_body: PhysicsBody3D
@export var dynamic_crosshair: DynamicCrosshair

## Won't pick up anything heavier than this (kg).
@export var max_grab_mass: float = 25.0

## Spring (P) and damping (D) gains for the hold. Units are 1/s^2 and 1/s --
## see the tuning notes below for how to pick these.
@export var position_p_gain: float = 90.0
@export var position_d_gain: float = 14.0

## If the object can't keep up with the hold point by more than this
## (usually because it's wedged against geometry), let go instead of
## dragging it -- and the player -- through the wall.
@export var auto_release_distance: float = 2.0

## Throw speed in meters/second.
@export var throw_speed: float = 16.0

var held_body: RigidBody3D
var _saved_state: Dictionary = {}

func _ready() -> void:
	assert(camera and ray and hold_point and player_body and dynamic_crosshair,
		"GrabController: assign all exported node references in the Inspector.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if held_body:
			_drop()
		else:
			_try_grab()
	elif event.is_action_pressed("throw") and held_body:
		_throw()

func _physics_process(_delta: float) -> void:
	if held_body == null:
		return

	var to_target := hold_point.global_position - held_body.global_position
	if to_target.length() > auto_release_distance:
		_drop()
		return

	# P term: spring force toward the hold point.
	# D term: damps the object's own velocity so it settles instead of
	# oscillating past the target.
	# Multiplying by mass makes this a mass-normalized controller -- a
	# heavy crate and a light envelope both converge at the same rate.
	var force := to_target * position_p_gain - held_body.linear_velocity * position_d_gain
	held_body.apply_central_force(force * held_body.mass)

func _try_grab() -> void:
	if not ray.is_colliding():
		return
	var collider := ray.get_collider()
	if collider is RigidBody3D and collider.is_in_group("grabbable") \
			and collider.mass <= max_grab_mass:
		_grab(collider)

func _grab(body: RigidBody3D) -> void:
	dynamic_crosshair.set_crosshair(dynamic_crosshair.CROSSHAIRS.HOLDING)
	held_body = body
	_saved_state = {
		gravity_scale = body.gravity_scale,
		linear_damp = body.linear_damp,
		angular_damp = body.angular_damp,
		can_sleep = body.can_sleep,
		lock_rotation = body.lock_rotation,
	}
	body.gravity_scale = 0.0
	body.linear_damp = 0.0
	body.angular_damp = 0.0
	body.can_sleep = false   # a sleeping body ignores apply_central_force
	body.sleeping = false
	body.lock_rotation = true   # simplest option -- see the rotation section below
	body.add_collision_exception_with(player_body)

func _drop() -> void:
	_restore_state(held_body)
	held_body = null
	dynamic_crosshair.set_crosshair(dynamic_crosshair.CROSSHAIRS.DEFAULT)

func _throw() -> void:
	var body := held_body
	_restore_state(body)
	held_body = null
	body.linear_velocity = -camera.global_transform.basis.z * throw_speed

func _restore_state(body: RigidBody3D) -> void:
	body.gravity_scale = _saved_state.gravity_scale
	body.linear_damp = _saved_state.linear_damp
	body.angular_damp = _saved_state.angular_damp
	body.can_sleep = _saved_state.can_sleep
	body.lock_rotation = _saved_state.lock_rotation
	body.remove_collision_exception_with(player_body)
