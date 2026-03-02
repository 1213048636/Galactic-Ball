extends Node2D

var ball_scene = preload("res://scenes/Ball.tscn")
var brick_scene = preload("res://scenes/Brick.tscn")
var explosion_scene = preload("res://scenes/ExplosionParticles.tscn")

var score = 0
var game_over = false
var original_camera_pos = Vector2.ZERO

@onready var score_label = $UILayer/ScoreLabel
@onready var game_over_label = $UILayer/GameOverLabel
@onready var camera = $Camera2D

func _ready():
	original_camera_pos = camera.position
	create_bricks()
	spawn_ball()

func create_bricks():
	var brick_width = 60
	var brick_height = 25
	var spacing = 10
	var start_x = 50
	var start_y = 80
	var columns = 15
	var rows = 5
	
	for row in range(rows):
		for col in range(columns):
			var brick = brick_scene.instantiate()
			brick.position = Vector2(
				start_x + col * (brick_width + spacing),
				start_y + row * (brick_height + spacing)
			)
			add_child(brick)
			brick.set_color(row)
			brick.connect("brick_destroyed", _on_brick_destroyed.bind(brick.position))

func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.position = Vector2(576, 550)
	add_child(ball)
	ball.connect("ball_fell", _on_ball_fell)
	ball.connect("hit_paddle", _on_hit_paddle)

func _on_hit_paddle():
	screen_shake()

func _on_brick_destroyed(brick_pos):
	score += 10
	score_label.text = "Score: " + str(score)
	
	spawn_explosion(brick_pos)
	spawn_score_popup(brick_pos, "+10")
	screen_shake()
	
	if get_brick_count() == 0:
		win_game()

func get_brick_count():
	var count = 0
	for child in get_children():
		if child.has_method("hit") and child.name != "Paddle" and child.name != "Ball":
			count += 1
	return count

func spawn_explosion(pos):
	var explosion = explosion_scene.instantiate()
	explosion.position = pos
	add_child(explosion)

func spawn_score_popup(pos, text):
	var popup = Label.new()
	popup.text = text
	popup.position = pos
	add_child(popup)
	
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
	if not game_over:
		game_over = true
		game_over_label.visible = true
		screen_shake()

func win_game():
	game_over = true
	game_over_label.text = "You Win!\nPress R to Restart"
	game_over_label.visible = true

func _input(event):
	if game_over and event.is_action_pressed("restart"):
		restart_game()

func restart_game():
	game_over = false
	score = 0
	score_label.text = "Score: 0"
	game_over_label.visible = false
	
	for child in get_children():
		if child.name == "Ball" or child.has_method("hit") or child is GPUParticles2D or child is Label:
			child.queue_free()
	
	create_bricks()
	spawn_ball()