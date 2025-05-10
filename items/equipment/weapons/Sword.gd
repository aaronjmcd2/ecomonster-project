extends Node2D

@onready var anim := $AnimationPlayer

func _ready():
	$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	$Hitbox.monitoring = false  # Start disabled

func swing():
	if anim.is_playing():
		anim.stop()
	$Hitbox.monitoring = true
	anim.play("swing")
	await anim.animation_finished
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("monsters"):
		print("🩸 Hit monster:", body.name)
		if body.has_method("take_damage"):
			body.take_damage(1)
