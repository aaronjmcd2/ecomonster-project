# SilverIngot.gd
extends Area2D

var claimed_by: Node = null
var count: int =.1
var resource_type: String = "silver_ingot"
var dropped_in_water: bool = false

func _ready():
	add_to_group("ingot_drops")
	print("🥈 Silver Ingot spawned | count:", count)
	
	# Check if we're in water after a small delay
	get_tree().create_timer(0.5).timeout.connect(Callable(self, "_check_water"))

func _check_water():
	# Get the lake manager
	var lake_manager = get_node_or_null("/root/Main/LakeManager")
	if lake_manager:
		# Check if we're in a lake
		if lake_manager.check_silver_ingot_drop(global_position):
			dropped_in_water = true
			# Create fog effect
			print("🌫️ Silver ingot created fog in lake")
			# Remove the item
			queue_free()

func get_item_data() -> Dictionary:
	return {
		"name": "SilverIngot",
		"count": count,
		"icon": preload("res://items/drops/resources/SilverIngot.png"),
		"scene": preload("res://items/drops/resources/SilverIngot.tscn")
	}
