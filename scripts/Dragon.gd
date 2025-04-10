# Dragon.gd
# Handles Dragon behavior: consumes lava, converts it to soil, stores lava to excrete ore drops, tracks efficiency.
# Uses: SearchModule, ConversionModule (optional), MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var tile_map_layer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay

@export var search_radius: int = 10
@export var max_lava_storage: int = 8
@export var ore_drop_count: int = 2
@export var move_speed: float = 50.0
@export var cooldown_time: float = 10.0
@export var ore_drop_scene: PackedScene
@export var required_lava_to_excrete: int = 2

var efficiency_score: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

var target_tile = Vector2.ZERO
var lava_storage: int = 0
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false
var is_efficient: bool = false

var wander_timer: float = 0.0
var wander_target = Vector2.ZERO

func _ready():
	# Set the visual radius size in pixels
	if search_display:
		search_display.set_radius(search_radius * 32)

func _process(delta: float) -> void:
	var was_efficient = is_efficient
	is_efficient = false

	_process_behavior()

	# Cooldown phase = excretion prep
	if is_cooling_down:
		is_efficient = true
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			_excrete_ore()
			is_cooling_down = false

	# Update efficiency tracker
	if is_efficient:
		efficiency_score += EFFICIENCY_RATE * delta
	else:
		efficiency_score -= EFFICIENCY_RATE * delta

	efficiency_score = clamp(efficiency_score, 0.0, 100.0)

func _process_behavior() -> void:
	# Look for lava tiles to consume
	var found_tile = SearchModule.find_nearest_tile(global_position, search_radius, 2)  # 2 = Lava

	if found_tile != null:
		_move_toward_target(found_tile)

		if global_position.distance_to(found_tile) < 8.0:
			_consume_lava(found_tile)

		is_efficient = true
	else:
		_wander()

func _consume_lava(tile_position: Vector2) -> void:
	# Converts lava tile to soil and stores lava
	if lava_storage >= max_lava_storage:
		return

	var tile_pos = tile_map_layer.local_to_map(tile_position)
	var current_source = tile_map_layer.get_cell_source_id(tile_pos)

	if current_source == 2:  # Lava
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # 3 = Soil
		# Optional: Use ConversionModule.replace_tile(tile_position, 2, 3)
		lava_storage += 1

		if lava_storage >= required_lava_to_excrete:
			is_cooling_down = true
			cooldown_timer = cooldown_time

func _excrete_ore() -> void:
	# Spawns ore drop(s) around the dragon
	for i in range(ore_drop_count):
		var ore_instance = ore_drop_scene.instantiate()
		var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
		ore_instance.global_position = global_position + offset
		get_parent().add_child(ore_instance)

	lava_storage = 0
	is_cooling_down = false

func _wander() -> void:
	# Picks a random target every few seconds and moves toward it
	wander_timer -= get_process_delta_time()
	if wander_timer <= 0.0:
		var angle = randf() * PI * 2.0
		wander_target = global_position + Vector2(cos(angle), sin(angle)) * 32
		wander_timer = 2.0
	
	_move_toward_target(wander_target)

func _move_toward_target(target: Vector2) -> void:
	# Movement function toward a given position
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func _input_event(viewport, event, shape_idx):
	# Show popup info when clicked
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Dragon",
			"efficiency": int(float(lava_storage) / float(max_lava_storage) * 100.0),
			"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec" % [
				lava_storage, max_lava_storage, ore_drop_count, cooldown_time
			],
			"node": self
		}
		MonsterInfo.show_info(info, event.position)

func get_live_stats() -> Dictionary:
	# Called externally for live data
	return {
		"efficiency": int(efficiency_score),
		"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec" % [
			lava_storage, max_lava_storage, ore_drop_count, cooldown_time
		]
	}
