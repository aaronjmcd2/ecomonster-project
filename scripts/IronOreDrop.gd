extends Area2D

var claimed_by: Node = null

@export var ore_type: String = "iron"
@export var ore_value: int = 1
@export var count: int = 1  # New: how many are in this drop

func _ready():
	print("🌾 Spawned IronOreDrop | type:", ore_type, "| count:", count)
	# Optional: Add animation or effects when spawned
	pass

# FireElemental consumes this ore drop
func consume():
	queue_free()
