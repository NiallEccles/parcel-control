extends Node

@export var sprite_3d: Sprite3D
@export var label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("grabbable"):
		print("something in me")
		label.text = str(body.mass)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group('grabbable'):
		print('something left me')
