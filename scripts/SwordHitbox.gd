extends Area2D

@export var duration := 0.2

func _ready():
	$Timer.wait_time = duration
	$Timer.start()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(1)

func _on_Timer_timeout():
	queue_free()
