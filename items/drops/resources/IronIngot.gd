# IronIngot.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "iron_ingot"

func _ready():
	add_to_group("ingot_drops")
	print("🔩 Iron Ingot spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "IronIngot",
		"count": count,
		"icon": preload("res://items/drops/resources/IronIngot.png"),
		"scene": preload("res://items/drops/resources/IronIngot.tscn")
	}
