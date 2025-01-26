extends Camera2D

@export var radius = 10.0  # Circle radius
@export var speed = 2.0    # Rotation speed

var angle = 0.0

func _process(delta):
	angle += speed * delta
	offset = Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)