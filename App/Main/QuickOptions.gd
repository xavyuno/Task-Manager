extends HBoxContainer

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	for i in 2:
		if !(Settings.QuickOptions[i] in Settings.AvailableQuickOptions):
			Settings.QuickOptions[i] = RandomOption()
	SettingsChanged()

func SettingsChanged():
	get_node("QuickOption1").tooltip_text = Settings.QuickOptions[0]
	get_node("QuickOption2").icon = load("res://App/Assets/Icons/" + Settings.QuickOptions[1] + ".png")
	get_node("QuickOption1").tooltip_text = Settings.QuickOptions[0]
	get_node("QuickOption1").icon = load("res://App/Assets/Icons/" + Settings.QuickOptions[0] + ".png")

func RandomOption():
	var output = Settings.AvailableQuickOptions[randi() % Settings.AvailableQuickOptions.size()]
	return output.replace("_", "")

func _on_close_pressed() -> void :
	$"../Nodes".visible = !$"../Nodes".visible
	User.CanvasHidden = !$"../Nodes".visible

func _on_settings_pressed() -> void :
	if User.CurrentPage != "Settings":
		User.emit_signal("ChangeBoard", "Settings", "Settings", "", Settings.CamPosSettings)
	else:
		User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.CamPosBoard)

func QuickOption(Index):
	match Settings.QuickOptions[Index]:
		"ShowCenter":
			Settings.ShowCenter = !Settings.ShowCenter
		"ResetCam":
			$"../../Camera".ResetCam()
		"Calendar":
			if User.CurrentPage != "Calendar":
				User.emit_signal("ChangeBoard", "Calendar", "Calendar", "", Settings.CamPosCalendar)
			else :
				User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.CamPosBoard)
		"Canvas":
			if User.CurrentPage != "Canvas":
				User.emit_signal("ChangeBoard", "Canvas", "Canvas", "", Settings.CamPosCanvas)
			else :
				User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.CamPosBoard)

	User.emit_signal("PreviewNotes")
	User.emit_signal("ChangedOptionsBar")
	Settings.emit_signal("SettingsChanged")

func _on_quick_option_1_pressed() -> void:
	QuickOption(0)

func _on_quick_option_2_pressed() -> void:
	QuickOption(1)
