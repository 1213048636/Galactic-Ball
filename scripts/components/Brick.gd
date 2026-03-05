extends StaticBody2D

signal brick_destroyed

# 颜色定义
var white_color = Color(0.95, 0.95, 0.95, 0.8)   # 白色 - 70%
var red_color = Color(0.9, 0.2, 0.2, 0.8)        # 红色 - 10% - 触发加速
var green_color = Color(0.2, 0.9, 0.3, 0.8)      # 绿色 - 20%
var yellow_color = Color(0.95, 0.85, 0.1, 0.8)   # 黄色 - 带生命值

var current_color: Color = Color.WHITE

# 生命值系统（仅黄色砖块）
var max_health: int = 1
var current_health: int = 1
var is_yellow: bool = false

@onready var health_label = $HealthLabel

func _ready():
	update_health_display()

func set_random_color():
	var random_value = randf()
	if random_value < 0.7:
		# 70% 白色
		current_color = white_color
	elif random_value < 0.8:
		# 10% 红色 (0.7 - 0.8)
		current_color = red_color
	else:
		# 20% 绿色 (0.8 - 1.0)
		current_color = green_color
	
	is_yellow = false
	update_color_display()

func set_color_by_type(color_type: String):
	match color_type:
		"white":
			current_color = white_color
			is_yellow = false
		"red":
			current_color = red_color
			is_yellow = false
		"green":
			current_color = green_color
			is_yellow = false
		"yellow":
			current_color = yellow_color
			is_yellow = true
	
	update_color_display()
	update_health_display()

func set_yellow_brick(health: int):
	current_color = yellow_color
	is_yellow = true
	max_health = health
	current_health = health
	update_color_display()
	update_health_display()

func update_color_display():
	$ColorRect.color = Color(current_color.r, current_color.g, current_color.b, 0.3)

func update_health_display():
	if health_label:
		if is_yellow and current_health > 0:
			health_label.text = str(current_health)
			health_label.visible = true
		else:
			health_label.visible = false

func get_brick_color() -> Color:
	return current_color

func is_yellow_brick() -> bool:
	return is_yellow

func hit():
	if is_yellow:
		# 黄色砖块处理生命值
		current_health -= 1
		update_health_display()
		
		if current_health <= 0:
			# 生命值归零，变成白色砖块
			set_color_by_type("white")
			spawn_glass_shards()
			return
		else:
			# 还有生命值，播放受击效果
			spawn_glass_shards()
			return
	
	# 普通砖块直接销毁
	spawn_glass_shards()
	queue_free()
	brick_destroyed.emit()

func spawn_glass_shards():
	var shards_scene = preload("res://scenes/system/GlassShards.tscn")
	var shards = shards_scene.instantiate()
	shards.position = position + Vector2(30, 12.5)
	get_parent().add_child(shards)
