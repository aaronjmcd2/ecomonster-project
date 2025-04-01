extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0

# Directional input
var velocity_vector := Vector2.ZERO

func _physics_process(delta):
	# Get player input for movement
	velocity_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		velocity_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity_vector.x += 1

	# Normalize diagonal movement
	velocity_vector = velocity_vector.normalized()

	# Move the player
	velocity = velocity_vector * speed
	move_and_slide()
