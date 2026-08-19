extends Node3D

## Node references -- assign these in the Inspector.
@export var camera: Camera3D
@export var ray: RayCast3D
@export var hold_point: Marker3D
@export var player_body: PhysicsBody3D
@export var dynamic_crosshair: DynamicCrosshair

func _ready() -> void:
	assert(camera and ray and hold_point and player_body and dynamic_crosshair,
		"GrabController: assign all exported node references in the Inspector.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()

func _physics_process(_delta: float) -> void:
	_update_crosshair()

func _try_interact() -> void:
	if not ray.is_colliding():
		return
	var collider := ray.get_collider()
	if collider is CharacterBody3D and collider.is_in_group("customer"):
		_interact(collider)

func _interact(body: CharacterBody3D) -> void:
	print(body)
	print('wat up')
	body.has_method('interact')
	body.interact()

	
func _update_crosshair() -> void:
	if ray.is_colliding():
		var collider := ray.get_collider()

		if collider is CharacterBody3D \
			and collider.is_in_group("customer"):
				dynamic_crosshair.set_crosshair(
					dynamic_crosshair.CROSSHAIRS.ASK
				)
				return
