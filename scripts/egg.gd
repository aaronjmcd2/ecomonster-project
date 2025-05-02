extends Area2D

var claimed_by: Node = null  # ✅ Needed for SearchModule
var resource_type: String = "egg"
var count: int = 1  # Needed for pickup

func _ready():
	print("🥚 Egg spawned | count:", count)
