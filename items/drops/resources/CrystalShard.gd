# CrystalShard.gd
# Crystal shards from mining crystals
extends Area2D

var claimed_by = null
var resource_type := "crystal_shard"
var count: int = 1
var time_passed: float = 0.0

func _ready():
	add_to_group("crystal_shard_drops")
	print("✨ Crystal shard dropped")
	
	# Set initial appearance
	modulate = Color(0.7, 0.85, 1.0, 0.9)  # Blue crystal look

func _process(delta: float):
	# Simple sparkling effect
	time_passed += delta
	modulate.r = 0.7 + sin(time_passed * 4.0) * 0.1
	modulate.g = 0.85 + sin(time_passed * 3.5) * 0.1
	
	# Slight rotation
	rotation = sin(time_passed * 0.5) * 0.1

func get_item_data() -> Dictionary:
	return {
		"name": "CrystalShard",
		"count": count,
		"icon": preload("res://items/drops/resources/CrystalShard.png"),
		"scene": preload("res://items/drops/resources/CrystalShard.tscn")
	}
