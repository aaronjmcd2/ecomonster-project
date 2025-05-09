# CoalWorm.gd
# Handles Coal Worm behavior using a modular module system
# Uses: WormSearchModule, ConversionModule, MonsterInfo, SearchRadiusDisplay, and custom modules

extends CharacterBody2D

# === Modules ===
@onready var init_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormInitModule.gd").new()
@onready var movement_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormMovementModule.gd").new()
@onready var search_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormSearchModule.gd").new()
@onready var consumption_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormConsumptionModule.gd").new()
@onready var conversion_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormConversionModule.gd").new()
@onready var stats_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormStatsModule.gd").new()
@onready var ui_module = preload("res://modules/MonsterHelperModules/WormHelperModules/CoalWormUIModule.gd").new()

# === Existing dependencies ===
@onready var EfficiencyTracker := preload("res://scripts/MonsterHelperScripts/EfficiencyTracker.gd").new()
@onready var coal_stat := preload("res://scripts/MonsterHelperScripts/RollingStatTracker.gd").new()
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
var target_drop = null
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
			target_drop = search_module.find_target_drop(self)
			if target_drop:
				is_idle = false
		else:
			_move_toward_target(delta)
			was_efficient = true

	stats_module.update_efficiency(self, delta, was_efficient)
	stats_module.update_coal_tracking(self, delta)

func _move_toward_target(delta: float) -> void:
	if movement_module.move_toward_target(self, target_drop, speed, delta):
		if is_instance_valid(target_drop):
			_consume_ore_drop()
		else:
			_reset_worm()

func _consume_ore_drop() -> void:
	consumption_module.consume_ore_drop(self, target_drop)
	conversion_module.convert_tile_beneath(self, tile_map_layer)
	stats_module.track_coal_produced(self, 1)
	_reset_worm()

func _reset_worm() -> void:
	is_idle = true
	cooldown_timer = cooldown_time

	if target_drop and is_instance_valid(target_drop) and target_drop.claimed_by == self:
		target_drop.claimed_by = null

func _input_event(viewport, event, shape_idx):
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)
