# GoldIngot.gd
extends Area2D

var claimed_by: Node = null
var count: int = 1
var resource_type: String = "gold_ingot"

func _ready():
	add_to_group("ingot_drops")
	print("🥇 Gold Ingot spawned | count:", count)

func get_item_data() -> Dictionary:
	return {
		"name": "GoldIngot",
		"count": count,
		"icon": preload("res://items/drops/resources/GoldIngot.png"),
		"scene": preload("res://items/drops/resources/GoldIngot.tscn")
	}
