extends Area2D

var count: int = 1  # Required to match the pickup logic

func _ready():
	print("🥚 Egg spawned | count:", count)
