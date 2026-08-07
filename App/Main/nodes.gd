extends Control

@onready var history: ItemList = $Holder/History / HistoryHolder / History

func _ready() -> void :
	Init()

func Init():
	get_parent().visible = true
	User.connect("ObjectAdded", Callable(self, "ObjAdded"))
	User.connect("ObjectRemoved", Callable(self, "ObjRemoved"))
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))

	var Settingsfile = FileAccess.open("user://Settings.txt", FileAccess.READ)
	if Settingsfile:
		var data :Array = Settingsfile.get_var(true)
		Settingsfile.close()
		if !(data is Array):
			print("Error loading settings File!")
			User.TestingMode = true
		else:
			ValidateValue(data, 0, "BackgroundCol")
			ValidateValue(data, 1, "UpdatePath")
			ValidateValue(data, 2, "LoadDur")
			ValidateValue(data, 3, "ItemLimit")
			# ValidateValue(data, 4, "OptionsEnabled")
			ValidateValue(data, 5, "ShowCenter")
			ValidateValue(data, 6, "QuickOptions")
			ValidateValue(data, 7, "DefaultFontSize")
			ValidateValue(data, 8, "DefaultTitleSize")
			ValidateValue(data, 9, "UrlAPIKey")
			ValidateValue(data, 10, "ProgressiveLoading")
			#ValidateValue(data, 11, "TotalBoards")
			ValidateValue(data, 12, "SelectCol")
			ValidateValue(data, 13, "CanSelectCol")
			
			var TempBinds = Settings.SavedKeybinds
			ValidateValue(data, 14, "SavedKeybinds")
			for j in TempBinds.keys():
				if !Settings.SavedKeybinds.has(j):
					Settings.SavedKeybinds.merge({j : []}, true)
			if data.size() > 15:
				User.SavedEvents = data[15]
			ValidateValue(data, 16, "GridSize")
			ValidateValue(data, 17, "GridCol")
			
	Settings.emit_signal("SettingsChanged")
	User.emit_signal("ChangedOptionsBar")

	var fileHistory = FileAccess.open("user://History.txt", FileAccess.READ)
	if fileHistory:
		var data = fileHistory.get_var(true)
		if !(data is Array):
			print("Error loading History File!")
			User.TestingMode = true
		else:
			User.RemovedHistory = data
			fileHistory.close()
			for i in User.RemovedHistory:
				if i["Type"] != "Line":
					if Settings.ProgressiveLoading:
						await get_tree().create_timer(User.LoadDur).timeout
					var img = get_node("Holder/ItemHolder/Items/" + i["Type"]).icon
					history.add_item("Removed: " + JSON.stringify(i, "\t", false, true), img)

	var fileSave = FileAccess.open("user://Save.txt", FileAccess.READ)
	if fileSave:
		var data = fileSave.get_var(true)
		if !(data is Array):
			print("Error loading Save File!")
			User.TestingMode = true
		else :
			User.StoredHistory = data
			fileSave.close()
			for i in User.StoredHistory:
				if i["Type"] != "Line":
					if Settings.ProgressiveLoading:
						await get_tree().create_timer(User.LoadDur).timeout
					if i["Type"] == "Board":
						User.Boards.merge({i["Board"] : {"Title" : i["Title"], "ID" : i["ID"], "CamPos" : Vector2(640, 352)}}, true)
					initObj(i, false)

	User.StillLoading = false
	if Settings.TotalBoards <= 0:
		await get_tree().create_timer(6).timeout
		for i in $"../../Boards".get_children():
			if int(i.name) > Settings.TotalBoards:
				Settings.TotalBoards = int(i.name) + 1

func ValidateValue(array: Array, index, parameter) -> bool:
	if array.size() > index:
		Settings.set(parameter, array[index])
		return true
	else :
		return false

func _physics_process(delta: float) -> void :
	$Holder/Delete.visible = !$Holder/DeleteAll.visible
	if get_global_mouse_position().x <= 160:
		User.MouseInCanvas = true
	else :
		User.MouseInCanvas = false
	
	if Input.is_action_pressed("MultiSelect"):
		User.MultiSelecting = true
	if Input.is_action_just_released("MultiSelect"):
		User.MultiSelecting = false

	if Input.is_action_just_pressed("Undo") and history.item_count >= 1 and !User.InFocus:
		Undo(User.RemovedHistory[User.RemovedHistory.size() - 1])
	if Input.is_action_just_pressed("Copy") and !User.InFocus:
		if User.SelectedObject:
			User.CopiedObject = get_node(User.SelectedObject).Data
		if User.MultiSelectedObjects.size() >= 1:
			User.MultiCopiedObjects = []
			for i in User.MultiSelectedObjects:
				User.MultiCopiedObjects.append(get_node(i).Data)
			User.MultiSelectedObjects = []
	if Input.is_action_just_pressed("Cut") and !User.InFocus:
		if User.SelectedObject:
			User.CopiedObject = get_node(User.SelectedObject).Data
			get_node(User.SelectedObject).queue_free()
		if User.MultiSelectedObjects.size() >= 1:
			User.MultiCopiedObjects = []
			for i in User.MultiSelectedObjects:
				User.MultiCopiedObjects.append(get_node(i).Data)
			for i in User.MultiSelectedObjects:
				get_node(i).queue_free()
			User.MultiSelectedObjects = []
		User.emit_signal("ItemFocusLost")
	if Input.is_action_just_pressed("Paste") and !User.InFocus and !User.CurrentPage in ["Settings", "Calendar"]:
		if User.CopiedObject:
			var TempData = User.CopiedObject
			TempData["Pos"] = User.MousePos
			TempData["ID"] = User.CurrentPage
			initObj(TempData, true)
		elif User.MultiSelectedObjects.size() >= 1:
			for i in User.MultiSelectedObjects:
				initObj(get_node(i).Data, true)
		elif User.MultiCopiedObjects.size() >= 1:
			for i in User.MultiCopiedObjects:
				initObj(i, true)
		else:
			if DisplayServer.clipboard_has_image():
				var obj = preload("res://App/Assets/Scenes/File/File.tscn").instantiate()
				var saveImg := DisplayServer.clipboard_get_image()
				var Dir = DirAccess.make_dir_absolute("user://PastedImages")
				var files = DirAccess.get_files_at("user://PastedImages")
				var filepath
				if files.size() > 0:
					filepath = "user://PastedImages/" + str( int(files.size()) + 1 ) + ".png"
				else :
					filepath = "user://PastedImages/1.png"
				saveImg.save_png(filepath)
				obj.Data["Dir"] = filepath
				System.AddObject(obj)
			else:
				var cb := DisplayServer.clipboard_get()
				if cb.begins_with("Https://") or cb.begins_with("https://") or cb.begins_with("www.") or cb.ends_with(".com") or cb.ends_with(".na"):
					var obj = preload("res://App/Assets/Scenes/Link/Link.tscn").instantiate()
					obj.Data["Link"] = cb
					System.AddObject(obj)
		User.emit_signal("StoppedSelecting")
	if Input.is_action_just_pressed("Duplicate") and User.CopiedObject:
		initObj(User.CopiedObject, true)

func Undo(data):
	initObj(data, true)

func initObj(data, emit = false):
	var obj = load("res://App/Assets/Scenes/" + data["Type"] + "/" + data["Type"] + ".tscn")
	System.AddObject(obj, false, data["ID"], data, emit)

func ObjAdded(data):
	if User.RemovedHistory.is_empty():
		UpdateHistory()
		return
	for i in User.RemovedHistory.size():
		if User.RemovedHistory[i] == data:
			User.RemovedHistory.remove_at(i)
			history.remove_item(i)
			UpdateHistory()
			break

func UpdateHistory():
	if User.RemovedHistory.is_empty():
		$Holder/History.visible = false
	else:
		$Holder/History.visible = true

func ObjRemoved(data):
	var img = get_node("Holder/ItemHolder/Items/" + data["Type"]).icon
	history.add_item("Removed: " + JSON.stringify(data, "\t", false, true), img)
	User.RemovedHistory.append(data)
	if User.StoredHistory.is_empty():
		UpdateHistory()
		return
	for i in User.StoredHistory.size():
		if User.StoredHistory[i] == data:
			User.StoredHistory.remove_at(i)
			UpdateHistory()
			break

func _on_history_item_activated(index: int) -> void :
	if history.get_selected_items().size() > 1:
		for i in history.get_selected_items():
			if history.get_item_text(i).begins_with("Removed: "):
				Undo(User.RemovedHistory[i])
	else:
		if history.get_item_text(index).begins_with("Removed: "):
			Undo(User.RemovedHistory[index])

func ChangedBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352)):
	if User.CurrentPage in ["Settings", "Calendar"]:
		$Holder/ItemHolder.visible = false
	else:
		$Holder/ItemHolder.visible = true
	User.emit_signal("ItemFocusLost")

func _exit_tree() -> void :
	User.emit_signal("SaveObjectData")

func _on_delete_pressed() -> void :
	$Holder/DeleteAll.visible = true


func _on_clear_pressed() -> void :
	history.clear()
	User.RemovedHistory.clear()
	System.SaveRemoveHistory()
	UpdateHistory()


func _on_history_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 2:
		$Holder/HistoryHolder/History.remove_item(index)
		User.RemovedHistory.erase(User.RemovedHistory[index])
		System.SaveRemoveHistory()


func _on_search_text_changed(new_text: String) -> void:
	if new_text == "":
		User.emit_signal("Searched", "")

func _on_yes_pressed() -> void:
	User.TotalItems = 0
	history.clear()
	User.StoredHistory.clear()
	User.RemovedHistory.clear()
	User.Boards = {}
	System.SaveRemoveHistory()
	System.SaveStoreHistory()
	var boards = $"../../Boards"
	for i in boards.get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()
	for i in boards.get_node("Home").get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()
	User.emit_signal("ChangeBoard", "Home")
	$Holder/DeleteAll.visible = false
	UpdateHistory()

func _on_no_pressed() -> void:
	$Holder/DeleteAll.visible = false

func _on_search_text_submitted(new_text: String) -> void:
	User.emit_signal("Searched", new_text)
