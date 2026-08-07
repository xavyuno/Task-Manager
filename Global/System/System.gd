extends Node

signal BackupLoaded

const APIfILE = "res://.API"
const MAINDIR = "user://"
const  SAVEFILE = "Save"
const SETTINGSFILE = "Settings"
const HISTORYFILE = "History"
const EXTENSION = ".txt"
const AUTOSAVELOC = "AutoSave/"

func _notification(what: int) -> void:
	if (what == NOTIFICATION_EXIT_TREE) or (what == NOTIFICATION_WM_CLOSE_REQUEST) or (what == NOTIFICATION_WM_WINDOW_FOCUS_IN) or (what == NOTIFICATION_WM_WINDOW_FOCUS_OUT) or (what == NOTIFICATION_APPLICATION_FOCUS_IN):
		SaveAll()
		BackupAll()

func GoTo(Info : Dictionary):
	if Info["ID"] != "Home":
		User.emit_signal("ChangeBoard", Info["ID"], User.Boards[Info["ID"]]["Title"], "", Info["Pos"])
	else:
		User.emit_signal("ChangeBoard", "Home", "Home", "", Info["Pos"])

func SaveAll():
	if User.TestingMode:
		return
	SaveStoreHistory()
	SaveRemoveHistory()
	SaveSettings()

func BackupAll():
	DirAccess.make_dir_absolute(MAINDIR + AUTOSAVELOC)
	SaveSettings(AUTOSAVELOC, "AUTO")
	SaveRemoveHistory(AUTOSAVELOC, "AUTO")
	SaveStoreHistory(AUTOSAVELOC, "AUTO")

func LoadBackups():
	for i in [
		MAINDIR + AUTOSAVELOC + SETTINGSFILE + "AUTO" + EXTENSION,
		MAINDIR + AUTOSAVELOC + SAVEFILE + "AUTO" + EXTENSION,
		MAINDIR + AUTOSAVELOC + HISTORYFILE + "AUTO" + EXTENSION,
	]:
		var location : String = i
		location.replace("AUTO", "")
		location.replace("AutoSave/", "")
		SaveFile(location,LoadFile(i))
		emit_signal("BackupLoaded")
		print("backups loaded")

func GetAPI(Index) -> String:
	var file = FileAccess.open(APIfILE,FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data[Index]

func LoadFile(DIR):
	var fileSave = FileAccess.open(DIR, FileAccess.READ)
	if fileSave:
		return fileSave.get_var(true)

func SaveFile(DIR, data):
	var fileSave = FileAccess.open(DIR, FileAccess.WRITE)
	if fileSave:
		fileSave.store_var(data, true)
		fileSave.close()

func SaveStoreHistory(start = "", end = ""):
	var fileSave = FileAccess.open(MAINDIR + start + SAVEFILE + end + EXTENSION, FileAccess.WRITE)
	if fileSave:
		fileSave.store_var(User.StoredHistory, true)
		fileSave.close()

func SaveSettings(start = "", end = ""):
	var fileSave = FileAccess.open(MAINDIR + start + SETTINGSFILE + end + EXTENSION, FileAccess.WRITE)
	if fileSave:
		fileSave.store_var(Settings.GetSettings(), true)
		fileSave.close()

func SaveRemoveHistory(start = "", end = ""):
	var file = FileAccess.open(MAINDIR + start + HISTORYFILE + end + EXTENSION , FileAccess.WRITE)
	if file:
		file.store_var(User.RemovedHistory, true)
		file.close()

func DateToString(date : Array):
	return str(date[0]) + "/" + str(date[1]) + "/" + str(date[2])

func StringToDate(string : String):
	var ToArry = string.split("/")
	return [int(ToArry[0]), int(ToArry[1]), int(ToArry[2])]

func CreateRectangle(p1: Vector2, p2: Vector2):
	var TopRight = Vector2(p2.x, p1.y)
	var BottomLeft = Vector2(p1.x, p2.y)
	var Vertices = PackedVector2Array()
	Vertices.append(p1)
	Vertices.append(TopRight)
	Vertices.append(p2)
	Vertices.append(BottomLeft) 
	Vertices.append(p1)
	return Vertices

func AddObject(item, atMouse = true, parent = null, extraData = {}, emit = true):
	var obj
	if item is PackedScene:
		obj = item.instantiate()
	elif item is Object:
		obj = item
	else:
		obj = load(item).instantiate()
	if extraData.has("Board"):
		obj.Data["Board"] = extraData["Board"]
	if !extraData.is_empty():
		obj.Data = extraData
	if parent != null:
		if get_tree().current_scene.has_node("Boards/" + parent) != null:
			var board = preload("res://App/Assets/Scenes/NewBoard/NewBoard.tscn").instantiate()
			board.name = parent
			get_tree().current_scene.get_node("Boards").add_child(board)
		get_tree().current_scene.get_node("Boards/" + parent).call_deferred("add_child", obj)
		obj.Data["ID"] = parent
	else:
		if !get_tree().current_scene.get_node("Boards/" + User.CurrentPage):
			get_tree().current_scene.get_node("Boards/Home").call_deferred("add_child", obj)
		else:
			get_tree().current_scene.get_node("Boards/" + User.CurrentPage).call_deferred("add_child", obj)
		obj.Data["ID"] = User.CurrentPage
	if GetSpecificType(obj, [Button, Control, TextEdit]):
		obj.position = User.MousePos
	if !extraData.is_empty() and (extraData["Pos"] != Vector2.ZERO and extraData["Size"] != Vector2.ZERO):
		obj.position = extraData["Pos"]
		obj.size = extraData["Size"]
	User.emit_signal("ObjectAdded", obj.Data)


func GetSpecificType(Item, TypeArray: Array):
	var result = false
	for i in TypeArray:
		if typeof(Item) == typeof(i):
			result = true
	return result
