extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var mission_text: MissionText = $CanvasLayer/MissionTextPanelContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var battle_music = preload("res://music/BattleMusic1.1Cello.mp3")

var player_scene = preload("res://scenes/player.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var player_instance
var enemy_instance

var game_active = false

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

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("ui_accept") and game_active:
		player_instance.take_damage(enemy_instance.attack(player_instance.stats))
		enemy_instance.take_damage(player_instance.attack(enemy_instance.stats))
	pass
		

func _on_ok_button_pressed() -> void:
	mission_text.hide()
	mission_text.stop_typing_effect()
	player_instance.show()
	enemy_instance.show()
	audio_player.stream = battle_music
	audio_player.play()
	game_active = true

	
