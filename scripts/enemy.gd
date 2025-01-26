extends CharacterBody2D

class_name Enemy

@export var health_bar: ProgressBar

var alive: bool = true
var stats: Stats

func take_damage(amount: int) -> bool:
	alive = stats.take_damage(amount)

	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()
	return alive

func _ready() -> void:
	stats = Stats.new()
	stats.health = 100
	stats.def = 2
	stats.atk = 100
	stats.ap = 4
	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()
