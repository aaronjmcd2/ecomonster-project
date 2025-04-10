# CoalWorm.gd
# Handles Coal Worm behavior: seeks iron ore drops, converts tiles beneath them to coal, idles when no target found.
# Uses: SearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay

@export var search_radius: int = 10
@export var cooldown_time: float = 5.0
@export var speed: float = 100.0

var efficiency_score: float = 0.0
var coal_log := []
const COAL_LOG_SIZE := 60  # 60 seconds
var coal_this_second: int = 0
var coal_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)
var target_drop = null
var cooldown_timer: float = 0.0
var is_idle := true
var move_vector := Vector2.ZERO

func _ready():
	# Set up collision and visual radius
	collision_layer = 2
	collision_mask = 1
	
	if search_display:
		search_display.set_radius(search_radius * 64)  # tile size conversion

func _physics_process(delta: float) -> void:
	var was_efficient = false

	# Handle cooldown
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		was_efficient = true
	else:
		if is_idle:
			target_drop = SearchModule.find_closest_ore_drop(global_position, search_radius * 64.0, self)
			if target_drop:
				is_idle = false
		else:
			_move_toward_target(delta)
			was_efficient = true  # Moving toward a target counts as efficient

	# Efficiency logic
	if was_efficient:
		efficiency_score += EFFICIENCY_RATE * delta
	else:
		efficiency_score -= EFFICIENCY_RATE * delta

	efficiency_score = clamp(efficiency_score, 0.0, 100.0)
	
	# Coal/min tracking (rolling 60s average)
	coal_timer += delta
	if coal_timer >= 1.0:
		coal_log.append(coal_this_second)
		if coal_log.size() > COAL_LOG_SIZE:
			coal_log.pop_front()

		coal_this_second = 0
		coal_timer = 0.0

func _move_toward_target(delta: float) -> void:
	# Navigate toward the current ore drop
	if target_drop == null or not is_instance_valid(target_drop):
		_reset_worm()
		return
	
	var target_pos = target_drop.global_position
	var direction = (target_pos - global_position).normalized()
	move_vector = direction * speed
	velocity = move_vector
	move_and_slide()
	
	if global_position.distance_to(target_pos) < 5.0:
		if target_drop and is_instance_valid(target_drop):
			_consume_ore_drop()
		else:
			_reset_worm()  # Target was removed before we got there

func _consume_ore_drop() -> void:
	# Consume the ore drop and convert the tile
	if target_drop and is_instance_valid(target_drop):
		_convert_tile_beneath()
		coal_this_second += 1
		target_drop.consume()
		
		if target_drop.claimed_by == self:
			target_drop.claimed_by = null
	
	_reset_worm()

func _convert_tile_beneath() -> void:
	# Use ConversionModule to change tile under worm
	var tile_pos = tile_map_layer.local_to_map(global_position)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		print("No tile exists under worm. Skipping conversion.")
		return
	
	ConversionModule.convert_tile(tile_pos)

func _reset_worm() -> void:
	# Set worm back to idle and clear claim
	is_idle = true
	cooldown_timer = cooldown_time
	
	if target_drop and is_instance_valid(target_drop) and target_drop.claimed_by == self:
		target_drop.claimed_by = null

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var info = {
			"name": "Coal Worm",
			"efficiency": int(efficiency_score),
			"stats": "Cooldown: %.1f seconds" % cooldown_time,
			"node": self
		}
		MonsterInfo.show_info(info, event.position)
		
func get_live_stats() -> Dictionary:
	var total = 0
	for amount in coal_log:
		total += amount
	var average_coal_per_min = float(total)
	var max_coal_per_min = 60.0 / cooldown_time

	return {
		"efficiency": int(efficiency_score),
		"stats": "Cooldown: %.1f seconds\nCoal/min: %.1f / %.1f" % [
			cooldown_time,
			average_coal_per_min,
			max_coal_per_min
		]
	}
