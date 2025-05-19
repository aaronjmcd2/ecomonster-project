# Wisp.gd
# Handles wisp behavior, movement, and dropping mana when killed
extends CharacterBody2D

# === Node References ===
@onready var sprite := $Sprite2D
@onready var life_timer := $LifeTimer

# === Wisp Helper Modules ===
@onready var movement_module = preload("res://creatures/wisp/WispMovementModule.gd").new()
@onready var ui_module = preload("res://creatures/wisp/WispUIModule.gd").new()

# Explicitly load scenes
@onready var mana_scene_ref = preload("res://items/drops/resources/Mana.tscn")

# === Configuration Parameters ===
@export_group("Movement & Search")
@export var hover_speed: float = 120.0
@export var wander_radius: float = 1500.0

@export_group("Life Cycle")
@export var life_duration: float = 180.0  # 3 minutes before despawning
@export var mana_scene: PackedScene

# === State Variables ===
var birth_forest = null  # Reference to forest that spawned this wisp
var life_remaining: float = 0.0
var wander_target: Vector2 = Vector2.ZERO
var returning_to_forest: bool = false
var health: int = 2  # Hit points
var time_passed: float = 0.0  # For simple visual effects

# === Core Functions ===
func _ready():
	# Make sure we can be clicked
	input_pickable = true
	
	# Set up visual properties
	sprite.modulate = Color(0.5, 1.0, 0.6, 0.8)  # Ghostly green appearance
	
	# Set up collision
	collision_layer = 2
	collision_mask = 1
	
	# Add to monsters and wisps groups
	if not is_in_group("monsters"):
		add_to_group("monsters")
	if not is_in_group("wisps"):
		add_to_group("wisps")
	
	# Connect timer signal
	life_timer.timeout.connect(Callable(self, "_on_life_timer_timeout"))
	
	# Start with a fresh timer
	life_timer.stop()  # Make sure any existing timer is stopped
	life_timer.wait_time = life_duration
	life_timer.start()
	life_remaining = life_duration
	
	print("✨ Wisp spawned with life duration: %s seconds" % life_duration)

func _process(delta: float) -> void:
	# Update life remaining
	life_remaining = life_timer.time_left
	
	# Simple ghostly effect - just a slight pulsing transparency
	time_passed += delta
	sprite.modulate.a = 0.6 + sin(time_passed * 2.0) * 0.1
	
	# Execute floating/wandering behavior
	_execute_wandering_behavior(delta)

func _input_event(viewport, event, shape_idx) -> void:
	ui_module.handle_input_event(self, viewport, event, shape_idx)

func get_live_stats() -> Dictionary:
	var life_percent = int((life_remaining / life_duration) * 100)
	
	var stats_text = "Life: %d%%\n" % life_percent
	stats_text += "Health: %d / 2\n" % health
	
	if returning_to_forest:
		stats_text += "Status: Returning to forest"
	else:
		stats_text += "Status: Wandering"
	
	return {
		"name": "Wisp",
		"efficiency": life_percent,
		"stats": stats_text
	}

# Called when hit by player weapon
func take_damage(amount: int) -> void:
	health -= amount
	
	# Visual feedback
	sprite.modulate = Color(1.0, 0.5, 0.5, sprite.modulate.a)  # Flash red
	
	if health <= 0:
		_drop_mana()
		queue_free()

# === Helper Functions ===
func _execute_wandering_behavior(delta: float) -> void:
	if wander_target == Vector2.ZERO or global_position.distance_to(wander_target) < 50.0:
		# Pick new wander target
		var angle = randf() * TAU
		var distance = randf_range(300.0, wander_radius)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		if birth_forest and returning_to_forest:
			# Return toward forest center
			wander_target = birth_forest.center
			returning_to_forest = false
		else:
			# Normal wandering
			wander_target = global_position + offset
	
	# Move toward target with ethereal movement
	var move_result = movement_module.float_toward_target(delta, self, wander_target, hover_speed)

func _on_life_timer_timeout() -> void:
	print("⏰ Wisp life timer expired - despawning")
	queue_free()

func _drop_mana() -> void:
	var scene_to_use = mana_scene if mana_scene != null else mana_scene_ref
	
	if scene_to_use:
		var mana = scene_to_use.instantiate()
		mana.global_position = global_position
		get_parent().add_child(mana)
		print("✨ Mana dropped at: %s" % global_position)
	else:
		print("❌ ERROR: Mana scene is not set!")
