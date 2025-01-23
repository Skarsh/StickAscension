extends Node2D

class_name Enemy

@export var health_bar: ProgressBar

var stats: Player.Stats

func damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health
	print(health_bar.value)

func _ready() -> void:
	stats = Player.Stats.new()
	health_bar.value = stats.health
