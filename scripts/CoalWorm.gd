extends CharacterBody2D

@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")

@export var search_radius: int = 100
@export var cooldown_time: float = 2.0
@export var speed: float = 100.0

var target_drop: Node2D = null
var cooldown_timer: float = 0.0
var is_idle := true

var move_vector := Vector2.ZERO

func _ready():
	collision_layer = 2
	collision_mask = 1  # Doesn't collide with player

func _physics_process(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
		return

	if is_idle:
		target_drop = find_closest_ore_drop()
		if target_drop:
			is_idle = false
	else:
		move_to_target(delta)

func move_to_target(delta):
	var target_pos = target_drop.global_position
	var direction = (target_pos - global_position).normalized()
	move_vector = direction * speed
	velocity = move_vector
	move_and_slide()

	if global_position.distance_to(target_pos) < 5.0:
		consume_ore_drop()

func find_closest_ore_drop() -> Node2D:
	var closest_drop = null
	var closest_dist = search_radius * 64  # Max distance in pixels

	for drop in get_tree().get_nodes_in_group("ore_drops"):
		var dist = global_position.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	return closest_drop

func consume_ore_drop():
	if target_drop:
		convert_tile_beneath()
		target_drop.consume()
		reset_worm()

func convert_tile_beneath():
	var tile_pos = tile_map_layer.local_to_map(global_position)

	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	if source_id == -1:
		print("No tile exists under worm. Skipping conversion.")
		return

	ConversionModule.convert_tile(tile_pos)

func reset_worm():
	is_idle = true
	cooldown_timer = cooldown_time
