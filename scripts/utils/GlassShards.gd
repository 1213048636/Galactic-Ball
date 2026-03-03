extends GPUParticles2D

func _ready():
	$Timer.timeout.connect(_on_timer_timeout)
	emitting = true

func _on_timer_timeout():
	queue_free()
