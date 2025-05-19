# Mana.gd (simplified without animations)
extends Area2D

var count := 1
var claimed_by = null  # Needed to avoid crashes with monster claiming system
var resource_type = "mana"  # For compatibility with existing systems

func _ready():
	add_to_group("world_items")
	add_to_group("mana_drops")

func get_item_data() -> Dictionary:
	return {
		"name": "Mana",
		"type": "resource",
		"count": count,
		"icon": preload("res://items/drops/resources/Mana.png"),
		"scene": preload("res://items/drops/resources/Mana.tscn")
	}

# Called when monster consumes this drop
func consume() -> void:
	queue_free()
