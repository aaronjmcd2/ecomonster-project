# CoalWorm.gd
# Handles Coal Worm behavior: seeks iron ore drops, converts tiles beneath them to coal, idles when no target found.
# Uses: WormSearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay

extends CharacterBody2D

@onready var EfficiencyTracker := preload("res://scripts/MonsterHelperScripts/EfficiencyTracker.gd").new()
@onready var coal_stat := preload("res://scripts/MonsterHelperScripts/RollingStatTracker.gd").new()
@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay

@export var search_radius: int = 40
@export var cooldown_time: float = 5.0
@export var speed: float = 400.0

const EFFICIENCY_RATE := 100.0 / (5 * 60.0)
var efficiency_score: float = 0.0
var coal_tick_timer: float = 0.0
var target_drop = null
var cooldown_timer: float = 0.0
var is_idle := true
var move_vector := Vector2.ZERO

func _ready():
	collision_layer = 2
	collision_mask = 1
	add_child(coal_stat)

	if search_display:
		search_display.set_radius(search_radius * 64)  # tile size conversion

func _physics_process(delta: float) -> void:
	var was_efficient = false

	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		was_efficient = true
	else:
		if is_idle:
			target_drop = WormSearchModule.find_closest_iron_drop(global_position, search_radius * 64.0, self)
			if target_drop:
				is_idle = false
		else:
			_move_toward_target(delta)
			was_efficient = true

	efficiency_score = EfficiencyTracker.update(delta, was_efficient, efficiency_score, EFFICIENCY_RATE)

	coal_tick_timer += delta
	if coal_tick_timer >= 1.0:
		coal_stat.tick()
		coal_tick_timer = 0.0

func _move_toward_target(delta: float) -> void:
	if target_drop == null or not is_instance_valid(target_drop):
		_reset_worm()
		return

	var target_pos = target_drop.global_position
	var direction = (target_pos - global_position).normalized()
	move_vector = direction * speed
	velocity = move_vector
	move_and_slide()

	if global_position.distance_to(target_pos) < 5.0:
		if is_instance_valid(target_drop):
			_consume_ore_drop()
		else:
			_reset_worm()

func _consume_ore_drop() -> void:
	if not target_drop or not is_instance_valid(target_drop):
		_reset_worm()
		return

	if not target_drop.has_method("consume"):
		print("🐛 Skipping drop without consume() method:", target_drop.name)
		_reset_worm()
		return

	print("🐛 Coal Worm consuming:", target_drop.name)
	_convert_tile_beneath()
	coal_stat.add(1)
	target_drop.consume()

	if target_drop.claimed_by == self:
		target_drop.claimed_by = null


	_reset_worm()

func _convert_tile_beneath() -> void:
	var tile_pos = tile_map_layer.local_to_map(global_position)
	var source_id = tile_map_layer.get_cell_source_id(tile_pos)

	if source_id == -1:
		print("No tile exists under worm. Skipping conversion.")
		return

	ConversionModule.convert_tile(tile_pos)

func _reset_worm() -> void:
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
	var average_coal_per_min = coal_stat.get_average()
	var max_coal_per_min = 60.0 / cooldown_time
	return {
		"efficiency": int(efficiency_score),
		"stats": "Cooldown: %.1f seconds\nCoal/min: %.1f / %.1f" % [
			cooldown_time,
			average_coal_per_min,
			max_coal_per_min
		]
	}
