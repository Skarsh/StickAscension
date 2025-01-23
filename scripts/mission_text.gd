extends Node

var opening_monologue: String = """
You are a stick. Why? You don’t remember. Was it a curse? A bad deal? A poorly worded wish?
Doesn’t matter. The only thing you know is this: you’re a stick.
That old joke comes to mind. What’s brown and sticky?
Yeah, you’re the punchline. Congrats.
With your "stick-sight" (which I just made up), you spot something moving in the distance.
Oh no, it’s coming right at you. Oh yes, it’s time to fight.
"""

@export var typing_speed: float = 0.07

@export var text_label: Label

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
	if Input.is_action_just_pressed("ui_select"):
		stop_typing_effect()

	time_since_last_scribble += delta
	print(time_since_last_scribble)

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
