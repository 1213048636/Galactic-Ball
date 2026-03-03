extends StaticBody2D

signal brick_destroyed

# 颜色定义
var white_color = Color(0.95, 0.95, 0.95, 0.8)   # 白色 - 70%
var red_color = Color(0.9, 0.2, 0.2, 0.8)        # 红色 - 10% - 触发加速
var green_color = Color(0.2, 0.9, 0.3, 0.8)      # 绿色 - 20%

var current_color: Color = Color.WHITE

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
	
	$ColorRect.color = Color(current_color.r, current_color.g, current_color.b, 0.3)

func set_color_by_type(color_type: String):
	match color_type:
		"white":
			current_color = white_color
		"red":
			current_color = red_color
		"green":
			current_color = green_color
	
	$ColorRect.color = Color(current_color.r, current_color.g, current_color.b, 0.3)

func get_brick_color() -> Color:
	return current_color

func hit():
	spawn_glass_shards()
	queue_free()
	brick_destroyed.emit()

func spawn_glass_shards():
	var shards_scene = preload("res://scenes/system/GlassShards.tscn")
	var shards = shards_scene.instantiate()
	shards.position = position + Vector2(30, 12.5)
	get_parent().add_child(shards)
