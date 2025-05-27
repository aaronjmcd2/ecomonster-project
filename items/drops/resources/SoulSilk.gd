# SoulSilk.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "soul_silk"

func _ready():
	add_to_group("soul_silk_drops")
	add_to_group("ore_drops")  # Add to general pickup group
	print("👻🕸️ Soul Silk produced | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "SoulSilk",
		"count": count,
		"icon": preload("res://items/drops/resources/SoulSilk.png"),
		"scene": preload("res://items/drops/resources/SoulSilk.tscn")
	}
