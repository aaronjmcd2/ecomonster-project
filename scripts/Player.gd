# Player.gd
# Handles player movement, zoom control, item pickup, and hotbar scrolling.
# Uses: InventoryDataScript, InventoryUI

extends CharacterBody2D

@export var speed: float = 200.0
@export var pickup_radius: float = 800.0
@onready var inventory_ui := get_node("/root/Main/UILayer/InventoryUI")

var velocity_vector := Vector2.ZERO

@onready var sprite := $Sprite
@onready var camera := $Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

func _ready():
	# Apply custom physics material to prevent monster sticking
	setup_physics_material()

func _physics_process(delta: float) -> void:
	# Player movement input
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

	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("monsters"):
			# Prevent sticky collision with monsters
			velocity = Vector2.ZERO
			position += collision.get_normal() * 2.0

	# Flip sprite to face direction
	if velocity_vector.x < 0:
		sprite.scale.x = -1
	elif velocity_vector.x > 0:
		sprite.scale.x = 1

# === Sets low-friction physics material to avoid sticky collisions ===
func setup_physics_material() -> void:
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.0
	physics_material.bounce = 0.1

	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		collision_shape.shape.set("physics_material_override", physics_material)
	else:
		push_error("No valid CollisionShape2D or shape found to apply PhysicsMaterial!")

# === Zoom the camera in or out ===
func zoom_camera(amount: float) -> void:
	var new_zoom = camera.zoom + Vector2(amount, amount)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	camera.zoom = new_zoom

# === Handle mouse and keyboard input ===
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_step)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var world_pos = get_canvas_transform().affine_inverse() * event.position
		try_pickup_item(world_pos)

	# Hotbar scrolling: X (left), C (right)
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

	# Weapon use: Spacebar
	if event.is_action_pressed("use_item"):
		var selected_item = inventory_ui.get_selected_hotbar_item()
		if selected_item and selected_item.has("type") and selected_item.type == "weapon":
			use_weapon(selected_item)


# === Try picking up an item at a clicked location ===
func try_pickup_item(world_pos: Vector2) -> void:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results = get_world_2d().direct_space_state.intersect_point(query)

	for result in results:
		var node = result.get("collider")
		if node == null:
			continue

		# Handle ore drops
		if node.is_in_group("ore_drops"):
			if global_position.distance_to(node.global_position) <= pickup_radius:
				print("✨ Picked up:", node.name)

				var drop_count = node.count
				var item_data = {
					"name": "IronOre",
					"count": drop_count
				}

				inventory_ui.add_item_to_inventory(item_data.duplicate(true))  # Deep copy
				node.queue_free()
				break

		# Handle world items like SwordDrop
		elif node.is_in_group("world_items"):
			if global_position.distance_to(node.global_position) <= pickup_radius:
				print("🗡️ Picked up world item:", node.name)

				var item_data = node.get_item_data()
				inventory_ui.add_item_to_inventory(item_data.duplicate(true))  # Deep copy
				node.queue_free()
				break


# === Helper to update hotbar UI and print selected item ===
func _update_hotbar_selector() -> void:
	var ui = get_node("/root/Main/UILayer/InventoryUI")
	ui.update_hotbar_selector()

	var selected_item = ui.get_selected_hotbar_item()
	if not selected_item.is_empty():
		print("🔘 Selected Hotbar Item:", selected_item)
	else:
		print("⚪ Hotbar slot is empty.")

func use_weapon(item):
	print("Swinging weapon: %s" % item.name)

	var use_scene = item.get("use_scene", null)
	if use_scene:
		var sword = use_scene.instantiate()
		sword.global_position = global_position + Vector2(16, 0)
		get_parent().add_child(sword)

		if sword.has_method("swing"):
			sword.swing()
