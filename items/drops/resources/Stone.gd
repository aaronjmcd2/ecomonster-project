# Stone.gd
extends Area2D

var count: int = 1
var resource_type := "stone"

func _ready():
	print("🪨 Stone spawned | count:", count)
	add_to_group("stone_drops")

func get_item_data() -> Dictionary:
	return {
		"name": "Stone",
		"count": count,
		"icon": preload("res://items/drops/resources/Stone.png"),
		"scene": preload("res://items/drops/resources/Stone.tscn")
	}
