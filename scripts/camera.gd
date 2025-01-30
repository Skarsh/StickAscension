extends Camera2D

@export var radius = 10.0  # Circle radius
@export var speed = 2.0    # Rotation speed

var angle = 0.0
var random_shake_strength: float = 30.0
var slam_shake_strength: float = 60.0  # Stronger shake for slams
var shake_fade: float = 8.0
var shake_strength: float = 0.0
var shake_started: bool = false
var circle_offset: Vector2 = Vector2.ZERO
var default_zoom = Vector2(1, 1)

func start_shake(is_slam: bool = false) -> void:
	shake_started = true
	shake_strength = slam_shake_strength if is_slam else random_shake_strength

func zoom_out(amount: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "zoom", default_zoom * amount, duration)
	
func zoom_reset(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "zoom", default_zoom, duration)

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