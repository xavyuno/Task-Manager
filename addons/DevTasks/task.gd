@tool
extends HBoxContainer

func _ready() -> void:
	$Holder/Remove.connect("pressed", Callable(self, "Pressed"))

func UpdateData(taskinfo, value):
	$Info.text = taskinfo
	$Holder/Check.button_pressed = value

func Pressed() -> void:
	queue_free()
