extends Node2D

@export var ore_type: String = "iron"
@export var ore_value: int = 1

func _ready():
	# Optional: Add animation or effects when spawned
	pass

# FireElemental consumes this ore drop
func consume():
	queue_free()
