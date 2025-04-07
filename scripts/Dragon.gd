extends CharacterBody2D

@onready var tile_map_layer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay  # ← Added

@export var search_radius: int = 10
@export var max_lava_storage: int = 8
@export var ore_drop_count: int = 2
@export var move_speed: float = 50.0
@export var cooldown_time: float = 10
@export var ore_drop_scene: PackedScene

var target_tile: Vector2 = Vector2.ZERO
var lava_storage: int = 0
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false

var wander_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO

func _ready():
	if search_display:
		search_display.set_radius(search_radius * 32)  # ← Converts tile-based radius to pixels

func _process(delta):
	if is_cooling_down:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			_excrete_ore()
	else:
		_process_behavior()

func _process_behavior():
	var found_tile = SearchModule.find_nearest_tile(global_position, search_radius, 2) # 2 = Lava

	if found_tile != null:
		_move_toward(found_tile)
		if global_position.distance_to(found_tile) < 8:
			_consume_lava(found_tile)
	else:
		_wander()

func _consume_lava(tile_position: Vector2):
	var tile_pos = tile_map_layer.local_to_map(tile_position)
	var current_source = tile_map_layer.get_cell_source_id(tile_pos)

	if current_source == 2: # Lava
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0)) # Replace lava with soil
		lava_storage += 1

		if lava_storage >= max_lava_storage:
			is_cooling_down = true
			cooldown_timer = cooldown_time

func _excrete_ore():
	for i in range(ore_drop_count):
		var ore_instance = ore_drop_scene.instantiate()
		var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
		ore_instance.global_position = global_position + offset
		get_parent().add_child(ore_instance)

	lava_storage = 0
	is_cooling_down = false

func _wander():
	wander_timer -= get_process_delta_time()
	if wander_timer <= 0:
		var angle = randf() * PI * 2.0
		wander_target = global_position + Vector2(cos(angle), sin(angle)) * 32
		wander_timer = 2.0

	_move_toward(wander_target)

func _move_toward(target: Vector2):
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Dragon clicked!")

		var info = {
			"name": "Dragon",
			"efficiency": int(float(lava_storage) / float(max_lava_storage) * 100.0),
			"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec" % [lava_storage, max_lava_storage, ore_drop_count, cooldown_time],
			"node": self  # ← So the popup can access the radius node
		}

		MonsterInfo.show_info(info, event.position)

func get_live_stats() -> Dictionary:
	return {
		"efficiency": int(float(lava_storage) / float(max_lava_storage) * 100.0),
		"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec" % [
			lava_storage, max_lava_storage, ore_drop_count, cooldown_time
		]
	}
