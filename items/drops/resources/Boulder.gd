# Boulder.gd
extends Node2D

var claimed_by = null
var resource_type := "boulder"

func _ready():
	add_to_group("boulders")

func consume():
	queue_free()
