extends Camera2D

# Screen shake variables
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_decay: float = 0.0

func _process(delta: float) -> void:
    if shake_duration > 0:
        # Apply random offset to the camera
        offset = Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
        
        # Reduce shake intensity over time
        shake_duration -= delta
        shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
    else:
        # Reset the camera offset when shaking is done
        offset = Vector2.ZERO

# Function to start the screen shake
func start_shake(intensity: float, duration: float, decay: float = 2.0) -> void:
    shake_intensity = intensity
    shake_duration = duration
    shake_decay = decay