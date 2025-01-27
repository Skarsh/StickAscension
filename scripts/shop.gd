extends Node

@export var Item1: TextureButton
@export var Item2: TextureButton
@export var Item3: TextureButton

@onready var gold_label: Label = $CanvasLayer/Gold/Label

var items: Array[Player.WeaponKind]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gold_label.text = str(GameState.player_gold)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button_hover_animation(Item1)
	button_hover_animation(Item2)
	button_hover_animation(Item3)

func _on_item_1_mouse_entered() -> void:
	Item1.modulate = Color(1.2, 1.2, 1.2)

func _on_item_1_mouse_exited() -> void:
	Item1.modulate = Color(1.0, 1.0, 1.0)

func _on_item_2_mouse_entered() -> void:
	Item2.modulate = Color(1.2, 1.2, 1.2)

func _on_item_2_mouse_exited() -> void:
	Item2.modulate = Color(1.0, 1.0, 1.0)

func _on_item_3_mouse_entered() -> void:
	Item3.modulate = Color(1.2, 1.2, 1.2)

func _on_item_3_mouse_exited() -> void:
	Item3.modulate = Color(1.0, 1.0, 1.0)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func start_tween(object, property, final_value, duration):
	var tween = create_tween()
	tween.tween_property(object, property, final_value, duration)

func button_hover_animation(button):
	button.pivot_offset = button.size / 2
	if button.is_hovered():
		start_tween(button, "scale", Vector2.ONE * 2.0, 0.1)
	else:
		start_tween(button, "scale", Vector2.ONE, 0.1)
