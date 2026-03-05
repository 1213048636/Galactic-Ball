extends Node

# 像素太空人角色生成器
# 生成复杂的像素风格太空人立绘

const TEXTURE_SIZE = 128

# 太空人颜色定义
const SUIT_WHITE = Color(0.95, 0.95, 0.98)
const SUIT_GRAY = Color(0.75, 0.78, 0.82)
const SUIT_DARK = Color(0.5, 0.55, 0.6)
const HELMET_GLASS = Color(0.2, 0.5, 0.8, 0.6)
const HELMET_FRAME = Color(0.7, 0.75, 0.8)
const VISOR_REFLECTION = Color(0.6, 0.8, 1.0, 0.4)
const BACKPACK_MAIN = Color(0.6, 0.65, 0.7)
const BACKPACK_DETAIL = Color(0.4, 0.45, 0.5)
const GLOVES = Color(0.3, 0.35, 0.4)
const BOOTS = Color(0.25, 0.3, 0.35)
const SKIN_COLOR = Color(0.95, 0.8, 0.7)
const EYE_COLOR = Color(0.2, 0.15, 0.1)
const OUTLINE_COLOR = Color(0.15, 0.18, 0.22)
const ACCENT_BLUE = Color(0.2, 0.6, 0.9)
const ACCENT_ORANGE = Color(0.95, 0.5, 0.2)

func generate_character() -> ImageTexture:
	var image = Image.create(TEXTURE_SIZE, TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	
	# 中心偏移，让角色居中
	var cx = TEXTURE_SIZE / 2
	var cy = TEXTURE_SIZE / 2 + 10
	
	# 绘制太空人
	draw_astronaut(image, cx, cy)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func draw_astronaut(image: Image, cx: int, cy: int):
	# 绘制背包（在背后）
	draw_rounded_rect(image, cx - 28, cy - 35, 56, 70, 8, BACKPACK_MAIN)
	draw_rounded_rect(image, cx - 22, cy - 30, 44, 60, 6, BACKPACK_DETAIL)
	# 背包上的细节条纹
	draw_rect_pixels(image, cx - 28, cy - 15, 56, 4, ACCENT_BLUE)
	draw_rect_pixels(image, cx - 28, cy + 5, 56, 4, ACCENT_ORANGE)
	
	# 绘制腿部（左）
	draw_rounded_rect(image, cx - 22, cy + 25, 18, 35, 6, SUIT_WHITE)
	draw_rounded_rect(image, cx - 20, cy + 45, 14, 20, 4, SUIT_GRAY)
	# 靴子（左）
	draw_rounded_rect(image, cx - 24, cy + 58, 22, 12, 4, BOOTS)
	draw_rounded_rect(image, cx - 22, cy + 68, 18, 8, 3, BOOTS)
	
	# 绘制腿部（右）
	draw_rounded_rect(image, cx + 4, cy + 25, 18, 35, 6, SUIT_WHITE)
	draw_rounded_rect(image, cx + 6, cy + 45, 14, 20, 4, SUIT_GRAY)
	# 靴子（右）
	draw_rounded_rect(image, cx + 2, cy + 58, 22, 12, 4, BOOTS)
	draw_rounded_rect(image, cx + 4, cy + 68, 18, 8, 3, BOOTS)
	
	# 绘制身体
	draw_rounded_rect(image, cx - 25, cy - 10, 50, 45, 10, SUIT_WHITE)
	# 胸部细节
	draw_rounded_rect(image, cx - 15, cy - 5, 30, 25, 5, SUIT_GRAY)
	# 控制面板
	draw_rounded_rect(image, cx - 10, cy + 5, 20, 15, 3, SUIT_DARK)
	draw_rect_pixels(image, cx - 6, cy + 8, 4, 4, ACCENT_BLUE)
	draw_rect_pixels(image, cx + 2, cy + 8, 4, 4, ACCENT_ORANGE)
	draw_rect_pixels(image, cx - 6, cy + 14, 12, 3, Color(0.2, 0.9, 0.3))
	
	# 绘制手臂（左）
	draw_rounded_rect(image, cx - 42, cy - 5, 18, 35, 6, SUIT_WHITE)
	draw_rounded_rect(image, cx - 40, cy + 20, 14, 20, 4, SUIT_GRAY)
	# 手套（左）
	draw_rounded_rect(image, cx - 44, cy + 35, 22, 15, 5, GLOVES)
	
	# 绘制手臂（右）
	draw_rounded_rect(image, cx + 24, cy - 5, 18, 35, 6, SUIT_WHITE)
	draw_rounded_rect(image, cx + 26, cy + 20, 14, 20, 4, SUIT_GRAY)
	# 手套（右）
	draw_rounded_rect(image, cx + 22, cy + 35, 22, 15, 5, GLOVES)
	
	# 绘制头盔外框
	draw_circle_filled(image, cx, cy - 35, 32, HELMET_FRAME)
	draw_circle_filled(image, cx, cy - 35, 28, HELMET_GLASS)
	
	# 绘制脸部（在头盔内）
	draw_circle_filled(image, cx, cy - 32, 18, SKIN_COLOR)
	
	# 绘制眼睛
	draw_circle_filled(image, cx - 6, cy - 34, 3, EYE_COLOR)
	draw_circle_filled(image, cx + 6, cy - 34, 3, EYE_COLOR)
	draw_circle_filled(image, cx - 5, cy - 35, 1, Color.WHITE)
	draw_circle_filled(image, cx + 7, cy - 35, 1, Color.WHITE)
	
	# 绘制鼻子
	draw_rect_pixels(image, cx - 1, cy - 30, 2, 3, Color(0.85, 0.7, 0.6))
	
	# 绘制嘴巴
	draw_rect_pixels(image, cx - 4, cy - 24, 8, 2, Color(0.7, 0.5, 0.5))
	
	# 头盔玻璃反光
	draw_circle_filled(image, cx - 10, cy - 45, 8, VISOR_REFLECTION)
	draw_circle_filled(image, cx + 12, cy - 40, 5, VISOR_REFLECTION)
	
	# 头盔上的灯
	draw_circle_filled(image, cx + 20, cy - 50, 4, ACCENT_ORANGE)
	draw_circle_filled(image, cx + 20, cy - 50, 2, Color(1, 0.7, 0.4))
	
	# 绘制轮廓线
	draw_outline_rounded_rect(image, cx - 25, cy - 10, 50, 45, 10, OUTLINE_COLOR)
	draw_circle_outline(image, cx, cy - 35, 32, OUTLINE_COLOR)

func draw_rect_pixels(image: Image, x: int, y: int, width: int, height: int, color: Color):
	for i in range(width):
		for j in range(height):
			if x + i >= 0 and x + i < TEXTURE_SIZE and y + j >= 0 and y + j < TEXTURE_SIZE:
				image.set_pixel(x + i, y + j, color)

func draw_rounded_rect(image: Image, x: int, y: int, width: int, height: int, radius: int, color: Color):
	# 主体矩形
	draw_rect_pixels(image, x + radius, y, width - 2 * radius, height, color)
	draw_rect_pixels(image, x, y + radius, width, height - 2 * radius, color)
	
	# 四个圆角
	draw_circle_filled(image, x + radius, y + radius, radius, color)
	draw_circle_filled(image, x + width - radius - 1, y + radius, radius, color)
	draw_circle_filled(image, x + radius, y + height - radius - 1, radius, color)
	draw_circle_filled(image, x + width - radius - 1, y + height - radius - 1, radius, color)

func draw_circle_filled(image: Image, cx: int, cy: int, radius: int, color: Color):
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if x * x + y * y <= radius * radius:
				var px = cx + x
				var py = cy + y
				if px >= 0 and px < TEXTURE_SIZE and py >= 0 and py < TEXTURE_SIZE:
					image.set_pixel(px, py, color)

func draw_circle_outline(image: Image, cx: int, cy: int, radius: int, color: Color):
	for angle in range(0, 360, 2):
		var rad = deg_to_rad(angle)
		var x = int(cx + radius * cos(rad))
		var y = int(cy + radius * sin(rad))
		if x >= 0 and x < TEXTURE_SIZE and y >= 0 and y < TEXTURE_SIZE:
			image.set_pixel(x, y, color)

func draw_outline_rounded_rect(image: Image, x: int, y: int, width: int, height: int, radius: int, color: Color):
	# 简化轮廓绘制
	for i in range(width):
		if x + i >= 0 and x + i < TEXTURE_SIZE:
			if y - 1 >= 0:
				image.set_pixel(x + i, y - 1, color)
			if y + height < TEXTURE_SIZE:
				image.set_pixel(x + i, y + height, color)
	for j in range(height):
		if y + j >= 0 and y + j < TEXTURE_SIZE:
			if x - 1 >= 0:
				image.set_pixel(x - 1, y + j, color)
			if x + width < TEXTURE_SIZE:
				image.set_pixel(x + width, y + j, color)

func save_character(path: String = "res://assets/astronaut_portrait.png"):
	var texture = generate_character()
	var image = texture.get_image()
	image.save_png(path)
	print("太空人立绘已保存到: ", path)
