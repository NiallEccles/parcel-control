@tool
class_name DynamicCrosshair
extends Node

enum CROSSHAIRS {
	OPEN,
	HOLDING,
	DEFAULT
}

const crosshair_assets = [
	preload("res://Entities/DynamicCrosshair/assets/hand_open.png"),
	preload("res://Entities/DynamicCrosshair/assets/hand_closed.png"),
	preload("res://Entities/DynamicCrosshair/assets/dot_large.png")
]

@export var sprite_2d: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#sprite_2d.visible = false
	sprite_2d.texture = crosshair_assets[CROSSHAIRS.DEFAULT]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_crosshair(crosshair: CROSSHAIRS) -> void:
	assert(
		crosshair >= 0 and crosshair < crosshair_assets.size(),
		"DynamicCrosshair: invalid crosshair %s" % crosshair
	)
	sprite_2d.texture = crosshair_assets[crosshair]
