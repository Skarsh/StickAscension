extends Node

class_name Spawner

var enemies: Array[Enemy]

var enemy_scene = preload("res://scenes/enemy.tscn")

var slime_texture = preload("res://sprites/Slime_version_2_Merged.png")
var wolf_texture = preload("res://sprites/EnemyCardDireWolf_version_2_Merged_10xScaled..png")
var demon_texutre = preload("res://sprites/EnemyCardDemon_Version_1_Merged_10xScaled.png")
var eldritch_texture = preload("res://sprites/EnemyCardEldritchBeast_version_1_Merged_10xScaled.png")

var slime_stats = Stats.new(100, 7, 2, 3)
var wolf_stats = Stats.new(200, 12, 4, 5)
var demon_stats = Stats.new(300, 20, 8, 10)
var eldritch_stats = Stats.new(400, 30, 15, 18)

func random_enemy_kind() -> Enemy.EnemyKind:
	var enemy_kinds = Enemy.EnemyKind.values()
	var random_index = randi() % enemy_kinds.size()
	return enemy_kinds[random_index]


func spawn(parent: Node2D, kind: Enemy.EnemyKind) -> Node2D:
	var enemy_instance = enemy_scene.instantiate()
	parent.add_child(enemy_instance)

	# TODO(Thomas): Should make the slime scaled the same as the others
	match kind:
		Enemy.EnemyKind.Slime:
			enemy_instance.stats = slime_stats
			enemy_instance.sprite.texture = slime_texture
			enemy_instance.scale *= 2
		Enemy.EnemyKind.Wolf:
			enemy_instance.stats = wolf_stats
			enemy_instance.sprite.texture = wolf_texture
			enemy_instance.scale *= 2
			enemy_instance.sprite.scale /= 10
		Enemy.EnemyKind.Demon:
			enemy_instance.stats = demon_stats
			enemy_instance.sprite.texture = demon_texutre
			enemy_instance.scale *= 2
			enemy_instance.sprite.scale /= 10
		Enemy.EnemyKind.Eldritch:
			enemy_instance.stats = eldritch_stats
			enemy_instance.sprite.texture = eldritch_texture
			enemy_instance.scale *= 2
			enemy_instance.sprite.scale /= 10

	enemy_instance.position = Vector2(500, 0)
	enemy_instance.update_stats()
	enemy_instance.hide()
	return enemy_instance

func despawn(node: Node2D):
	node.queue_free()


