extends CharacterBody2D

var speed = 300
var velocity_vector = Vector2(1, -1)

signal ball_fell
signal hit_paddle

func _ready():
	velocity = velocity_vector.normalized() * speed

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		velocity = velocity.bounce(collision.get_normal())
		
		if collider.name == "Paddle":
			var paddle = collider
			var paddle_center = paddle.position.x
			var ball_x = position.x
			var diff = ball_x - paddle_center
			var bounce_angle = diff / 60
			bounce_angle = clamp(bounce_angle, -0.8, 0.8)
			velocity = Vector2(bounce_angle, -1).normalized() * speed
			hit_paddle.emit()
		elif collider.has_method("hit"):
			collider.hit()
	
	var screen_size = get_viewport_rect().size
	
	if position.x <= 10 or position.x >= screen_size.x - 10:
		velocity.x = -velocity.x
	
	if position.y <= 10:
		velocity.y = -velocity.y
	
	if position.y > screen_size.y + 20:
		ball_fell.emit()
		queue_free()
