# GlassDrop.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "glass"

func _ready():
	add_to_group("glass_drops")
	print("🪟 Glass produced | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "Glass",
		"count": count,
		"icon": preload("res://items/drops/resources/TemperedGlass.png"),
		"scene": preload("res://items/drops/resources/TemperedGlass.tscn")
	}
