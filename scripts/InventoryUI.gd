extends Control

@onready var inventory_grid := $MainContainer/InventoryGrid
@export var inventory_slot_scene: PackedScene

const NUM_COLUMNS := 8
const NUM_ROWS := 7

func _ready():
	# Populate inventory grid
	for i in range(NUM_COLUMNS * NUM_ROWS):
		var slot = inventory_slot_scene.instantiate()
		inventory_grid.add_child(slot)
