extends CharacterBody2D

class_name Enemy

enum EnemyKind {Slime, Wolf, Demon, Eldritch}

@export var health_bar: ProgressBar
@export var sprite: Sprite2D

var alive: bool = true
var stats: Stats
var kind: EnemyKind

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
	stats.atk = 10
	stats.def = 2
	stats.ap = 4
	health_bar.value = stats.health
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()
