extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

var max_health: int = 100
var current_health: int = 100

func _ready():
	update_health_display()

func set_health(new_health: int):
	current_health = clamp(new_health, 0, max_health)
	update_health_display()

func take_damage(damage: int):
	set_health(current_health - damage)

func update_health_display():
	if health_bar:
		health_bar.value = (float(current_health) / float(max_health)) * 100
	if health_label:
		health_label.text = str(current_health) + "/" + str(max_health)

func is_alive() -> bool:
	return current_health > 0