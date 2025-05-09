# Melon.gd
extends Node2D

var claimed_by = null
var resource_type := "melon"
var is_harvestable := true  # Set to true for testing

func _ready():
	add_to_group("melons")

func harvest(consumed_by_worm: bool = false):
	if consumed_by_worm:
		queue_free()
