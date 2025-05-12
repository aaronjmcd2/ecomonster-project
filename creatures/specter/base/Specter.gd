# Specter.gd
# Handles Specter behavior - born from foggy lakes, turns to crystal over time
extends CharacterBody2D

# === Node References ===
@onready var sprite := $Sprite2D
@onready var life_timer := $LifeTimer

# === Specter Helper Modules ===
@onready var movement_module = preload("res://creatures/specter/base/SpecterMovementModule.gd").new()
@onready var ui_module = preload("res://creatures/specter/base/SpecterUIModule.gd").new()

# === Configuration Parameters ===
@export_group("Movement & Search")
@export var hover_speed: float = 150.0
@export var wander_radius: float = 2000.0

@export_group("Life Cycle")
@export var life_duration: float = 120.0  # 2 minutes before turning to crystal
@export var crystal_scene: PackedScene
@export var soul_scene: PackedScene

# === State Variables ===
var birth_lake = null  # Reference to lake that spawned this specter
var life_remaining: float = 0.0
var wander_target: Vector2 = Vector2.ZERO
var returning_to_lake: bool = false
var health: int = 3  # Hit points
var time_passed: float = 0.0  # For simple visual effects

# === Core Functions ===
func _ready():
	# Set up properties
	sprite.modulate = Color(0.8, 0.9, 1.0, 0.7)  # Ghostly appearance
	
	# Set up collision
	collision_layer = 2
	collision_mask = 1
	
	# Start life timer
	life_timer.wait_time = life_duration
	life_timer.start()
	life_remaining = life_duration

func _process(delta: float) -> void:
	# Update life remaining
	life_remaining = life_timer.time_left
	
	# Simple ghostly effect - pulsing transparency
	time_passed += delta
	sprite.modulate.a = 0.5 + sin(time_passed * 2.0) * 0.2
	
	# Make specter more transparent as it nears crystallization
	var life_percent = life_remaining / life_duration
	if life_percent < 0.3:
		sprite.modulate = Color(0.5, 0.7, 0.9, sprite.modulate.a)  # More blue/cyan as it crystallizes
	
	# Execute floating/wandering behavior
	_execute_wandering_behavior(delta)

func _input_event(viewport, event, shape_idx) -> void:
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	var life_percent = int((life_remaining / life_duration) * 100)
	
	var stats_text = "Life: %d%%\n" % life_percent
	stats_text += "Health: %d / 3\n" % health
	
	if life_percent < 20:
		stats_text += "Status: Crystallizing"
	else:
		stats_text += "Status: Roaming"
	
	return {
		"name": "Specter",
		"efficiency": life_percent,
		"stats": stats_text
	}

# Called when hit by player weapon
func take_damage(amount: int) -> void:
	health -= amount
	
	# Visual feedback
	sprite.modulate = Color(1.0, 0.5, 0.5, sprite.modulate.a)  # Flash red
	
	if health <= 0:
		_drop_soul()
		queue_free()

# === Helper Functions ===
func _execute_wandering_behavior(delta: float) -> void:
	if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 50.0:
		# Pick new wander target
		var angle = randf() * TAU
		var distance = randf_range(500.0, wander_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		if birth_lake and returning_to_lake:
			# Return toward lake center
			var lake_center = Vector2.ZERO
			for tile in birth_lake.tiles:
				lake_center += Vector2(tile.x * 32, tile.y * 32)  # Convert tiles to world pos
			
			if birth_lake.tiles.size() > 0:
				lake_center /= birth_lake.tiles.size()
				wander_target = lake_center
				returning_to_lake = false
		else:
			# Normal wandering
			wander_target = global_position + offset
	
	# Move toward target with some vertical bobbing
	var move_result = movement_module.float_toward_target(delta, self, wander_target, hover_speed)

func _on_life_timer_timeout() -> void:
	# Turn into crystal
	var crystal = crystal_scene.instantiate()
	crystal.global_position = global_position
	get_parent().add_child(crystal)
	queue_free()

func _drop_soul() -> void:
	var soul = soul_scene.instantiate()
	soul.global_position = global_position
	get_parent().add_child(soul)
