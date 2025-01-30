extends Camera2D

@export var radius = 10.0  # Circle radius
@export var speed = 2.0    # Rotation speed

var angle = 0.0
var random_shake_strength: float = 30.0
var shake_fade: float = 8.0
var shake_strength: float = 0.0
var shake_started: bool = false
var circle_offset: Vector2 = Vector2.ZERO

func start_shake():
	shake_started = true
	shake_strength = random_shake_strength

func random_offset() -> Vector2:
	return Vector2(randf_range(-shake_strength, shake_strength), 
				  randf_range(-shake_strength, shake_strength))

func _process(delta):
	# Calculate circular motion
	angle += speed * delta
	circle_offset = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)
	
	# Handle shake effect
	if shake_started:
		if shake_strength > 0:
			shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
			# Combine circular motion with shake
			offset = circle_offset + random_offset()
		else:
			shake_started = false
	else:
		# Just circular motion when not shaking
		offset = circle_offset