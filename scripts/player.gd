extends CharacterBody2D

class_name Player

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
	stats.atk = 50
	stats.def = 4
	stats.ap = 4
	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()

func _process(delta: float) -> void:
	#position = Vector2(100, 100) * cos(Time.get_unix_time_from_system()) + Vector2(100, 100) * sin(Time.get_unix_time_from_system())
	pass
