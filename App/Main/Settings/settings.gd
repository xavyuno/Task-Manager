extends Control

@onready var progress: TextureProgressBar = $Holder/User/Update/Progress
@onready var info: Label = $Holder/User/Update/Info
@onready var download: HTTPRequest = $Holder/User/Update/Download

var Downloading: = false
var Version = ""

func _ready() -> void :
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	var ver = FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text()
	ver = ver.strip_edges(true, true)
	ver = ver.strip_escapes()
	$Version.text = "Version: " + ver.validate_filename()
	


func _physics_process(delta: float) -> void :
	if Downloading:
		$Holder/User/Update / Progress.value = download.get_downloaded_bytes()
		$Holder/User/Update / Info.text = "Downloading Update..."
		$Holder/User/Update / Version.text = str(Version)
		get_window().set_taskbar_progress_value(
			$Holder/User/Update / Progress.value / $Holder/User/Update / Progress.max_value
		)
	$Holder/User/Update / Version.visible = Downloading
	$Holder/Items/ItemLimit/TotalItems.text = "Total Items: " + str(User.TotalItems) + " / " + str(Settings.Data["ItemLimit"])

func SettingsChanged():
	$Holder/User/BGPicker.color = Settings.Data["BackgroundCol"]
	$Holder/Items/LoadDur.value = Settings.Data["LoadDur"]
	$Holder/Items/ItemLimit.value = Settings.Data["ItemLimit"]
	$Holder/User/Center.text = "Show center of board: On" if Settings.Data["ShowCenter"] else "Show center of board: Off"
	$Holder/User/Center.alignment = HORIZONTAL_ALIGNMENT_CENTER if Settings.Data["ShowCenter"] else HORIZONTAL_ALIGNMENT_LEFT
	$Holder/Items/LoadDur/Proload.text = "On" if Settings.Data["ProgressiveLoading"] else "Off"
	$Holder/Items/DefaultFontSize.value = Settings.Data["DefaultFontSize"]
	$Holder/Items/DefaultTitle.value = Settings.Data["DefaultTitleSize"]
	$Holder/User/TotalBoards.text = "Total Boards: " + str(Settings.Data["TotalBoards"])
	$Holder/User/SelectColor.color = Settings.Data["SelectCol"]
	$Holder/User/SelectColor/On.text = "On" if Settings.Data["CanSelectCol"] else "Off"
	$Holder/User/DragColor.color = Settings.Data["DragCol"]
	$Holder/User/GridCol.color = Settings.Data["GridCol"]

func _on_color_picker_button_color_changed(color: Color) -> void :
	Settings.Data["BackgroundCol"] = color
	Settings.emit_signal("SettingsChanged")

func _on_project_dir_pressed() -> void :
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _on_project_link_pressed() -> void :
	OS.shell_open("https://github.com/xavyuno/Task-Manager")

func _on_update_pressed() -> void :
	$Holder/User/Update / FileDialog.current_path = Settings.Data["UpdatePath"]
	$Holder/User/Update / FileDialog.popup(Rect2i(600, 600, 600, 600))

func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	Downloading = false
	$Holder/User/Update / Info.text = "Update Finished!"
	print("Retrieved Data")
	if response_code == 200:
		var file = FileAccess.open(Settings.Data["UpdatePath"], FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		print("Update successful")
	else:
		print("Failed to get update")
	await get_tree().create_timer(1).timeout
	$Holder/User/Update / Info.text = "Download Update"

func _on_get_version_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	if response_code == 200:
		Version = body.get_string_from_utf8().trim_prefix("v").to_float()
		var OwnedVer = FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text().trim_prefix("v").to_float()
		if Version <= OwnedVer:
			$Holder/User/Update / Info.text = "Already Up-to-date!"
			await get_tree().create_timer(1).timeout
			$Holder/User/Update / Info.text = "Download Update"
			return
		else :
			$Holder/User/Update / Info.text = "Recieved Latest Version!"
			print("Retrieved version: ", Version)
			var url = "https://github.com/xavyuno/NotaBoard/releases/download/v%s/NotaBoard.exe" % str(Version)
			print("url: " + url)
			download.request(url)
			Downloading = true
	else:
		print("Failed to get version")

func _on_file_dialog_file_selected(path: String) -> void :
	$Holder/User/Update / Info.text = "Getting Latest Version"
	Settings.Data["UpdatePath"] = path
	$Holder/User/Update / GetVersion.request("https://raw.githubusercontent.com/xavyuno/Task-Manager/main/LatestVersion.txt")


func _on_notes_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_load_dur_value_changed(value: float) -> void:
	Settings.Data["LoadDur"] = value

func _on_submit_feedback_pressed() -> void:
	if $Holder/User/Feedback.text == "":
		return
	var req := $Holder/User/Feedback/SubmitFeedback/SubmitReq
	req.request(System.GetAPI(0), ["Content-type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"content" : "```\n" + $Feedback.text + "\n```"}))

func _on_submit_req_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print(body.get_string_from_utf8())
	else :
		print("failed to submit feedback")

func _on_item_limit_value_changed(value: float) -> void:
	Settings.Data["ItemLimit"] = value

func _on_center_pressed() -> void:
	Settings.Data["ShowCenter"] = !Settings.Data["ShowCenter"]
	Settings.emit_signal("SettingsChanged")

func _on_show_bar_pressed() -> void:
	Settings.Data["OptionsEnabled"] = !Settings.Data["OptionsEnabled"]
	Settings.emit_signal("SettingsChanged")

func _on_default_font_size_value_changed(value: float) -> void:
	Settings.Data["DefaultFontSize"] = int(value)
	Settings.emit_signal("SettingsChanged")

func _on_default_title_value_changed(value: float) -> void:
	Settings.Data["DefaultTitleSize"] = int(value)
	Settings.emit_signal("SettingsChanged")


func _on_calendar_pressed() -> void:
	System.SwitchBoard("Calendar")

func _on_proload_pressed() -> void:
	Settings.Data["ProgressiveLoading"] = !Settings.Data["ProgressiveLoading"]
	Settings.emit_signal("SettingsChanged")


func _on_bg_picker_2_color_changed(color: Color) -> void:
	Settings.Data["SelectCol"] = color
	Settings.emit_signal("SettingsChanged")


func _on_on_pressed() -> void:
	Settings.Data["CanSelectCol"] = !Settings.Data["CanSelectCol"]
	Settings.emit_signal("SettingsChanged")


func _on_drag_color_color_changed(color: Color) -> void:
	Settings.Data["DragCol"] = color


func _on_loadbackup_pressed() -> void:
	System.LoadBackups()

var ChangingKeybind = false

func _on_keybind_change_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	print(InputMap.action_get_events("Bold"))
	ChangingKeybind = true

func _input(event: InputEvent) -> void:
	if ChangingKeybind and event is InputEventKey:
		ChangingKeybind = false
		InputMap.action_add_event("Bold", event)
		print(InputMap.action_get_events("Bold"))

func _on_drag_color_2_color_changed(color: Color) -> void:
	Settings.Data["GridCol"] = color
	Settings.emit_signal("SettingsChanged")


func _on_grid_scale_value_changed(value: float) -> void:
	Settings.Data["GridSize"] = value * 16
