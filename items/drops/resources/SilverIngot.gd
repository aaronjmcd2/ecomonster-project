# SilverIngot.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "silver_ingot"

func _ready():
	add_to_group("ingot_drops")
	print("🥈 Silver Ingot spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "SilverIngot",
		"count": count,
		"icon": preload("res://items/drops/resources/SilverIngot.png"),
		"scene": preload("res://items/drops/resources/SilverIngot.tscn")
	}
