# Spider.gd
# Handles Spider behavior using a modular system
# Converts Tempered Glass to Glass Silk and Soul to Soul Silk
# Uses: SearchModule, MonsterInfo, SearchRadiusDisplay, and custom modules

extends CharacterBody2D

# === Modules ===
@onready var init_module = preload("res://creatures/spider/base/SpiderInitModule.gd").new()
@onready var movement_module = preload("res://creatures/spider/base/SpiderMovementModule.gd").new()
@onready var search_module = preload("res://creatures/spider/base/SpiderSearchModule.gd").new()
@onready var consumption_module = preload("res://creatures/spider/base/SpiderConsumptionModule.gd").new()
@onready var conversion_module = preload("res://creatures/spider/base/SpiderConversionModule.gd").new()
@onready var stats_module = preload("res://creatures/spider/base/SpiderStatsModule.gd").new()
@onready var ui_module = preload("res://creatures/spider/base/SpiderUIModule.gd").new()

# === Existing dependencies ===
@onready var EfficiencyTracker := preload("res://systems/modules/helpers/EfficiencyTracker.gd").new()
@onready var silk_stat := preload("res://systems/modules/helpers/RollingStatTracker.gd").new()
@onready var search_display := $SearchRadiusDisplay

# === Configuration ===
@export var search_radius: int = 35
@export var conversion_cooldown: float = 3.0
@export var move_speed: float = 300.0

# === Drop Scenes ===
@export var glass_silk_scene: PackedScene = preload("res://items/drops/resources/GlassSilk.tscn")
@export var soul_silk_scene: PackedScene = preload("res://items/drops/resources/SoulSilk.tscn")

# === State ===
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)
var efficiency_score: float = 0.0
var silk_tick_timer: float = 0.0
var target_data := {"type": "none", "target": null, "resource_type": ""}
var is_busy := false
var cooldown_timer := 0.0
var wander_target: Vector2 = Vector2.ZERO

func _ready():
	init_module.initialize(self)

func _process(delta: float) -> void:
	var was_efficient = false

	if is_busy:
		_handle_cooldown(delta)
		was_efficient = true

		# Continue wandering while busy
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			wander_target = movement_module.pick_wander_target(global_position)
		movement_module.move_toward_wander_target(self, wander_target, move_speed)
	elif target_data.target:
		_move_toward_target(delta)
		was_efficient = true
	else:
		_search_for_target()

	stats_module.update_efficiency(self, delta, was_efficient)
	stats_module.update_silk_tracking(self, delta)

func _handle_cooldown(delta: float) -> void:
	cooldown_timer -= delta
	if cooldown_timer <= 0.0:
		is_busy = false

func _search_for_target() -> void:
	target_data = search_module.search_for_target(self)
	
	# If no target found, wander
	if target_data.type == "none":
		if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
			wander_target = movement_module.pick_wander_target(global_position)
		movement_module.move_toward_wander_target(self, wander_target, move_speed)

func _move_toward_target(delta: float) -> void:
	if movement_module.move_toward_target(self, target_data, move_speed):
		consumption_module.consume_resource(self, target_data)
		conversion_module.convert_resource(self, target_data)
		target_data = {"type": "none", "target": null, "resource_type": ""}
		is_busy = true
		cooldown_timer = conversion_cooldown

func _input_event(viewport, event, shape_idx) -> void:
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)
