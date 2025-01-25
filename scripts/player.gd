extends CharacterBody2D

class_name Player

@export var health_bar: ProgressBar

var stats: Stats

func take_damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health

func attack(enemy_stats: Stats) -> int:
	var value = 14 - enemy_stats.def
	return value

func _ready() -> void:
	stats = Stats.new()
	health_bar.value = stats.health

func _process(delta: float) -> void:
	#position = Vector2(100, 100) * cos(Time.get_unix_time_from_system()) + Vector2(100, 100) * sin(Time.get_unix_time_from_system())
	pass
