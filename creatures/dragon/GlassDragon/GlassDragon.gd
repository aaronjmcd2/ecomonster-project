# GlassDragon.gd
# Specialized dragon that consumes lava and ice to produce tempered glass.
# Evolved form of the base Dragon.
# 
# Behavior summary:
# - Searches for lava and ice to consume
# - Stores resources and produces tempered glass through excretion
# - Wanders when no resources are available
# - Shows stats when clicked

extends CharacterBody2D

# === Node References ===
@onready var tile_map_layer: TileMapLayer = get_node("/root/Main/TileMap/TileMapLayer")
@onready var search_display := $SearchRadiusDisplay
@onready var anim_sprite := $AnimatedSprite2D

# === Dragon Helper Modules ===
# Reuse most modules from the base Dragon
@onready var wander_module = preload("res://creatures/dragon/base/modules/DragonWanderModule.gd").new()
@onready var movement_module = preload("res://creatures/dragon/base/modules/DragonMovementModule.gd").new()
@onready var consumption_module = preload("res://creatures/dragon/base/modules/DragonConsumptionModule.gd").new()
@onready var search_module = preload("res://creatures/dragon/base/modules/DragonSearchModule.gd").new()
@onready var tile_module = preload("res://creatures/dragon/base/modules/DragonTileModule.gd").new()
@onready var animation_module = preload("res://creatures/dragon/base/modules/DragonAnimationModule.gd").new()
@onready var init_module = preload("res://creatures/dragon/base/modules/DragonInitModule.gd").new()

# Glass Dragon specific modules
@onready var glass_excretion_module = preload("res://creatures/dragon/glass/modules/GlassDragonExcretionModule.gd").new()
@onready var glass_stats_module = preload("res://creatures/dragon/glass/modules/GlassDragonStatsModule.gd").new()
@onready var glass_ui_module = preload("res://creatures/dragon/glass/modules/GlassDragonUIModule.gd").new()

# === Configuration Parameters ===
@export_group("Resource Production")
@export var required_lava_to_excrete: int = 1
@export var required_ice_to_excrete: int = 1
@export var glass_yield: int = 1

@export_group("Glass Production")
@export var glass_drop_scene: PackedScene
@export var tempered_glass_drop_scene: PackedScene = null

@export_group("Movement & Search")
@export var search_radius_tiles: int = 12
@export var search_radius_px: float = 3072.0
@export var move_speed: float = 200.0

@export_group("Resource Storage")
@export var max_total_storage: int = 8
@export var max_lava_storage: int = 8
@export var cooldown_time: float = 10.0

# === State Variables ===
# Storage
var lava_storage: int = 0
var ice_storage: int = 0

# Targets
var target_tile = null
var wander_target: Vector2 = Vector2.ZERO

# Excretion
var cooldown_timer: float = 0.0
var is_cooling_down: bool = false

# Efficiency tracking
var is_efficient: bool = false
var efficiency_score: float = 0.0
var glass_log := []
const GLASS_LOG_SIZE := 60  # 60 seconds
var glass_this_second: int = 0
var glass_timer: float = 0.0
const EFFICIENCY_RATE := 100.0 / (5 * 60.0)

# === Core Functions ===
func _ready():
	# Use init module to handle all initialization
	init_module.initialize(self)
	
	# Make sure we're in the monsters group
	if not is_in_group("monsters"):
		add_to_group("monsters")

func _process(delta: float) -> void:
	is_efficient = false

	# === Phase 1: Handle excretion cooldown ===
	if is_cooling_down:
		_handle_excretion(delta)
		is_efficient = true
	
	# === Phase 2: Resource gathering or wandering behavior ===
	if _can_gather_more_resources():
		_execute_gathering_behavior(delta)
	else:
		_execute_wandering_behavior(delta)
	
	# === Phase 3: Ensure we have targets if needed ===
	if not target_tile:
		search_module.search_for_resources(self)

	# === Phase 4: Update stats ===
	glass_stats_module.update_efficiency(self, delta, is_efficient)
	glass_stats_module.update_glass_log(self, delta)

func _input_event(viewport, event, shape_idx) -> void:
	glass_ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	return glass_stats_module.get_live_stats(self)

func get_total_storage() -> int:
	return lava_storage + ice_storage

# === Helper Functions ===
func _handle_excretion(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	else:
		glass_excretion_module.excrete_glass(self)
		animation_module.play_excretion_animation(self)

func _can_gather_more_resources() -> bool:
	return lava_storage < max_lava_storage or ice_storage < max_lava_storage

func _execute_gathering_behavior(delta: float) -> void:
	if target_tile:
		var move_result = movement_module.move_toward_target(delta, self, target_tile, null, wander_target, move_speed)
		animation_module.update_animation(self)

		if move_result == "tile":
			consumption_module.consume_tile(self, target_tile, tile_map_layer)
		elif move_result == "wander":
			wander_target = wander_module.pick_wander_target(global_position)
			target_tile = null
	else:
		# Use search module for comprehensive resource search
		search_module.search_for_resources(self)

		if not target_tile:
			# No resources found, ensure we have a wander target
			search_module.ensure_wander_target(self)
			
			var move_result = movement_module.move_toward_target(delta, self, target_tile, null, wander_target, move_speed)
			animation_module.update_animation(self)

			if move_result == "tile":
				consumption_module.consume_tile(self, target_tile, tile_map_layer)
			elif move_result == "wander":
				wander_target = wander_module.pick_wander_target(global_position)
				target_tile = null

func _execute_wandering_behavior(delta: float) -> void:
	# Storage full → wander
	search_module.ensure_wander_target(self)
	
	var move_result = movement_module.move_toward_target(delta, self, target_tile, null, wander_target, move_speed)
	animation_module.update_animation(self)

	if move_result == "tile":
		consumption_module.consume_tile(self, target_tile, tile_map_layer)
	elif move_result == "wander":
		wander_target = wander_module.pick_wander_target(global_position)
		target_tile = null
