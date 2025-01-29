extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var mission_text: MissionText = $CanvasLayer/MissionTextPanelContainer
@onready var interaction_buttons: HBoxContainer = $CanvasLayer/InteractionButtons
@onready var gold_label: Label = $CanvasLayer/Gold/Label

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var enemy_sound_player: AudioStreamPlayer = $EnemySoundPlayer
@onready var player_sound_player: AudioStreamPlayer = $PlayerSoundPlayer

@onready var enemy_attack_timer: Timer = Timer.new()

@export var spawner: Spawner

@onready var emitter = $CanvasLayer/MissionTextPanelContainer

var battle_music = preload("res://music/BattleMusic1.1Cello.mp3")

var stick_attack_sound = preload("res://sounds/ES_Wooden Stick, Hit Log, Hard - Epidemic Sound.mp3")
var staff_attack_sound = preload("res://sounds/Weapons/StaffAttackSound.wav")
var spear_attack_sound = preload("res://sounds/Weapons/SpearAttackSound.mp3")
var sword_attack_sound = preload("res://sounds/Weapons/SwordAttackSound.mp3")
var revolver_attack_sound = preload("res://sounds/Weapons/RevolverAttackSound.mp3")

var slime_attack_sound = preload("res://sounds/Monsters/Slime/SlimeAttackSound.mp3")
var wolf_attack_sound = preload("res://sounds/Monsters/Wolf/WolfAttackSound.mp3")
var black_knight_attack_sound = preload("res://sounds/Monsters/BlackKnight/BlackKnightAttackSound.mp3")
var eldritch_attack_sound = preload("res://sounds/Monsters/EldritchBeast/EldritchBeastAttackSound.mp3")
var demon_attack_sound = preload("res://sounds/Monsters/Demon/DemonAttackSound.mp3")

var button_entered_sound = preload("res://sounds/MenuHoverBop.wav")

var player_scene = preload("res://scenes/player.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var player_instance
var enemy_instance
var slime_enemy_instance

var game_active = false
var player_turn = true
var is_animating = false

const PLAYER_SCALE = 2.5
const PLAYER_SPRITE_SCALE = 10

const DEATH_PENALTY = 0.8

func _ready() -> void:

	add_child(enemy_attack_timer)
	enemy_attack_timer.one_shot = true
	enemy_attack_timer.timeout.connect(_on_enemy_attack_timer_timeout)

	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.scale *= PLAYER_SCALE
	player_instance.sprite.scale /= PLAYER_SPRITE_SCALE
	player_instance.position = Vector2(-500, 0)

	# TODO(Thomas): Set more of the previous player state, e.g weaponkind, stats etc
	if GameState.started == true:
		player_instance.gold = GameState.player_gold
		player_instance.stats = GameState.player_stats
		player_instance.update_stats()
		player_instance.update_weapon()
	else:
		GameState.started = true
		GameState.player_stats = player_instance.stats
		
		# TODO(Thomas): Need better initialization stuff
		GameState.next_level = 2

	player_instance.hide()
	gold_label.text = str(player_instance.gold)


	enemy_instance = spawner.spawn(self, spawner.random_enemy_kind())


func perform_attack_animation(attacker: Node2D, target: Node2D, on_complete: Callable) -> void: 
	if is_animating:
		return
	
	is_animating = true
	var start_pos = attacker.position
	var target_pos = target.position

	# Calculate control point for the quadratic curve
	# Point above and between attacker and target
	var control_point = Vector2(
		(start_pos.x + target_pos.x) / 2,
		min(start_pos.y, target_pos.y) - 200
	)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)

	var attack_duration = 0.3
	var return_duration = 0.2

	# Forward attack animation
	tween.tween_method(
		func(t: float):
			var q0 = start_pos.lerp(control_point, t)
			var q1 = control_point.lerp(target_pos, t)
			attacker.position = q0.lerp(q1, t), 0.0, 1.0, attack_duration
	)

	# Return attack animation
	tween.tween_method(
		func(t: float):
			var q0 = target_pos.lerp(control_point, t)
			var q1 = control_point.lerp(start_pos, t)
			attacker.position = q0.lerp(q1, t), 0.0, 1.0, return_duration
	)

	tween.tween_callback(func():
		is_animating = false
		on_complete.call()
	)

func start_enemy_attack_timer() -> void:
	var delay = randf_range(1.0, 2.0)
	enemy_attack_timer.start(delay)

func _on_enemy_attack_timer_timeout() -> void:
	if game_active and not player_turn and not is_animating and player_instance.alive and enemy_instance.alive:
		perform_attack_animation(enemy_instance, player_instance, func():
			# TODO(Thomas): What to do when the player dies?
			var alive = player_instance.take_damage(player_instance.stats.calculate_damage(enemy_instance.stats))
			if not alive:
				GameState.player_gold = int(DEATH_PENALTY * GameState.player_gold)
				get_tree().change_scene_to_file("res://scenes/shop.tscn")
		)

		match enemy_instance.kind:
			Enemy.EnemyKind.Slime:
				enemy_sound_player.stream = slime_attack_sound
			Enemy.EnemyKind.Wolf:
				enemy_sound_player.stream = wolf_attack_sound
			Enemy.EnemyKind.BlackKnight:
				enemy_sound_player.stream = black_knight_attack_sound
			Enemy.EnemyKind.Eldritch:
				enemy_sound_player.stream = eldritch_attack_sound
			Enemy.EnemyKind.Demon:
				enemy_sound_player.stream = demon_attack_sound

		enemy_sound_player.play()
		player_turn = true

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("ui_accept"):
		mission_text.stop_typing_effect()
		
func _on_ok_button_pressed() -> void:
	start_battle_scene()

	
func _on_attack_pressed() -> void:
	if game_active and player_turn and not is_animating and player_instance.alive and enemy_instance.alive:
		perform_attack_animation(player_instance, enemy_instance, func():
			var alive = enemy_instance.take_damage(enemy_instance.stats.calculate_damage(player_instance.stats))
			if not alive:

				# Drops
				var gold_amount = enemy_instance.generate_drop()
				GameState.player_gold += gold_amount
				gold_label.text = str(GameState.player_gold)

				# Despawn
				enemy_instance.hide()
				spawner.despawn(enemy_instance)

				#Spawn
				enemy_instance = spawner.spawn(self, spawner.random_enemy_kind())
				enemy_instance.show()
		)

		match player_instance.kind:
			Player.WeaponKind.Stick:
				player_sound_player.stream = stick_attack_sound
			Player.WeaponKind.Staff:
				player_sound_player.stream = staff_attack_sound
			Player.WeaponKind.Spear:
				player_sound_player.stream = spear_attack_sound
			Player.WeaponKind.Sword:
				player_sound_player.stream = sword_attack_sound
			Player.WeaponKind.Revolver:
				player_sound_player.stream = revolver_attack_sound

		player_sound_player.play()
		player_turn = false

		# It's not time for the enemy to attack us
		start_enemy_attack_timer()


func start_battle_scene() -> void:
	mission_text.hide()
	mission_text.stop_typing_effect()
	player_instance.show()
	enemy_instance.show()
	audio_player.stream = battle_music
	audio_player.play()
	game_active = true
	interaction_buttons.show()

func _on_escape_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shop.tscn")

func _on_mission_text_panel_container_start_battle_scene_signal() -> void:
	await get_tree().process_frame
	start_battle_scene()