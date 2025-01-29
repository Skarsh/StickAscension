extends Node

class_name Spawner

var enemies: Array[Enemy]

var enemy_scene = preload("res://scenes/enemy.tscn")

var slime_texture = preload("res://sprites/Slime_version_2_2_merged_10xScaled.png")
var wolf_texture = preload("res://sprites/EnemyCardDireWolf_version_2_Merged_10xScaled..png")
var black_knight_texture = preload("res://sprites/EnemyCardBlackKnigh_Version_1_Merged_10xScaled.png")
var demon_texutre = preload("res://sprites/EnemyCardDemon_Version_1_Merged_10xScaled.png")
var eldritch_texture = preload("res://sprites/EnemyCardEldritchBeast_version_1_Merged_10xScaled.png")


const ENEMY_SCALE = 2.5
const ENEMY_SPRITE_SCALE = 10

const BASE_SPAWN_LEVEL = 1
const ENEMIES_PER_LEVEL = 3

func random_enemy_kind() -> Enemy.EnemyKind:
	# Get the current level from game state
	var current_level = GameState.next_level - 1
	
	# Define available enemies per level
	var available_enemies: Array[Enemy.EnemyKind] = []
	
	match current_level:
		1: # Starting level - only Slimes
			available_enemies = [Enemy.EnemyKind.Slime]
		2: # Introduce Wolves
			available_enemies = [
				Enemy.EnemyKind.Slime,
				Enemy.EnemyKind.Slime,  # Weight slimes higher
				Enemy.EnemyKind.Wolf
			]
		3: # Introduce Black Knights
			available_enemies = [
				Enemy.EnemyKind.Slime,
				Enemy.EnemyKind.Wolf,
				Enemy.EnemyKind.Wolf,   # Weight wolves higher
				Enemy.EnemyKind.BlackKnight
			]
		4: # Introduce Demons
			available_enemies = [
				Enemy.EnemyKind.Wolf,
				Enemy.EnemyKind.BlackKnight,
				Enemy.EnemyKind.BlackKnight,  # Weight knights higher
				Enemy.EnemyKind.Demon
			]
		5: # Introduce Eldritch
			available_enemies = [
				Enemy.EnemyKind.BlackKnight,
				Enemy.EnemyKind.Demon,
				Enemy.EnemyKind.Demon,        # Weight demons higher
				Enemy.EnemyKind.Eldritch
			]
		6, 7, 8: # Late game mix
			available_enemies = [
				Enemy.EnemyKind.Demon,
				Enemy.EnemyKind.Demon,
				Enemy.EnemyKind.Eldritch,
				Enemy.EnemyKind.Eldritch
			]
		_: # Default/fallback case
			available_enemies = [Enemy.EnemyKind.Slime]
	
	var random_index = randi() % available_enemies.size()
	return available_enemies[random_index]


func spawn(parent: Node2D, kind: Enemy.EnemyKind) -> Node2D:
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.setup(kind)
	parent.add_child(enemy_instance)

	# TODO(Thomas): Should make the slime scaled the same as the others
	match kind:
		Enemy.EnemyKind.Slime:
			enemy_instance.stats = Stats.new(20, 5, 1, 1)
			enemy_instance.sprite.texture = slime_texture
			enemy_instance.scale *= ENEMY_SCALE
			enemy_instance.sprite.scale /= ENEMY_SPRITE_SCALE
		Enemy.EnemyKind.Wolf:
			enemy_instance.stats = Stats.new(160, 10, 3, 2)
			enemy_instance.sprite.texture = wolf_texture
			enemy_instance.scale *= ENEMY_SCALE
			enemy_instance.sprite.scale /= ENEMY_SPRITE_SCALE
		Enemy.EnemyKind.BlackKnight:
			enemy_instance.stats = Stats.new(240, 15, 6, 4)
			enemy_instance.sprite.texture = black_knight_texture
			enemy_instance.scale *= ENEMY_SCALE
			enemy_instance.sprite.scale /= ENEMY_SPRITE_SCALE
		Enemy.EnemyKind.Demon:
			enemy_instance.stats = Stats.new(320, 22, 8, 10) 
			enemy_instance.sprite.texture = demon_texutre
			enemy_instance.scale *= ENEMY_SCALE
			enemy_instance.sprite.scale /= ENEMY_SPRITE_SCALE
		Enemy.EnemyKind.Eldritch:
			enemy_instance.stats = Stats.new(450, 35, 15, 20)
			enemy_instance.sprite.texture = eldritch_texture
			enemy_instance.scale *= ENEMY_SCALE
			enemy_instance.sprite.scale /= ENEMY_SPRITE_SCALE

	enemy_instance.position = Vector2(500, 0)
	enemy_instance.update_stats()
	enemy_instance.hide()
	return enemy_instance

func despawn(node: Node2D):
	node.queue_free()
