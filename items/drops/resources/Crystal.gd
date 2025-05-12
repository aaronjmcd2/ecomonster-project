# Crystal.gd
extends Area2D

var claimed_by = null
var resource_type := "crystal"
var count: int = 1  # For inventory compatibility

func _ready():
	add_to_group("crystals")
	add_to_group("crystal_drops")  # For player pickup
	print("💎 Crystal formed")

# This is the function that elementals likely call to convert
func consume():
	print("🧊 Crystal being consumed")
	queue_free()

# Get item data for inventory
func get_item_data() -> Dictionary:
	return {
		"name": "Crystal",
		"count": count,
		"icon": preload("res://items/drops/resources/Crystal.png"),
		"scene": preload("res://items/drops/resources/Crystal.tscn")
	}

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
