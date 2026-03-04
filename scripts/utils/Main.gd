extends Node2D

var ball_scene = preload("res://scenes/actors/player/Ball.tscn")
var brick_scene = preload("res://scenes/actors/enemies/Brick.tscn")
var explosion_scene = preload("res://scenes/system/ExplosionParticles.tscn")

var score = 0
var game_over = false
var original_camera_pos = Vector2.ZERO

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

@onready var score_label = $InfoPanel/ScoreSection/ScoreLabel
@onready var game_over_label = $InfoPanel/GameOverLabel
@onready var camera = $Camera2D
@onready var energy_bar = $InfoPanel/EnergySection/EnergyBar
@onready var paddle = $GameArea/Paddle
@onready var game_over_overlay = $GameArea/GameOverOverlay

func _ready():
	original_camera_pos = camera.position
	create_bricks()
	spawn_ball()
	update_energy_display()

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("restart"):
			restart_game()
		return
	
	handle_skills(delta)
	
	brick_move_timer += delta
	if brick_move_timer >= brick_move_interval:
		brick_move_timer = 0.0
		move_bricks_down()

func handle_skills(delta):
	var j_pressed = Input.is_action_pressed("skill_j")
	var k_pressed = Input.is_action_pressed("skill_k")
	var l_just_pressed = Input.is_action_just_pressed("skill_l")
	
	# 处理L键技能（瞬间清空能量条，清除最下面一排砖头）
	if l_just_pressed and current_energy >= max_energy:
		use_skill_l()
	
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

func use_skill_l():
	# 清空能量条
	current_energy = 0.0
	
	# 找到并清除最下面一排砖头
	var game_area = $GameArea
	var bricks = []
	
	# 收集所有砖头
	for child in game_area.get_children():
		if child.has_method("hit") and child.name != "Paddle" and child.name != "Ball":
			bricks.append(child)
	
	if bricks.size() == 0:
		return
	
	# 找到最下面一排的Y坐标
	var max_y = bricks[0].position.y
	for brick in bricks:
		if brick.position.y > max_y:
			max_y = brick.position.y
	
	# 清除最下面一排的砖头
	var destroyed_count = 0
	for brick in bricks:
		if abs(brick.position.y - max_y) < 5:  # 允许小误差
			spawn_explosion(brick.position)
			brick.queue_free()
			destroyed_count += 1
	
	# 增加分数
	if destroyed_count > 0:
		var points = destroyed_count * 10
		score += points
		score_label.text = str(score)
		screen_shake()

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
	var start_x = (640 - total_width) / 2  # 在游戏区域(640px)内居中
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
	var brick_count = 0
	for child in game_area.get_children():
		if child.has_method("hit") and child.name != "Paddle" and child.name != "Ball":
			child.position.y += brick_row_height
			brick_count += 1
			
			if child.position.y >= 580:
				game_over = true
				if game_over_overlay:
					game_over_overlay.visible = true
				return
	
	spawn_new_brick_row()

func spawn_new_brick_row():
	var brick_width = 60
	var brick_height = 25
	var spacing = 10
	var columns = 8  # 8列
	
	# 计算总宽度并居中
	var total_width = columns * brick_width + (columns - 1) * spacing
	var start_x = (640 - total_width) / 2
	var start_y = 60
	
	var game_area = $GameArea
	
	for col in range(columns):
		if randf() < 0.8:
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + col * (brick_width + spacing),
				start_y
			)
			game_area.add_child(brick)
			brick.set_random_color()
			brick.connect("brick_destroyed", _on_brick_destroyed.bind(brick.position))

func spawn_ball():
	var game_area = $GameArea
	
	# 生成第一个球
	var ball1 = ball_scene.instantiate()
	ball1.position = Vector2(game_area_width / 2 - 30, 580)
	game_area.add_child(ball1)
	ball1.connect("ball_fell", _on_ball_fell)
	ball1.connect("hit_paddle", _on_hit_paddle)
	
	# 生成第二个球（测试多球情况）
	var ball2 = ball_scene.instantiate()
	ball2.position = Vector2(game_area_width / 2 + 30, 580)
	game_area.add_child(ball2)
	ball2.connect("ball_fell", _on_ball_fell)
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
	# 检查是否还有球在场
	var game_area = $GameArea
	var ball_count = 0
	for child in game_area.get_children():
		if child.is_in_group("balls"):
			ball_count += 1
	
	# 只有当所有球都掉完才游戏结束
	if not game_over and ball_count == 0:
		game_over = true
		if game_over_overlay:
			game_over_overlay.visible = true
		screen_shake()

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
	
	# 清除所有砖块
	var game_area = $GameArea
	for child in game_area.get_children():
		if child.has_method("hit") or child.name == "Ball" or child.name.find("Explosion") != -1 or child is Label:
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
