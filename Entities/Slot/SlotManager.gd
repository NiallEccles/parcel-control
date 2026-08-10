extends Node

var slots: Array[Slot] = []


func _ready() -> void:
	for slot: Slot in get_children():
		slots.append(slot)

	Bus.register_slots(slots)
