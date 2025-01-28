extends Node

@export var Item1: TextureButton
@export var Item2: TextureButton
@export var Item3: TextureButton

class Item:
	var value: int
	
	func _init(new_value: int) -> void:
		value = new_value

@onready var gold_label: Label = $CanvasLayer/Gold/Label

var items: Array[Item] = []
var selected_button: TextureButton = null
var selected_style = StyleBoxFlat.new()

func _ready() -> void:
	update_gold_label()

	items.append(Item.new(5))
	items.append(Item.new(10))
	items.append(Item.new(15))

	# Configure the selection border style
	selected_style.border_color = Color.WHITE
	selected_style.border_width_left = 4
	selected_style.border_width_right = 4
	selected_style.border_width_top = 4
	selected_style.border_width_bottom = 4

	# Add content margin to ensure border visibility
	selected_style.content_margin_left = 6
	selected_style.content_margin_right = 6
	selected_style.content_margin_top = 6
	selected_style.content_margin_bottom = 6
	
	# Connect button signals
	_connect_button_signals()

func _connect_button_signals():
	# Clear existing connections
	for button in [Item1, Item2, Item3]:
		if button.pressed.is_connected(_on_item_pressed):
			button.pressed.disconnect(_on_item_pressed)
	
	# Create new connections
	Item1.pressed.connect(_on_item_pressed.bind(Item1))
	Item2.pressed.connect(_on_item_pressed.bind(Item2))
	Item3.pressed.connect(_on_item_pressed.bind(Item3))

func _on_item_pressed(button: TextureButton):
	if selected_button == button:
		# Deselect if clicking the same button
		button.remove_theme_stylebox_override("normal")
		selected_button = null
	else:
		# Deselect previous button
		if selected_button:
			selected_button.remove_theme_stylebox_override("normal")
		
		# Select new button
		selected_button = button
		selected_button.add_theme_stylebox_override("normal", selected_style)

func _process(delta: float) -> void:
	button_hover_animation(Item1)
	button_hover_animation(Item2)
	button_hover_animation(Item3)

func button_hover_animation(button: TextureButton):
	button.pivot_offset = button.size / 2
	if button == selected_button:
		start_tween(button, "scale", Vector2.ONE * 2.0, 0.1)
	else:
		if button.is_hovered():
			start_tween(button, "scale", Vector2.ONE * 2.0, 0.1)
		else:
			start_tween(button, "scale", Vector2.ONE, 0.1)

# Rest of your existing functions
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


func _on_buy_button_pressed() -> void:
	var item: Item
	if selected_button == Item1:
		item = items[0]
	elif selected_button == Item2:
		item = items[1]
	elif selected_button == Item3:
		item = items[2]

	if item != null and GameState.player_gold >= item.value:
		GameState.player_gold -= item.value

	update_gold_label()
	
func update_gold_label() -> void:
	gold_label.text = str(GameState.player_gold)
