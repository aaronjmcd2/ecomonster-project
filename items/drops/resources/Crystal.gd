# Crystal.gd
extends Node2D

var claimed_by = null
var resource_type := "crystal"

func _ready():
	add_to_group("crystals")

func consume():
	queue_free()

# Add mining functionality
func mine() -> void:
	# Spawn 2-4 crystal shards
	var shard_count = randi_range(2, 4)
	
	for i in range(shard_count):
		var shard = preload("res://items/drops/resources/CrystalShard.tscn").instantiate()
		var offset = Vector2(randi_range(-20, 20), randi_range(-20, 20))
		shard.global_position = global_position + offset
		get_parent().add_child(shard)
		
		queue_free()
