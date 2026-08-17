extends Node

signal BackupLoaded

const APIfILE = "res://.API"
const MAINDIR = "user://"
const SAVEFILE = "Save"
const SETTINGSFILE = "Settings"
const HISTORYFILE = "History"
const CANVASFILE = "Canvas"
const EXTENSION = ".txt"
const AUTOSAVELOC = "AutoSave/"

var Saving := false

func _notification(what: int) -> void:
	if what in [
	NOTIFICATION_EXIT_TREE,
	NOTIFICATION_WM_CLOSE_REQUEST,
	NOTIFICATION_WM_WINDOW_FOCUS_IN,
	NOTIFICATION_WM_WINDOW_FOCUS_OUT,
	NOTIFICATION_APPLICATION_FOCUS_IN
	]:
		SaveAll(false)
		BackupAll()


func GoTo(Info : Dictionary):
	if Info["ID"] != "Home":
		User.emit_signal("ChangeBoard", Info["ID"], User.Boards[Info["ID"]]["Title"], "", Info["Pos"])
	else:
		User.emit_signal("ChangeBoard", "Home", "Home", "", Info["Pos"])

func SaveAll(test):
	if User.TestingMode or Saving:
		Saving = false
		return
	Saving = true
	SaveStoreHistory()
	SaveRemoveHistory()
	SaveSettings()
	#SaveCanvas()

func BackupAll():
	DirAccess.make_dir_absolute(MAINDIR + AUTOSAVELOC)
	SaveSettings(AUTOSAVELOC, "AUTO")
	SaveRemoveHistory(AUTOSAVELOC, "AUTO")
	SaveStoreHistory(AUTOSAVELOC, "AUTO")
	#SaveCanvas(AUTOSAVELOC, "AUTO")

func LoadBackups():
	for i in [
		MAINDIR + AUTOSAVELOC + SETTINGSFILE + "AUTO" + EXTENSION,
		MAINDIR + AUTOSAVELOC + SAVEFILE + "AUTO" + EXTENSION,
		MAINDIR + AUTOSAVELOC + HISTORYFILE + "AUTO" + EXTENSION,
		MAINDIR + AUTOSAVELOC + CANVASFILE + "AUTO" + EXTENSION
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
		var Data = fileSave.get_var(true)
		fileSave.close()
		return Data

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

func SaveCanvas(start = "", end = ""):
	var fileSave = FileAccess.open(MAINDIR + start + CANVASFILE + end + EXTENSION, FileAccess.WRITE)
	if fileSave:
		fileSave.store_var(Canvas.SavedCanvas, true)
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

func CreateWarning(Info):
	var WarningUI = preload("res://App/Components/Warning/warning.tscn").instantiate()
	WarningUI.Info = Info
	get_tree().current_scene.get_node("UI").add_child(WarningUI)
	return WarningUI

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
		obj.Data.merge(extraData, true)
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
