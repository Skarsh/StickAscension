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

	update_stats()
	return alive

func _ready() -> void:
	pass

func update_stats():
	health_bar.value = (stats.health / float(stats.max_health)) * 100
	$HP.text = stats.health_string()
	$ATK.text = stats.atk_string()
	$DEF.text = stats.def_string()
	$AP.text = stats.ap_string()
