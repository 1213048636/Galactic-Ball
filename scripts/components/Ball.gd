extends CharacterBody2D

var base_speed = 300
var current_speed_multiplier = 1.0
var max_speed_multiplier = 2.0  # 200% 速度
var speed_decay_rate = 0.5  # 每秒衰减 0.5 倍（2秒回到正常速度）

# 穿透模式参数
var is_piercing = false
var pierce_duration = 5.0  # 持续5秒
var pierce_timer = 0.0
var max_pierce_count = 3   # 最多穿透3个砖块
var pierce_count = 0

signal ball_fell
signal hit_paddle

func _ready():
	var random_angle = randf_range(-PI / 3, PI / 3)
	var direction = Vector2(sin(random_angle), -cos(random_angle))
	velocity = direction * base_speed

func _physics_process(delta):
	# 速度衰减
	if current_speed_multiplier > 1.0:
		current_speed_multiplier -= speed_decay_rate * delta
		current_speed_multiplier = max(current_speed_multiplier, 1.0)
		velocity = velocity.normalized() * base_speed * current_speed_multiplier
	
	# 穿透模式计时
	if is_piercing:
		pierce_timer -= delta
		if pierce_timer <= 0 or pierce_count >= max_pierce_count:
			deactivate_piercing()
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		if collider.name == "Paddle":
			velocity = velocity.bounce(normal)
			hit_paddle.emit()
			
			# 检查是否碰到红色挡板
			if collider.has_method("is_red_paddle"):
				if collider.is_red_paddle():
					apply_speed_boost()
		else:
			# 检查砖块颜色效果
			if collider.has_method("get_brick_color"):
				var brick_color = collider.get_brick_color()
				if is_red_brick(brick_color):
					apply_speed_boost()
				elif is_green_brick(brick_color):
					# 绿色砖块触发穿透模式
					activate_piercing()
			
			# 穿透模式处理
			if is_piercing and collider.has_method("hit"):
				# 穿透砖块，不反弹，只销毁砖块
				pierce_count += 1
				collider.hit()
				# 不执行 bounce，保持原方向
			else:
				# 正常反弹
				velocity = velocity.bounce(normal)
				if collider.has_method("hit"):
					collider.hit()
	
	# 限制在左半边游戏区域 (640px)
	var game_area_width = 640.0
	var game_area_height = 720.0
	
	# 左右边界反弹
	if position.x <= 10:
		position.x = 10
		velocity.x = abs(velocity.x)
	elif position.x >= game_area_width - 10:
		position.x = game_area_width - 10
		velocity.x = -abs(velocity.x)
	
	# 上边界反弹
	if position.y <= 10:
		position.y = 10
		velocity.y = abs(velocity.y)
	
	# 下边界掉落
	if position.y > game_area_height + 20:
		ball_fell.emit()
		queue_free()

func is_red_brick(color: Color) -> bool:
	# 红色砖块：R值高，G和B值低
	return color.r > 0.7 and color.g < 0.5 and color.b < 0.5

func is_green_brick(color: Color) -> bool:
	# 绿色砖块：G值高，R和B值低
	return color.g > 0.7 and color.r < 0.5 and color.b < 0.5

func activate_piercing():
	is_piercing = true
	pierce_timer = pierce_duration
	pierce_count = 0
	$OuterGlow.modulate = Color(0.2, 1, 0.4, 1)
	$InnerGlow.modulate = Color(0.4, 1, 0.6, 1)
	$Core.modulate = Color(0.6, 1, 0.8, 1)
	$FireTrail.modulate = Color(0.3, 1, 0.3, 1)

func deactivate_piercing():
	is_piercing = false
	pierce_timer = 0.0
	pierce_count = 0
	$OuterGlow.modulate = Color(1, 0.5, 0.2, 1)
	$InnerGlow.modulate = Color(1, 0.9, 0.6, 1)
	$Core.modulate = Color(1, 1, 0.95, 1)
	$FireTrail.modulate = Color(1, 1, 1, 1)

func apply_speed_boost():
	current_speed_multiplier = max_speed_multiplier
	velocity = velocity.normalized() * base_speed * current_speed_multiplier
