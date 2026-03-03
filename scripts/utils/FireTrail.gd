extends GPUParticles2D

func _process(_delta):
	if get_parent():
		global_position = get_parent().global_position
