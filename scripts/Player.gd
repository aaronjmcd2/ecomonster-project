extends CharacterBody2D

@export var speed: float = 200.0

var velocity_vector := Vector2.ZERO
@onready var sprite := $Sprite

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

	# Flip sprite based on horizontal direction
	if velocity_vector.x < 0:
		sprite.scale.x = -1
	elif velocity_vector.x > 0:
		sprite.scale.x = 1

	velocity = velocity_vector * speed
	move_and_slide()
