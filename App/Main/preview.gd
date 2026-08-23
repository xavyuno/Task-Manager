extends Control

func _ready() -> void :
	User.connect("StartedDragging", Callable(self, "StartedDragging"))
	User.connect("StoppedDragging", Callable(self, "StoppedDragging"))

func _process(delta: float) -> void :
	global_position = User.MousePos

func StartedDragging():
	if Settings.Data["CurrentPage"].similarity(get_parent().name) < 1:
		return
	var obj = User.DraggedObject.instantiate()
	if obj.Data.has("Board"):
		obj.Preview = true
	add_child(obj)

func StoppedDragging():
	if get_child_count() >= 1:
		for i in get_children():
			i.queue_free()
			User.TotalItems -= 1

func _on_clear_focus_pressed() -> void:
	User.emit_signal("ItemFocusLost")
	User.emit_signal("AllFocusLost")
	User.MultiSelectedObjects = []
	User.MultiCopiedObjects = []
