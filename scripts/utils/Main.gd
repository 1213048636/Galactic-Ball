extends Node2D

const SaveManager = preload("res://scripts/utils/SaveManager.gd")

var ball_scene = preload("res://scenes/actors/player/Ball.tscn")
var brick_scene = preload("res://scenes/actors/enemies/Brick.tscn")
var explosion_scene = preload("res://scenes/system/ExplosionParticles.tscn")

var score = 0
var game_over = false
var original_camera_pos = Vector2.ZERO

# 存档管理器
var save_manager: SaveManager

# 最高分显示标签
@onready var high_score_label = $InfoPanel/HighScoreLabel

# 游戏区域设置
var game_area_width = 640  # 左半边宽度

# 砖块下移参数
var brick_move_timer = 0.0
var brick_move_interval = 3.0
var brick_move_speed = 0.5
var brick_row_height = 35

# 能量条系统
var max_energy = 100.0
var current_energy = 100.0
var energy_regen_rate = 10.0
var energy_drain_rate = 20.0
var is_using_skill_j = false
var is_using_skill_k = false
var is_using_skill_l = false

# 自动发射球系统
var auto_spawn_timer = 0.0
var auto_spawn_interval = 1.0  # 每秒发射一个

@onready var score_label = $InfoPanel/ScoreSection/ScoreLabel
@onready var game_over_label = $InfoPanel/GameOverLabel
@onready var camera = $Camera2D
@onready var energy_bar = $InfoPanel/EnergySection/EnergyBar
@onready var paddle = $GameArea/Paddle
@onready var game_over_overlay = $GameArea/GameOverOverlay

func _ready():
	# 初始化存档管理器
	save_manager = SaveManager.new()
	add_child(save_manager)
	
	original_camera_pos = camera.position
	create_bricks()
	spawn_ball()
	update_energy_display()
	update_high_score_display()

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("restart"):
			restart_game()
		return
	
	handle_skills(delta)
	
	# 自动发射球
	auto_spawn_timer += delta
	if auto_spawn_timer >= auto_spawn_interval:
		auto_spawn_timer = 0.0
		spawn_ball_at_paddle()
	
	brick_move_timer += delta
	if brick_move_timer >= brick_move_interval:
		brick_move_timer = 0.0
		move_bricks_down()

func handle_skills(delta):
	var j_pressed = Input.is_action_pressed("skill_j")
	var k_pressed = Input.is_action_pressed("skill_k")
	var l_just_pressed = Input.is_action_just_pressed("skill_l")
	
	# 处理L键技能（将所有黄色砖块变成白色）
	if l_just_pressed and current_energy >= max_energy:
		convert_yellow_bricks_to_white()
	
	if current_energy > 0:
		is_using_skill_j = j_pressed
		is_using_skill_k = k_pressed
		
		var energy_cost = 0.0
		if is_using_skill_j:
			energy_cost += energy_drain_rate * delta
		if is_using_skill_k:
			energy_cost += energy_drain_rate * delta
		
		current_energy -= energy_cost
		current_energy = max(current_energy, 0)
		
		if current_energy <= 0:
			is_using_skill_j = false
			is_using_skill_k = false
	else:
		is_using_skill_j = false
		is_using_skill_k = false
	
	if not is_using_skill_j and not is_using_skill_k:
		current_energy += energy_regen_rate * delta
		current_energy = min(current_energy, max_energy)
	
	if paddle:
		if is_using_skill_j:
			paddle.update_skill_j(true)
		elif not is_using_skill_k:
			paddle.update_skill_j(false)
		
		paddle.update_skill_k(is_using_skill_k, delta)
	
	update_energy_display()

func spawn_new_ball():
	# 清空能量条
	current_energy = 0.0
	
	# 发射一颗新球，从挡板中央发射
	spawn_ball_at_paddle()
	
	# 播放发射特效
	spawn_explosion(paddle.position + Vector2(0, -20))
	screen_shake()

func convert_yellow_bricks_to_white():
	# 清空能量条
	current_energy = 0.0
	
	# 将所有黄色砖块变成白色
	var game_area = $GameArea
	var converted_count = 0
	
	for child in game_area.get_children():
		if child.has_method("hit") and child.name != "Paddle":
			# 检查是否是黄色砖块
			if child.is_yellow_brick():
				child.convert_to_white()
				converted_count += 1
	
	# 如果有砖块被转换，播放特效
	if converted_count > 0:
		screen_shake()
		print("转换了 ", converted_count, " 个黄色砖块为白色")

func spawn_ball_at_paddle():
	# 从挡板中央发射一颗新球
	var game_area = $GameArea
	var new_ball = ball_scene.instantiate()
	new_ball.position = paddle.position + Vector2(0, -20)
	game_area.add_child(new_ball)
	new_ball.connect("hit_paddle", _on_hit_paddle)
	
	# 设置竖直向上发射
	new_ball.velocity = Vector2(0, -new_ball.base_speed)

func update_energy_display():
	if energy_bar:
		energy_bar.value = current_energy

func create_bricks():
	var brick_width = 60
	var brick_height = 25
	var spacing = 10
	var columns = 8  # 8列，左右各加一列
	var rows = 8
	
	# 计算总宽度并居中
	var total_width = columns * brick_width + (columns - 1) * spacing
	var start_x = (640.0 - total_width) / 2.0  # 在游戏区域(640px)内居中
	var start_y = 60
	
	var game_area = $GameArea
	
	for row in range(rows):
		for col in range(columns):
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + col * (brick_width + spacing),
				start_y + row * (brick_height + spacing)
			)
			game_area.add_child(brick)
			brick.set_random_color()
			brick.connect("brick_destroyed", _on_brick_destroyed.bind(brick.position))

func move_bricks_down():
	var game_area = $GameArea
	var _brick_count = 0
	for child in game_area.get_children():
		if child.has_method("hit") and child.name != "Paddle" and child.name != "Ball":
			child.position.y += brick_row_height
			_brick_count += 1
			
			if child.position.y >= 580:
				game_over = true
				if game_over_overlay:
					game_over_overlay.visible = true
				check_and_save_high_score()
				return
	
	spawn_new_brick_row()

func spawn_new_brick_row():
	var brick_width = 60
	var _brick_height = 25
	var spacing = 10
	var columns = 8  # 8列
	
	# 计算总宽度并居中
	var total_width = columns * brick_width + (columns - 1) * spacing
	var start_x = (640.0 - total_width) / 2.0
	var start_y = 60
	
	var game_area = $GameArea
	
	# 计算当前应该生成的黄色砖块生命值
	var yellow_health = calculate_yellow_brick_health()
	
	# 决定这一排生成多少个黄色砖块（1-3个）
	var yellow_count = randi() % 3 + 1  # 1-3个
	var yellow_positions = []
	
	# 随机选择黄色砖块的位置
	while yellow_positions.size() < yellow_count:
		var pos = randi() % columns
		if not yellow_positions.has(pos):
			yellow_positions.append(pos)
	
	for col in range(columns):
		if randf() < 0.8:
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + col * (brick_width + spacing),
				start_y
			)
			game_area.add_child(brick)
			
			# 检查是否是黄色砖块位置
			if yellow_positions.has(col):
				# 生成黄色砖块，带生命值
				brick.set_yellow_brick(yellow_health)
			else:
				brick.set_random_color()
			
			brick.connect("brick_destroyed", _on_brick_destroyed.bind(brick.position))

func calculate_yellow_brick_health() -> int:
	# 计算当前应该生成的黄色砖块生命值
	# 基于当前分数，分数越高生命值越高
	
	# 基础生命值2
	var base_health = 2
	
	# 每100分增加1点生命值
	var bonus_health = score / 100.0
	
	# 计算总生命值
	var health = base_health + bonus_health
	
	return max(health, 2)  # 至少2点生命值

func spawn_ball():
	var game_area = $GameArea
	
	# 生成第一个球
	var ball1 = ball_scene.instantiate()
	ball1.position = Vector2(game_area_width / 2.0 - 30, 580)
	game_area.add_child(ball1)
	ball1.connect("hit_paddle", _on_hit_paddle)
	
	# 生成第二个球（测试多球情况）
	var ball2 = ball_scene.instantiate()
	ball2.position = Vector2(game_area_width / 2.0 + 30, 580)
	game_area.add_child(ball2)
	ball2.connect("hit_paddle", _on_hit_paddle)

func _on_hit_paddle():
	screen_shake()

func _on_brick_destroyed(brick_pos):
	score += 10
	score_label.text = str(score)
	
	spawn_explosion(brick_pos)
	spawn_score_popup(brick_pos, "+10")
	screen_shake()

func get_brick_count():
	var game_area = $GameArea
	var count = 0
	for child in game_area.get_children():
		if child.has_method("hit") and child.name != "Paddle" and child.name != "Ball":
			count += 1
	return count

func spawn_explosion(pos):
	var game_area = $GameArea
	var explosion = explosion_scene.instantiate()
	explosion.position = pos
	game_area.add_child(explosion)

func spawn_score_popup(pos, text):
	var game_area = $GameArea
	var popup = Label.new()
	popup.text = text
	popup.position = pos
	game_area.add_child(popup)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(popup, "position:y", pos.y - 50, 0.8)
	tween.tween_property(popup, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(popup.queue_free)

func screen_shake():
	var shake_amount = 5
	var shake_duration = 0.1
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(camera, "position", original_camera_pos + Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount)), shake_duration / 3)
	tween.tween_property(camera, "position", original_camera_pos, shake_duration / 3)

func _on_ball_fell():
	# 小球掉落不再导致游戏结束，改为重置小球
	pass

func restart_game():
	# 重置游戏状态
	game_over = false
	score = 0
	score_label.text = "0"
	current_energy = max_energy
	update_energy_display()
	
	# 隐藏游戏结束覆盖层
	if game_over_overlay:
		game_over_overlay.visible = false
	
	# 清除所有砖块和球
	var game_area = $GameArea
	for child in game_area.get_children():
		# 清除砖块（有hit方法）、球（CharacterBody2D类型且不是Paddle）、爆炸效果、分数弹出标签
		var is_ball = child is CharacterBody2D and child.name != "Paddle"
		var is_brick = child.has_method("hit") and child.name != "Paddle"
		var is_explosion = child.name.find("Explosion") != -1
		var is_popup_label = child is Label and child.name != "WarningLine"
		
		if is_brick or is_ball or is_explosion or is_popup_label:
			child.queue_free()
	
	# 重置挡板
	if paddle:
		paddle.position = Vector2(320, 680)
		paddle.update_skill_j(false)
		paddle.update_skill_k(false, 0)
	
	# 重置相机
	camera.position = original_camera_pos
	
	# 重新生成砖块和球
	create_bricks()
	spawn_ball()
	
	# 重置计时器
	brick_move_timer = 0.0

func update_high_score_display():
	if save_manager and high_score_label:
		var high_score = save_manager.get_high_score()
		high_score_label.text = "最高分: " + str(high_score)

func check_and_save_high_score():
	if save_manager:
		save_manager.set_high_score(score)
		update_high_score_display()
