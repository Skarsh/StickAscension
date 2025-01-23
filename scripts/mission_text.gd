extends Control

class_name MissionText

var opening_monologue: String = """
You are a stick. Why? You do not remember. Was it a curse? A bad deal? A poorly worded wish?
It does not matter. The only thing you know is this: you are a stick.
That old joke comes to mind. What is brown and sticky?
Yes, you are the punchline. Congratulations.
With your "stick-sight" (which I just made up), you spot something moving in the distance.
Oh no, it is coming right at you. Oh yes, it is time to fight.
"""

@export var typing_speed: float = 0.07

@onready var text_label: Label =  $VBoxContainer/Text

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var current_text: String = ""
var current_index: int = 0
var is_typing: bool = false

var time_since_last_scribble = 0.0

func start_typing_effect() -> void:
	current_text = ""
	current_index = 0
	is_typing = true
	audio_player.play()
	set_process(true)

func stop_typing_effect() -> void:
	current_text = opening_monologue
	text_label.text = current_text
	is_typing = false
	audio_player.stop()
	set_process(false)

func _ready() -> void:
	start_typing_effect()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		stop_typing_effect()

	time_since_last_scribble += delta

	if is_typing && time_since_last_scribble > typing_speed:
		if current_index < opening_monologue.length():
			current_text += opening_monologue[current_index]
			text_label.text = current_text
			current_index += 1
			time_since_last_scribble = 0
		else:
			current_text = ""
			current_index = 0

	if current_index == opening_monologue.length() - 1:
		stop_typing_effect()
