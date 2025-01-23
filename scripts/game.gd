extends Node2D

# Reference to the Camera2D node
@onready var camera: Camera2D = $Camera2D

# Shake the UI parent node
@onready var ui_parent: Control = $CanvasLayer/Player/PlayerPanelContainer

@onready var mission_text: MissionText = $CanvasLayer/MissionTextPanelContainer

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


var battle_music = preload("res://music/BattleMusic1.1Cello.mp3")

const SHAKE_LENGTH = 2.0

var shake_duration: float = 0.0
var shaking = false

var player: Player
var enemy: Enemy

#func shake_ui():
#    ui_parent.position = Vector2(
#        randf_range(-30.0, 30.0),
#        randf_range(-30.0, 30.0)
#    )

func _ready() -> void:
	player = $CanvasLayer/Player
	enemy = $CanvasLayer/Enemy

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_select") and shake_duration < SHAKE_LENGTH:
	#    print("herro?")
	#    shaking = true 
	
	#if shaking:
	#    shake_ui()
	#    shake_duration += delta

	#if shake_duration >= SHAKE_LENGTH:
	#    shaking = false
	#    shake_duration = 0
	
	if Input.is_action_just_pressed("ui_select"):
		player.take_damage(enemy.attack(player.stats))
		enemy.take_damage(player.attack(enemy.stats))
		

func _on_ok_button_pressed() -> void:
	mission_text.hide()
	mission_text.stop_typing_effect()
	player.show()
	enemy.show()
	audio_player.stream = battle_music
	audio_player.play()
	
