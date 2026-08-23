extends Control

func _ready() -> void:
	var file = FileAccess.open("res://Updates.txt", FileAccess.READ)
	$Changelog/ScrollContainer/Notes.text = file.get_as_text()
	file.close()
