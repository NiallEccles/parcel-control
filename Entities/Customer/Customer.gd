extends CharacterBody3D

@export var speed: float = 3.0
@export var stopping_distance: float = 0.2
@export var gravity: float = 9.8
@export var bubble: Sprite3D
@export var bubble_text: Label

@export var wants: String

var target_slot: Slot
var was_interacted: bool = false


func _ready() -> void:
	_find_available_slot()
	bubble.visible = false


func _physics_process(delta: float) -> void:
	if target_slot == null:
		_find_available_slot()
		return

	# The slot has somehow become occupied.
	if target_slot.is_filled:
		target_slot = null
		return

	var target_position: Vector3 = target_slot.global_position
	var distance: float = global_position.distance_to(target_position)

	if distance <= stopping_distance:
		velocity.x = 0.0
		velocity.z = 0.0

		# Keep gravity active while stopped.
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0

		move_and_slide()

		target_slot.is_filled = true
		target_slot.is_reserved = false

		return

	# Move toward the target slot.
	var direction: Vector3 = global_position.direction_to(target_position)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()


func _find_available_slot() -> void:
	target_slot = Bus.claim_first_available_slot()

func _exit_tree() -> void:
	if target_slot != null and not target_slot.is_filled:
		Bus.release_slot(target_slot)
		
func interact() -> void:
	if was_interacted:
		bubble_text.text = 'Uhh I already told you...'
	else:
		bubble_text.text = wants
		was_interacted = true
	
	show_bubble()
		
func show_bubble() -> void:
	bubble.visible = true
