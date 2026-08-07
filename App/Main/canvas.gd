extends HBoxContainer

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	get_node("QuickOption1").tooltip_text = Settings.QuickOptions[0]
	get_node("QuickOption2").tooltip_text = Settings.QuickOptions[1]

func _on_close_pressed() -> void :
	$"../Nodes".visible = !$"../Nodes".visible
	User.CanvasHidden = !$"../Nodes".visible

func _on_settings_pressed() -> void :
	if User.CurrentPage != "Settings":
		User.emit_signal("ChangeBoard", "Settings", "Settings", "")
	else:
		User.emit_signal("ChangeBoard", User.PreviousPage, User.PreviousTitle, "")

func QuickOption(Index):
	match Settings.QuickOptions[Index]:
		"PreviewNotes":
			Settings.QuickOptions[Index] = "Calendar"
		"OptionsBar":
			Settings.QuickOptions[Index] = "ShowCenter"
		"ShowCenter":
			Settings.ShowCenter = !Settings.ShowCenter
		"ResetCam":
			$"../../Camera".ResetCam()
		"Calendar":
			if User.CurrentPage != "Calendar":
				User.emit_signal("ChangeBoard", "Calendar", "Calendar", "", User.CamPosCalendar)
			else :
				User.emit_signal("ChangeBoard", "Home", "Home", "", User.CamPosBoard)

	User.emit_signal("PreviewNotes")
	User.emit_signal("ChangedOptionsBar")
	Settings.emit_signal("SettingsChanged")

func _on_quick_option_1_pressed() -> void:
	QuickOption(0)

func _on_quick_option_2_pressed() -> void:
	QuickOption(1)
