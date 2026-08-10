extends Node

var slots: Array[Slot] = []


func register_slots(new_slots: Array[Slot]) -> void:
	slots = new_slots


func get_available_slots() -> Array[Slot]:
	var available: Array[Slot] = []

	for slot: Slot in slots:
		if not slot.is_filled and not slot.is_reserved:
			available.append(slot)

	return available


func claim_first_available_slot() -> Slot:
	for slot: Slot in slots:
		if not slot.is_filled and not slot.is_reserved:
			slot.is_reserved = true
			return slot

	return null


func release_slot(slot: Slot) -> void:
	if slot == null:
		return

	if not slot.is_filled:
		slot.is_reserved = false
