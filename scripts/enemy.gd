extends CharacterBody2D

class_name Enemy

enum EnemyKind {Slime, BlackKnight, Wolf, Demon, Eldritch}

@export var health_bar: ProgressBar
@export var sprite: Sprite2D

var alive: bool = true
var stats: Stats
var kind: EnemyKind

func setup(new_kind: EnemyKind) -> void:
	kind = new_kind

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

func generate_drop() -> int:
	var gold_value = 0
	match kind: 
		EnemyKind.Slime: 
			gold_value = randi_range(50, 100000000)
		EnemyKind.Wolf: 
			gold_value = randi_range(200, 300)
		EnemyKind.BlackKnight: 
			gold_value = randi_range(400, 600)
		EnemyKind.Eldritch: 
			gold_value = randi_range(1000, 1500)
		EnemyKind.Demon: 
			gold_value = randi_range(2300, 3200)
	return gold_value
