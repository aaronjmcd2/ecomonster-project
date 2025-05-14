# TemperedGlass.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "tempered_glass"

func _ready():
	add_to_group("glass_drops")  # Add to a group the player pickup module will recognize
	print("🪟 Tempered Glass produced | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "TemperedGlass",
		"count": count,
		"icon": preload("res://items/drops/resources/TemperedGlass.png"),
		"scene": preload("res://items/drops/resources/TemperedGlass.tscn")
	}
