extends Node

class_name Player

@export var health_bar: ProgressBar

var stats: Stats

func damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health
	print(health_bar.value)

func _ready() -> void:
	stats = Stats.new()
	health_bar.value = stats.health

class Stats: 
	var health: int = 100
	var atk: int = 10
	var def: int = 3
	var ap: int = 10