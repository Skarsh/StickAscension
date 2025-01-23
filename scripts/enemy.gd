extends Node2D

class_name Enemy

@export var health_bar: ProgressBar

var stats: Player.Stats

func attack(player_stats: Player.Stats) -> int:
	var value = 5 - player_stats.def
	return value

func take_damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health
	print(health_bar.value)

func _ready() -> void:
	stats = Player.Stats.new()
	stats.def = 2
	health_bar.value = stats.health
