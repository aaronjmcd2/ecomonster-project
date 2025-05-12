# AetherdriftOre.gd
extends Area2D

var claimed_by: Node = null
var resource_type: String = "aetherdrift"
var count: int = 1

func _ready():
	add_to_group("aetherdrift_ore_drops")
	add_to_group("ore_drops")
	print("✨ Spawned Aetherdrift Ore | count:", count)

func consume():
	queue_free()

func get_item_data() -> Dictionary:
	return {
		"name": "AetherdriftOre",
		"count": count,
		"icon": preload("res://items/drops/ores/AetherdriftOre.png"),
		"scene": preload("res://items/drops/ores/AetherdriftOre.tscn")
	}
