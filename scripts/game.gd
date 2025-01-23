extends Node2D


# Reference to the Camera2D node
@onready var camera: Camera2D = $Camera2D

# Shake the UI parent node
@onready var ui_parent: Control = $CanvasLayer/Player/PlayerPanelContainer

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
        player.damage(1)
        enemy.damage(1)

        
