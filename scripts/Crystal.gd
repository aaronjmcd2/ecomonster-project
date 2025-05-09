# Crystal.gd
extends Node2D

var claimed_by = null
var resource_type := "crystal"

func _ready():
	add_to_group("crystals")

func consume():
	queue_free()
