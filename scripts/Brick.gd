extends StaticBody2D

signal brick_destroyed

var glass_colors = [
	Color(0.9, 0.3, 0.3, 0.8),
	Color(0.9, 0.6, 0.2, 0.8),
	Color(0.9, 0.9, 0.2, 0.8),
	Color(0.3, 0.9, 0.3, 0.8),
	Color(0.3, 0.6, 0.9, 0.8)
]

func set_color(row_index):
	var base_color = glass_colors[row_index % glass_colors.size()]
	$ColorRect.color = Color(base_color.r, base_color.g, base_color.b, 0.3)

func hit():
	spawn_glass_shards()
	queue_free()
	brick_destroyed.emit()

func spawn_glass_shards():
	var shards_scene = preload("res://scenes/GlassShards.tscn")
	var shards = shards_scene.instantiate()
	shards.position = position + Vector2(30, 12.5)
	get_parent().add_child(shards)
