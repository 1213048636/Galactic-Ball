extends Node2D

func _ready():
	$TwinkleTimer.timeout.connect(_on_twinkle_timer_timeout)
	create_static_stars()

func create_static_stars():
	for i in range(50):
		var star = ColorRect.new()
		star.size = Vector2(randf_range(1, 3), randf_range(1, 3))
		star.position = Vector2(randf_range(0, 1152), randf_range(0, 648))
		star.color = Color(1, 1, 1, randf_range(0.3, 1))
		star.name = "Star" + str(i)
		add_child(star)

func _on_twinkle_timer_timeout():
	for child in get_children():
		if child.name.begins_with("Star"):
			if randf() < 0.1:
				var tween = create_tween()
				var target_alpha = randf_range(0.2, 1.0)
				tween.tween_property(child, "color:a", target_alpha, 0.5)
