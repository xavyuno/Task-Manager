extends Panel

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	for i in$ScrollHolder/Holder.get_children():
		i.queue_free()
	for i in Settings.Data["SavedKeybinds"].keys():
		var KBE = preload("res://App/Main/keybind_event.tscn").instantiate()
		KBE.Event = i
		$ScrollHolder/Holder.add_child(KBE)
