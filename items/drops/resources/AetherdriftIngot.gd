# AetherdriftIngot.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "aetherdrift_ingot"

func _ready():
	add_to_group("ingot_drops")
	print("⚛️ Aetherdrift Ingot spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "AetherdriftIngot",
		"count": count,
		"icon": preload("res://items/drops/resources/AetherdriftIngot.png"),
		"scene": preload("res://items/drops/resources/AetherdriftIngot.tscn")
	}
