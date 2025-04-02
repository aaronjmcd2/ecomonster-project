extends CharacterBody2D

@export var speed: float = 200.0

var velocity_vector := Vector2.ZERO
@onready var sprite := $Sprite

func _ready():
	setup_physics_material()

func _physics_process(delta):
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
			# Stop moving and nudge away to prevent sticking
			velocity = Vector2.ZERO
			position += collision.get_normal() * 2.0

	# Flip sprite based on horizontal direction
	if velocity_vector.x < 0:
		sprite.scale.x = -1
	elif velocity_vector.x > 0:
		sprite.scale.x = 1


# === Set Physics Material to Prevent Sticking ===
func setup_physics_material():
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.0
	physics_material.bounce = 0.1

	var collision_shape = $CollisionShape2D
	if collision_shape and collision_shape.shape:
		collision_shape.shape.set("physics_material_override", physics_material)
	else:
		push_error("No valid CollisionShape2D or shape found to apply PhysicsMaterial!")
