class_name SaveManager
extends Node

const SAVE_FILE_PATH = "res://save_data.json"

var save_data = {
	"high_score": 0
}

func _ready():
	load_data()

func load_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				save_data = json.data
			else:
				push_error("Failed to parse save data")
	else:
		# 首次运行，创建默认存档
		save_data = {"high_score": 0}
		save_to_file()

func save_to_file():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save data")

func get_high_score() -> int:
	return save_data.get("high_score", 0)

func set_high_score(score: int):
	if score > save_data["high_score"]:
		save_data["high_score"] = score
		save_to_file()

func reset_high_score():
	save_data["high_score"] = 0
	save_to_file()
