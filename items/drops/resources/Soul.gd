# Soul.gd
extends Area2D

var claimed_by = null
var resource_type := "soul"
var count: int = 1
var time_passed: float = 0.0

func _ready():
	add_to_group("soul_drops")
	print("👻 Soul released")
	
	# Set initial appearance
	modulate = Color(0.9, 0.95, 1.0, 0.7)  # Slight blue glow

func _process(delta: float):
	# Simple hover effect
	time_passed += delta
	position.y += sin(time_passed * 3.0) * 0.5
	
	# Simple pulsing glow
	modulate.a = 0.5 + sin(time_passed * 2.0) * 0.3

func get_item_data() -> Dictionary:
	return {
		"name": "Soul",
		"count": count,
		"icon": preload("res://items/drops/resources/Soul.png"),
		"scene": preload("res://items/drops/resources/Soul.tscn")
	}
