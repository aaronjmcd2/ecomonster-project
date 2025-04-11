extends Node2D

@onready var anim := $AnimationPlayer

func _ready():
	anim.play("idle")

func swing():
	anim.play("swing")
