extends Control

class_name MissionText

static var opening_monologue: String = """
You are a stick. Why? You do not remember. Was it a curse? A bad deal? A poorly worded wish?
It does not matter. The only thing you know is this: you are a stick.
That old joke comes to mind. What is brown and sticky?
Yes, you are the punchline. Congratulations.
With your "stick-sight" (which I just made up), you spot something moving in the distance.
Oh no, it is coming right at you. Oh yes, it is time to fight.
"""

static var scene_1: String = """
You did it. You stuck that thing right in the face.
Should sticks feel remorse? You do not know; you have never been a stick before.
There is no time for introspection. Another one is coming.
"""

static var scene_2: String = """
Something feels different. Are you... evolving?
Maybe you are not just a stick anymore. Maybe you are... a staff?
What is the difference? Is it just height? Status? Better posture?
Does it matter?
"""

static var scene_3: String = """
You are not a stick. Not anymore. You are something more.
You start to forget who you once were, and you remember the wise words of a famous forest predator.
“The things that make me different are the things that make me, me.”
Show the next one you, you.
"""

static var scene_4: String = """
Your mind feels... expansive. Wait, do you even have a mind?
Whatever it is, it is working. You are stronger.
But will you get to the bottom of this mystery? Or just keep hitting things until they stop moving?
Either way works for me.
"""

static var scene_5: String = """
There is no stopping you now. You are the stick everyone warned their kids about.
A stick with metal on it.
The stick parents tell bedtime horror stories about.
“You had better clean your room, or The Stick will find you!”
Yes. You are the weapon.
"""

static var scene_6: String = """
But… must you be this weapon of destruction? Could you not be something else?
Like a really sharp pencil? Or an inspirational walking stick for an old wizard?
No? Too late? Okay, cool. Back to smashing.
"""

static var scene_7: String = """
Wait, what is that smell? It is… gunpowder?
Oh, sweet splinters, are you a gun stick now?!
Things just got spicy. And very, very unsafe.
"""

static var scene_8: String = """
You are having fun now, are you not? Do not lie.
Admit it. Violence suits you. You are thriving.
Take a moment to smile. Oh wait, you do not have a face. Well, that is awkward.
"""

static var scene_9: String = """
Did you anger some wizard or something? Is this why you are here?
Were you human once? Or are you just some random enchanted stick?
You start to wonder, is the mind of a stick stuck in a human body somewhere?
Still a better story than Rob Schneider in The Hot Chick (2002). Yes, I said it.
"""

static var scene_10: String = """
If you had hands, you would pinch yourself. But you do not.
So how do you know if this is real?
Is this a game? Are you the game?
Who is playing you? Are they good at it? … Probably not.
"""

static var scene_11: String = """
Does any of this matter? You are unstoppable now.
Simple creatures are not even worth your time. You crave… more.
You do not need me anymore. Are you finally questioning who I am? I think you know the answer to that one.
"""

@export var typing_speed: float = 0.07

@onready var text_label: Label =  $VBoxContainer/Text

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var next_scene_text: String = ""
var current_text: String = ""
var current_text_index: int = 0
var is_typing: bool = false

var time_since_last_scribble = 0.0

signal start_battle_scene_signal

func start_typing_effect() -> void:
	current_text = ""
	current_text_index = 0
	is_typing = true
	audio_player.play()
	set_process(true)

func stop_typing_effect() -> void:
	current_text = next_scene_text
	text_label.text = current_text
	is_typing = false
	audio_player.stop()
	set_process(false)

func _ready() -> void:
	var scene_text = GameState.get_next_scene_text()
	
	# If we're just starting or if there's no new scene text
	if not GameState.started or scene_text == "":
		# Only show opening monologue if we haven't shown it before
		if not GameState.shown_scenes.has(0):
			GameState.shown_scenes.append(0)
			next_scene_text = opening_monologue
			start_typing_effect()
		else:
			hide()
			emit_signal("start_battle_scene_signal")
			return
	else:
		next_scene_text = scene_text
		start_typing_effect()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		stop_typing_effect()

	time_since_last_scribble += delta

	if is_typing && time_since_last_scribble > typing_speed:
		if current_text_index < next_scene_text.length():
			current_text += next_scene_text[current_text_index]
			text_label.text = current_text
			current_text_index += 1
			time_since_last_scribble = 0
		else:
			current_text = ""
			current_text_index = 0

	if current_text_index == next_scene_text.length() - 1:
		stop_typing_effect()
