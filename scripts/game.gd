extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var mission_text: MissionText = $CanvasLayer/MissionTextPanelContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

var battle_music = preload("res://music/BattleMusic1.1Cello.mp3")
var stick_hit_sound = preload("res://sounds/ES_Wooden Stick, Hit Log, Hard - Epidemic Sound.mp3")
var slime_hit_sound = preload("res://sounds/ES_Swipe, Body Hit, Slash - Epidemic Sound.mp3")

var player_scene = preload("res://scenes/player.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var player_instance
var enemy_instance

var game_active = false
var player_turn = true
var is_animating = false

func _ready() -> void:

	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.scale *= 2
	player_instance.position = Vector2(-500, 0)
	player_instance.hide()

	enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.scale *= 2
	enemy_instance.position = Vector2(500, 0)
	enemy_instance.hide()

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
			# Quadratic Bezier curve
			var q0 = start_pos.lerp(control_point, t)
			var q1 = control_point.lerp(target_pos, t)
			attacker.position = q0.lerp(q1, t), 0.0, 1.0, attack_duration
	)

	tween.tween_method(
		func(t: float):
			# Quadratic Bezier curve
			var q0 = target_pos.lerp(control_point, t)
			var q1 = control_point.lerp(start_pos, t)
			attacker.position = q0.lerp(q1, t), 0.0, 1.0, return_duration
	)

	tween.tween_callback(func():
		is_animating = false
		on_complete.call()
	)

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("ui_accept") and game_active and player_turn and not is_animating:
		perform_attack_animation(player_instance, enemy_instance, func():
			enemy_instance.take_damage(player_instance.attack(enemy_instance.stats))
		)
		sound_player.stream = slime_hit_sound
		sound_player.play()
		player_turn = false

	elif Input.is_action_just_pressed("ui_accept") and game_active and not player_turn and not is_animating:
		perform_attack_animation(enemy_instance, player_instance, func():
			player_instance.take_damage(enemy_instance.attack(player_instance.stats))
		)
		sound_player.stream = stick_hit_sound
		sound_player.play()
		player_turn = true
		
func _on_ok_button_pressed() -> void:
	mission_text.hide()
	mission_text.stop_typing_effect()
	player_instance.show()
	enemy_instance.show()
	audio_player.stream = battle_music
	audio_player.play()
	game_active = true

	
