extends Area2D

var claimed_by: Node = null
var resource_type: String = "coal"

@export var ore_type: String = "coal"
@export var ore_value: int = 1
@export var count: int = 1

func _ready():
	print("🌑 Spawned CoalDrop | type:", ore_type, "| count:", count)
	add_to_group("world_items")

func consume():
	queue_free()

func get_item_data() -> Dictionary:
	return {
		"name": "Coal",
		"count": count,
		"icon": preload("res://sprites/coal_drop.png"),
		"scene": preload("res://items/drops/ores/CoalDrop.tscn")
	}