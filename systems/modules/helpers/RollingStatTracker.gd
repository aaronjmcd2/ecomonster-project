# RollingStatTracker.gd
# Tracks a rolling average of a value (e.g., Coal/min, Lava/min).
# Call .add(value) to record, and .tick() once per second to roll the stat window.
# Call .get_average() to retrieve the rolling average.

class_name RollingStatTracker
extends Node

var log: Array = []
var max_size: int = 60
var current: int = 0

func add(value: int) -> void:
	current += value

func tick() -> void:
	log.append(current)
	if log.size() > max_size:
		log.pop_front()
	current = 0

func get_average() -> float:
	var total = 0
	for value in log:
		total += value
	return float(total)