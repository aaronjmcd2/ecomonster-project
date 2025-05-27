# GlassSilk.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "glass_silk"

func _ready():
	add_to_group("glass_silk_drops")
	add_to_group("ore_drops")  # Add to general pickup group
	print("🕸️ Glass Silk produced | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "GlassSilk",
		"count": count,
		"icon": preload("res://items/drops/resources/GlassSilk.png"),
		"scene": preload("res://items/drops/resources/GlassSilk.tscn")
	}
