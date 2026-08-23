extends HBoxContainer

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	for i in Settings.Data["QuickOptions"].size():
		if !(Settings.Data["QuickOptions"][i] in Settings.AvailableQuickOptions):
			Settings.Data["QuickOptions"][i] = RandomOption()
			
	SettingsChanged()

func SettingsChanged():
	for i in Settings.Data["QuickOptions"].size():
		get_node("QuickOption" + str(i+1)).tooltip_text = Settings.Data["QuickOptions"][i]
		get_node("QuickOption" + str(i+1)).icon = load("res://App/Assets/Icons/" + Settings.Data["QuickOptions"][i] + ".png")

func RandomOption():
	var output = Settings.AvailableQuickOptions[randi() % Settings.AvailableQuickOptions.size()]
	return output.replace("_", "")

func _on_settings_pressed() -> void :
	if User.CurrentPage != "Settings":
		System.SwitchBoard("Settings")
	else:
		System.SwitchBoard("Home")

func QuickOption(Index):
	match Settings.Data["QuickOptions"][Index]:
		"ShowCenter":
			Settings.Data["ShowCenter"] = !Settings.Data["ShowCenter"]
		"ResetCam":
			$"../../Camera".ResetCam()
		"Calendar":
			System.SwitchBoard("Calendar")
		"Hide":
			Settings.Data["ToolbarVisible"] = !Settings.Data["ToolbarVisible"]
			$"../Nodes".visible = Settings.Data["ToolbarVisible"]
			User.CanvasHidden = Settings.Data["ToolbarVisible"]

	User.emit_signal("PreviewNotes")
	User.emit_signal("ChangedOptionsBar")
	Settings.emit_signal("SettingsChanged")

func _on_quick_option_1_pressed() -> void:
	QuickOption(0)

func _on_quick_option_2_pressed() -> void:
	QuickOption(1)

func _on_quick_option_3_pressed() -> void:
	QuickOption(2)
