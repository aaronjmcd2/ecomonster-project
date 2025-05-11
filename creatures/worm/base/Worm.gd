# CoalWorm.gd
# Handles Coal Worm behavior using a modular module system
# Uses: WormSearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay, and custom modules

extends CharacterBody2D

# === Modules ===
@onready var init_module = preload("res://creatures/worm/base/WormInitModule.gd").new()
@onready var movement_module = preload("res://creatures/worm/base/WormMovementModule.gd").new()
@onready var search_module = preload("res://creatures/worm/base/WormSearchModule.gd").new()
@onready var consumption_module = preload("res://creatures/worm/base/WormConsumptionModule.gd").new()
@onready var conversion_module = preload("res://creatures/worm/base/WormConversionModule.gd").new()
@onready var stats_module = preload("res://creatures/worm/base/WormStatsModule.gd").new()
@onready var ui_module = preload("res://creatures/worm/base/WormUIModule.gd").new()

# === Existing dependencies ===
@onready var EfficiencyTracker := preload("res://systems/modules/helpers/EfficiencyTracker.gd").new()
@onready var coal_stat := preload("res://systems/modules/helpers/RollingStatTracker.gd").new()
@onready var tile_map_layer := get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay

# === Configuration ===
@export var search_radius: int = 40
@export var cooldown_time: float = 5.0
@export var speed: float = 400.0

# === State ===
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)
var efficiency_score: float = 0.0
var coal_tick_timer: float = 0.0
var target_data := {"type": "none", "target": null, "resource_type": ""}  # Enhanced target system
var cooldown_timer: float = 0.0
var is_idle := true
var move_vector := Vector2.ZERO

func _ready():
	init_module.initialize(self)

func _physics_process(delta: float) -> void:
	var was_efficient = false

	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		was_efficient = true
	else:
		if is_idle:
			target_data = search_module.find_target(self)
			if target_data.target:
				is_idle = false
		else:
			_move_toward_target(delta)
			was_efficient = true

	stats_module.update_efficiency(self, delta, was_efficient)
	stats_module.update_coal_tracking(self, delta)

func _move_toward_target(delta: float) -> void:
	if not target_data.target:
		_reset_worm()
		return
		
	# Get target position based on type
	var target_pos = Vector2.ZERO
	match target_data.type:
		"drop", "entity":
			if is_instance_valid(target_data.target):
				target_pos = target_data.target.global_position
		"tile":
			target_pos = target_data.target
	
	if target_pos == Vector2.ZERO:
		_reset_worm()
		return
	
	# Move toward target
	var direction = (target_pos - global_position).normalized()
	move_vector = direction * speed
	velocity = move_vector
	move_and_slide()
	
	# Check if reached target
	if global_position.distance_to(target_pos) < 5.0:
		_consume_target()

func _consume_target() -> void:
	if consumption_module.consume_target(self, target_data):
		# Convert tile based on resource type
		var target_pos = Vector2.ZERO
		if target_data.type == "tile":
			target_pos = target_data.target
		elif target_data.type == "entity" and is_instance_valid(target_data.target):
			target_pos = target_data.target.global_position
			
		conversion_module.convert_tile_beneath(self, tile_map_layer, target_data.resource_type, target_pos)
		stats_module.track_coal_produced(self, 1)
	
	_reset_worm()

func _reset_worm() -> void:
	is_idle = true
	cooldown_timer = cooldown_time
	target_data = {"type": "none", "target": null, "resource_type": ""}

func _input_event(viewport, event, shape_idx):
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)
