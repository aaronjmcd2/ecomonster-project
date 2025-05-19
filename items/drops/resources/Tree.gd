# Tree.gd
extends StaticBody2D

# Optional: Add some subtle movement
@export var sway_amount: float = 2.0
@export var sway_speed: float = 1.0

@onready var sprite = $Sprite2D

var time_passed: float = 0.0
var original_position: Vector2

func _ready():
	# Make sure we're in the trees group
	if not is_in_group("trees"):
		add_to_group("trees")
	
	# Store original position for swaying
	original_position = sprite.position

func _process(delta):
	# Optional: Add subtle swaying motion
	time_passed += delta
	var sway = sin(time_passed * sway_speed) * sway_amount
	sprite.position.x = original_position.x + sway
