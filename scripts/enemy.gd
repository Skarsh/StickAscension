extends CharacterBody2D

class_name Enemy

@export var health_bar: ProgressBar

var stats: Stats

func attack(player_stats: Stats) -> int:
	var value = 5 - player_stats.def
	return value

func take_damage(amount: int) -> void:
	stats.health -= amount
	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()

func _ready() -> void:
	stats = Stats.new()
	stats.def = 2
	stats.atk = 3
	stats.ap = 4
	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()
