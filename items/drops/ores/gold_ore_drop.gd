# gold_ore_drop.gd
extends Area2D

var claimed_by: Node = null  # Add this line to fix similar errors
var count: int = 1
var resource_type: String = "gold"

func _ready():
	add_to_group("gold_ore_drops")
	add_to_group("ore_drops")  # Add to general ore_drops group too
	print("🪙 Gold ore spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "GoldOre",
		"count": count,
		"icon": preload("res://items/drops/ores/GoldOre.png"),
		"scene": preload("res://items/drops/ores/GoldOreDrop.tscn")
	}
