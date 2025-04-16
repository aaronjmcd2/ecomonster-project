# Player.gd
# Handles player movement, zoom control, item pickup, and hotbar scrolling.
# Uses: InventoryDataScript, InventoryUI, PlayerZoomModule, PlayerPickupModule, PlayerCombatModule

extends CharacterBody2D

# === Exported Configuration ===
@export var speed: float = 200.0
@export var pickup_radius: float = 800.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

# === Nodes & UI References ===
@onready var inventory_ui := get_node("/root/Main/UILayer/InventoryUI")
@onready var anim_sprite := $AnimatedSprite2D
@onready var camera := $Camera2D

# === Movement State ===
var velocity_vector := Vector2.ZERO
var facing_direction := Vector2.DOWN

# === Modules ===
var zoom_module = preload("res://Modules/PlayerZoomModule.gd").new()
var pickup_module = preload("res://Modules/PlayerPickupModule.gd").new()
var combat_module = preload("res://Modules/PlayerCombatModule.gd").new()

# === Initialization ===
func _ready():
	setup_physics_material()
	zoom_module.setup(camera, zoom_step, min_zoom, max_zoom)
	pickup_module.setup(self, inventory_ui, pickup_radius)
	combat_module.setup(self, inventory_ui)

# === Movement & Collision Handling ===
func _physics_process(delta: float) -> void:
	velocity_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		velocity_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity_vector.x += 1

	velocity_vector = velocity_vector.normalized()
	velocity = velocity_vector * speed

	var collision = move_and_collide(velocity * delta)
	position = position.round()
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("monsters"):
			velocity = Vector2.ZERO
			position += collision.get_normal() * 2.0

	if velocity_vector != Vector2.ZERO:
		facing_direction = velocity_vector

	update_animation()

# === Input Handling ===
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_module.zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_module.zoom_out()

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var world_pos = get_canvas_transform().affine_inverse() * event.position
			pickup_module.try_pickup_item(world_pos)

	if event.is_action_pressed("hotbar_scroll_left"):
		InventoryDataScript.hotbar_selected_index -= 1
		if InventoryDataScript.hotbar_selected_index < 0:
			InventoryDataScript.hotbar_selected_index = InventoryDataScript.HOTBAR_SIZE - 1
		_update_hotbar_selector()

	elif event.is_action_pressed("hotbar_scroll_right"):
		InventoryDataScript.hotbar_selected_index += 1
		if InventoryDataScript.hotbar_selected_index >= InventoryDataScript.HOTBAR_SIZE:
			InventoryDataScript.hotbar_selected_index = 0
		_update_hotbar_selector()

	if event.is_action_pressed("use_item"):
		combat_module.use_weapon(facing_direction)

# === Hotbar Selector Sync ===
func _update_hotbar_selector() -> void:
	inventory_ui.update_hotbar_selector()

# === Collision Setup ===
func setup_physics_material() -> void:
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.0
	physics_material.bounce = 0.1
	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		collision_shape.shape.set("physics_material_override", physics_material)
	else:
		push_error("No valid CollisionShape2D or shape found to apply PhysicsMaterial!")

# === Animation State ===
func update_animation():
	if velocity_vector == Vector2.ZERO:
		anim_sprite.play("idle_down")
	else:
		if velocity_vector.y > 0:
			anim_sprite.play("walk_down")
		else:
			anim_sprite.play("idle_down")  # fallback for now
