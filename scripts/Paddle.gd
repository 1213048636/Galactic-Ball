extends CharacterBody2D

const SPEED = 500

func _physics_process(delta):
	var direction = 0
	
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	velocity.x = direction * SPEED
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		pass
	
	var screen_size = get_viewport_rect().size
	var paddle_width = $ColorRect.size.x
	
	if position.x < paddle_width / 2:
		position.x = paddle_width / 2
	elif position.x > screen_size.x - paddle_width / 2:
		position.x = screen_size.x - paddle_width / 2
