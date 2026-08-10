class_name Slot
extends Node

@export var is_filled: bool = false
@export var is_reserved: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_slot() -> void:
	is_filled = true
	
func empty_slot() -> void:
	is_filled = false
