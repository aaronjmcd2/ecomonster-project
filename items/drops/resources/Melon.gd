# Melon.gd
extends Area2D  # Changed from Node2D to Area2D for pickup functionality

var claimed_by = null
var resource_type := "melon"
var is_harvestable := true  # Set to true for testing - later you can make this grow over time
var count := 1

func _ready():
	add_to_group("melons")
	add_to_group("melon_drops")  # Also add to drops group for player pickup

# Called by CoalWorm
func harvest(consumed_by_worm: bool = false):
	if consumed_by_worm:
		queue_free()

# Called by player pickup system
func get_item_data() -> Dictionary:
	return {
		"name": "Melon",
		"count": count,
		"icon": preload("res://items/drops/resources/Melon.png"),  # This is the inventory PNG
		"scene": preload("res://items/drops/resources/Melon.tscn")  # Reference to this same scene
	}
