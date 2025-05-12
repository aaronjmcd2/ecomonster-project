# ReinforcedConcrete.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "reinforced_concrete"

func _ready():
	add_to_group("concrete_drops")
	print("🧱 Reinforced Concrete spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "ReinforcedConcrete",
		"count": count,
		"icon": preload("res://items/drops/resources/ReinforcedConcrete.png"),
		"scene": preload("res://items/drops/resources/ReinforcedConcrete.tscn")
	}
