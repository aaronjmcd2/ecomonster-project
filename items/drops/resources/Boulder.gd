# Boulder.gd
extends Area2D

var claimed_by = null
var resource_type := "boulder"

func _ready():
	add_to_group("boulders")
	# Ensure boulder is on collision layer 1 so pickaxe can detect it
	collision_layer = 1

func consume():
	queue_free()

func break_apart():
	# This method will be called by the pickaxe when it hits the boulder
	# The actual stone spawning is handled by the pickaxe itself
	print("🪨 Boulder is being broken apart!")
	queue_free()
