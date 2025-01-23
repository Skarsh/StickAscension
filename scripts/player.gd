extends Node2D

class_name Player

@export var health_bar: ProgressBar

var stats: Stats

func take_damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health
	print(health_bar.value)

func attack(enemy_stats: Stats) -> int:
	var value = 14 - enemy_stats.def
	return value

func _ready() -> void:
	stats = Stats.new()
	health_bar.value = stats.health

class Stats: 
	var health: int = 100
	var atk: int = 10
	var def: int = 3
	var ap: int = 10