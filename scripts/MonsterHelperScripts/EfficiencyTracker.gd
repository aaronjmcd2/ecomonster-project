# EfficiencyTracker.gd
# Shared helper module to manage buildup and decay of efficiency over time.
# Usage: efficiency_score = EfficiencyTracker.update(delta, is_efficient, current_score, rate)

extends Node

func update(delta: float, is_efficient: bool, score: float, rate: float) -> float:
	if is_efficient:
		score += rate * delta
	else:
		score -= rate * delta
	return clamp(score, 0.0, 100.0)