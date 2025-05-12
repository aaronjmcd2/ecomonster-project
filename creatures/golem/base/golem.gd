# Golem.gd
# Orchestrates Golem behavior through specialized modules.
# Handles state management and module coordination.
# 
# Behavior summary:
# - Searches for lava and other resources (stone, iron, etc.)
# - Combines resources to produce various ingots and concrete
# - Wanders when no resources are available
# - Shows stats when clicked

extends CharacterBody2D

# === Node References ===
@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var sprite := $Sprite2D if has_node("Sprite2D") else null
@onready var anim_sprite := $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

# === Golem Helper Modules ===
@onready var init_module = preload("res://creatures/golem/base/GolemInitModule.gd").new()
@onready var movement_module = preload("res://creatures/golem/base/GolemMovementModule.gd").new()
@onready var search_module = preload("res://creatures/golem/base/GolemSearchModule.gd").new()
@onready var consumption_module = preload("res://creatures/golem/base/GolemConsumptionModule.gd").new()
@onready var production_module = preload("res://creatures/golem/base/GolemProductionModule.gd").new()
@onready var stats_module = preload("res://creatures/golem/base/GolemStatsModule.gd").new()
@onready var ui_module = preload("res://creatures/golem/base/GolemUIModule.gd").new()

# === Configuration Parameters ===
@export_group("Resource Production")
@export var reinforced_concrete_yield: int = 2
@export var iron_ingot_yield: int = 2
@export var silver_ingot_yield: int = 2
@export var gold_ingot_yield: int = 2
@export var aetherdrift_ingot_yield: int = 1
@export var lava_required: int = 1
@export var material_required: int = 1

@export_group("Drop Scenes")
@export var reinforced_concrete_scene: PackedScene
@export var iron_ingot_scene: PackedScene
@export var silver_ingot_scene: PackedScene
@export var gold_ingot_scene: PackedScene
@export var aetherdrift_ingot_scene: PackedScene

@export_group("Movement & Search")
@export var search_radius_tiles: int = 12
@export var search_radius_px: float = 3072.0
@export var move_speed: float = 180.0

@export_group("Resource Storage")
@export var max_lava_storage: int = 4  # Maximum lava storage capacity
@export var max_material_storage: int = 4  # Maximum material storage capacity
@export var cooldown_time: float = 10.0

# === State Variables ===
# Storage
var lava_storage: int = 0
var stone_storage: int = 0
var iron_ore_storage: int = 0
var silver_ore_storage: int = 0
var gold_ore_storage: int = 0
var aetherdrift_ore_storage: int = 0

# Targets
var target_lava = null
var target_material = null
var material_type: String = ""
var wander_target: Vector2 = Vector2.ZERO

# Production
var production_type: String = ""
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false

# Efficiency tracking
var is_efficient: bool = false
var efficiency_score: float = 0.0
var ingot_log := []
const INGOT_LOG_SIZE := 60  # 60 seconds
var ingots_this_second: int = 0
var ingot_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

# === Core Functions ===
func _ready():
	# Use init module to handle all initialization
	init_module.initialize(self)

func _process(delta: float) -> void:
	is_efficient = false

	# === Phase 1: Handle production cooldown ===
	if is_cooling_down:
		_handle_production(delta)
		is_efficient = true
	
	# === Phase 2: Resource gathering or wandering behavior ===
	if not (is_lava_storage_full() and is_material_storage_full()):
		_execute_gathering_behavior(delta)
	else:
		_execute_wandering_behavior(delta)
	
	# === Phase 3: Ensure we have targets if needed ===
	if (not target_lava or not target_material):
		search_module.search_for_resources(self)

	# === Phase 4: Update stats ===
	stats_module.update_efficiency(self, delta, is_efficient)
	stats_module.update_ingot_log(self, delta)

func _input_event(viewport, event, shape_idx) -> void:
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return stats_module.get_live_stats(self)

func get_total_material_storage() -> int:
	return stone_storage + iron_ore_storage + silver_ore_storage + gold_ore_storage + aetherdrift_ore_storage

func get_total_storage() -> int:
	return lava_storage + get_total_material_storage()

func is_lava_storage_full() -> bool:
	return lava_storage >= max_lava_storage

func is_material_storage_full() -> bool:
	return get_total_material_storage() >= max_material_storage

# === Helper Functions ===
func _handle_production(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	else:
		production_module.produce_output(self)

func _execute_gathering_behavior(delta: float) -> void:
	# First prioritize gathering lava if needed
	if not is_lava_storage_full() and target_lava:
		var move_result = movement_module.move_toward_target(delta, self, target_lava, "lava", move_speed)
		
		if move_result == "reached":
			consumption_module.consume_lava(self, target_lava, tile_map_layer)
			target_lava = null
	
	# Then gather other materials if needed
	elif not is_material_storage_full() and target_material:
		var move_result = movement_module.move_toward_target(delta, self, target_material, material_type, move_speed)
		
		if move_result == "reached":
			consumption_module.consume_material(self, target_material, material_type)
			target_material = null
	
	# If no targets, search for them
	else:
		search_module.search_for_resources(self)
		
		# If still no targets, wander
		if not target_lava and not target_material:
			_execute_wandering_behavior(delta)

func _execute_wandering_behavior(delta: float) -> void:
	if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 5.0:
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * 64.0
		wander_target = global_position + offset
	
	var move_result = movement_module.move_toward_position(delta, self, wander_target, move_speed)
	
	if move_result == "reached":
		wander_target = Vector2.ZERO
