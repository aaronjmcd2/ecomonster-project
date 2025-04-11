extends Area2D

var count := 1
var claimed_by = null  # Still needed to avoid crashes, just in case

func _ready():
	add_to_group("world_items")
	$AnimationPlayer.play("idle")


func get_item_data() -> Dictionary:
	return {
		"name": "Sword",
		"type": "weapon",
		"count": count,
		"icon": preload("res://sprites/Items/Weapons/Sword.png"),
		"scene": preload("res://scenes/Items/Weapons/SwordDrop.tscn")
	}
