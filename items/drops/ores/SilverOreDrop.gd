# SilverOreDrop.gd
extends Area2D

var claimed_by: Node = null  # Add this line to fix the error
var count: int = 1
var resource_type: String = "silver"  # Make sure this is consistent

func _ready():
	add_to_group("silver_ore_drops")
	add_to_group("ore_drops")  # Add to general ore_drops group too
	print("🪙 Silver ore spawned | count:", count)
