extends CharacterBody2D

@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay

@export var search_radius: int = 10
@export var cooldown_time: float = 5
@export var speed: float = 100.0

var target_drop: Node2D = null
var cooldown_timer: float = 0.0
var is_idle := true

var move_vector := Vector2.ZERO

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Coal Worm clicked!")

		var info = {
			"name": "Coal Worm",
			"efficiency": 75,
			"stats": "Converted 12 ores\nCooldown: %.1f seconds" % cooldown_time,
			"node": self  # This is important! It allows the popup to control our radius display
		}

		MonsterInfo.show_info(info, event.position)

func _ready():
	collision_layer = 2
	collision_mask = 1

	# Set the visual radius size in pixels
	if search_display:
		search_display.set_radius(search_radius * 64)  # tile size conversion

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
	if target_drop == null or not is_instance_valid(target_drop):
		reset_worm()
		return
	var target_pos = target_drop.global_position
	var direction = (target_pos - global_position).normalized()
	move_vector = direction * speed
	velocity = move_vector
	move_and_slide()

	if global_position.distance_to(target_pos) < 5.0:
		consume_ore_drop()

func find_closest_ore_drop() -> Node2D:
	var closest_drop = null
	var closest_dist = search_radius * 64

	for drop in get_tree().get_nodes_in_group("ore_drops"):
		var dist = global_position.distance_to(drop.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_drop = drop

	return closest_drop

func consume_ore_drop():
	if target_drop and is_instance_valid(target_drop):
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
