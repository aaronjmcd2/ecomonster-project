# Dragon.gd
# Handles Dragon behavior: searches for lava, converts to soil, stores lava, and excretes ore after cooldown.
# Uses: SearchModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var tile_map_layer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var anim_sprite := $AnimatedSprite2D  # Add this to the top with the other @onready vars

@export var search_radius: int = 60
@export var max_lava_storage: int = 8
@export var ore_drop_count: int = 2
@export var move_speed: float = 200.0
@export var cooldown_time: float = 10.0
@export var ore_drop_scene: PackedScene
@export var required_lava_to_excrete: int = 2

var target_tile = null
var lava_storage: int = 0
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false
var is_efficient: bool = false
var efficiency_score: float = 0.0
var ore_log := []
const ORE_LOG_SIZE := 60  # 60 seconds
var ore_this_second: int = 0
var ore_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

var wander_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO

func _ready():
	collision_layer = 2
	collision_mask = 1
	if search_display:
		search_display.set_radius(search_radius * 32)
	
	anim_sprite.play("idle_down")  # <--- play animation here

func _process(delta: float) -> void:
	is_efficient = false

	# Handle ore excretion cooldown
	if is_cooling_down:
		if cooldown_timer > 0.0:
			cooldown_timer -= delta
		else:
			_excrete_ore()
		is_efficient = true

	# === Behavior: Always try to consume lava if not full ===
	if lava_storage < max_lava_storage:
		if target_tile:
			_move_toward_target(delta)
		else:
			target_tile = SearchModule.find_nearest_tile(global_position, search_radius, 2)
			if not target_tile:
				# No lava found, wander instead
				if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
					_pick_wander_target()
				_move_toward_target(delta)
	else:
		# Full → wander until cooldown finishes
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			_pick_wander_target()
		_move_toward_target(delta)

	# Efficiency scoring
	if is_efficient:
		efficiency_score += EFFICIENCY_RATE * delta
	else:
		efficiency_score -= EFFICIENCY_RATE * delta

	efficiency_score = clamp(efficiency_score, 0.0, 100.0)
	
	# Ore/min tracking (rolling 60s average)
	ore_timer += delta
	if ore_timer >= 1.0:
		ore_log.append(ore_this_second)
		if ore_log.size() > ORE_LOG_SIZE:
			ore_log.pop_front()

		ore_this_second = 0
		ore_timer = 0.0




func _search_for_lava() -> void:
	target_tile = SearchModule.find_nearest_tile(global_position, search_radius, 2)  # 2 = lava
	if not target_tile:
		_pick_wander_target()

func _pick_wander_target() -> void:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * 32
	wander_target = global_position + offset
	target_tile = null

func _move_toward_target(delta: float) -> void:
	var target = target_tile if target_tile else wander_target
	var direction = (target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	if global_position.distance_to(target) < 5.0:
		if target_tile:
			_consume_lava()
		else:
			_pick_wander_target()

func _consume_lava() -> void:
	if not target_tile or lava_storage >= max_lava_storage:
		return

	var tile_pos = tile_map_layer.local_to_map(target_tile)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	if source_id == 2:  # lava
		tile_map_layer.set_cell(tile_pos, 3, Vector2i(0, 0))  # 3 = soil
		lava_storage += 1
		SearchModule.claimed_tile_positions.erase(target_tile)

		if lava_storage >= required_lava_to_excrete and not is_cooling_down:
			is_cooling_down = true
			cooldown_timer = cooldown_time

	target_tile = null

func _excrete_ore() -> void:
	for i in range(ore_drop_count):
		var ore_instance = ore_drop_scene.instantiate()
		var offset = Vector2(randi_range(-8, 8), randi_range(-8, 8))
		ore_instance.global_position = global_position + offset
		get_parent().add_child(ore_instance)

	# Track that one ore output event occurred (not per drop, just once per excretion)
	ore_this_second += 1

	lava_storage -= required_lava_to_excrete

	if lava_storage >= required_lava_to_excrete:
		# Instead of waiting until next _process() loop, restart here
		cooldown_timer = cooldown_time
	else:
		is_cooling_down = false
		cooldown_timer = 0.0  # Reset to prevent leftover decay


func _input_event(viewport, event, shape_idx) -> void:
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
	var total = 0
	for amount in ore_log:
		total += amount
	var average_ore_per_min = float(total)
	var max_ore_per_min = 60.0 / cooldown_time  # Max 1 excrete per cooldown

	return {
		"efficiency": int(efficiency_score),
		"stats": "Lava Stored: %d/%d\nOre Output: %d\nCooldown: %.1f sec\nOre/min: %.1f / %.1f" % [
			lava_storage,
			max_lava_storage,
			ore_drop_count,
			cooldown_time,
			average_ore_per_min,
			max_ore_per_min
		]
	}
