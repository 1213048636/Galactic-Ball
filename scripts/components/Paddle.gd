extends CharacterBody2D

const SPEED = 500

var normal_color = Color(0.3, 0.6, 0.9, 1.0)  # 正常蓝色
var skill_j_color = Color(0.9, 0.2, 0.2, 1.0)  # J技能红色
var skill_k_color = Color(0.2, 0.9, 0.2, 1.0)  # K技能绿色

# 挡板长度参数
var normal_width = 120.0
var max_width = 240.0
var extend_rate = 60.0  # 每秒伸长60像素
var shrink_rate = 120.0  # 每秒缩回120像素（更快）
var current_width = 120.0

@onready var color_rect = $ColorRect
@onready var collision_shape = $CollisionShape2D

func _ready():
	# 保存初始颜色
	if color_rect:
		normal_color = color_rect.color
	current_width = normal_width

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
	
	# 限制在左半边游戏区域 (640px)
	var game_area_width = 640.0
	var paddle_width = current_width
	
	if position.x < paddle_width / 2:
		position.x = paddle_width / 2
	elif position.x > game_area_width - paddle_width / 2:
		position.x = game_area_width - paddle_width / 2

func update_skill_j(active: bool):
	# J技能：变红
	if active:
		if color_rect:
			color_rect.color = skill_j_color
	else:
		if color_rect:
			color_rect.color = normal_color

func update_skill_k(active: bool, delta: float):
	# K技能：瞬间变长/恢复
	if active:
		current_width = max_width
	else:
		current_width = normal_width
	
	# 更新挡板尺寸
	update_paddle_size()

func update_paddle_size():
	if color_rect:
		color_rect.size.x = current_width
		# 居中显示
		color_rect.position.x = -current_width / 2
	
	if collision_shape:
		var shape = collision_shape.shape
		if shape is RectangleShape2D:
			shape.size.x = current_width
			collision_shape.position.x = 0

func is_red_paddle() -> bool:
	if color_rect:
		return color_rect.color == skill_j_color
	return false
