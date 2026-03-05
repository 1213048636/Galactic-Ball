extends Node2D

var sprite: Sprite2D

func _ready():
	# 创建 Sprite2D 节点
	sprite = Sprite2D.new()
	add_child(sprite)
	
	# 生成像素角色纹理
	var generator = preload("res://scripts/utils/PixelCharacterGenerator.gd").new()
	var texture = generator.generate_character()
	sprite.texture = texture
	
	# 放大显示（2倍）
	sprite.scale = Vector2(2, 2)
	
	# 可选：保存为文件
	# generator.save_character("res://assets/images/astronaut_portrait.png")
