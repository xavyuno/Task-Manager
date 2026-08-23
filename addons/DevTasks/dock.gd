@tool
extends Control

@onready var input: LineEdit = $Holder/Input
@onready var tasks: VBoxContainer = $Holder/Tasks/Holder


var DevTasks := {}
var SaveFile := "res://addons/DevTasks/tasks.txt"
var Loaded := false

func _ready() -> void:
	Load()
	input.connect("text_submitted", Callable(self, "TaskSubmitted"))
	LoadTasks()

func TaskSubmitted(txt):
	DevTasks.merge({input.text : false}, true)
	var task = preload("res://addons/DevTasks/task.tscn").instantiate()
	tasks.add_child(task)
	task.get_node("Info").text = input.text
	input.text = ""
	Save()

func LoadTasks():
	if DevTasks.size() >= 1:
		for i in DevTasks.keys():
			var task = preload("res://addons/DevTasks/task.tscn").instantiate()
			tasks.add_child(task)
			task.UpdateData(i, DevTasks[i])
			Loaded = true

func TaskAdded():
	DevTasks.merge({input.text : false}, true)
	var task = preload("res://addons/DevTasks/task.tscn").instantiate()
	tasks.add_child(task)
	task.get_node("Info").text = input.text
	input.text = ""

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		Save()

func Save():
	if !Loaded:
		return
	var TempDevTasks = {}
	for i in tasks.get_child_count():
		var taskinfo = tasks.get_child(i).get_node("Info").text
		var value = tasks.get_child(i).get_node("Holder/Check").button_pressed
		TempDevTasks.merge({taskinfo : value}, true)
	var file = FileAccess.open(SaveFile, FileAccess.WRITE)
	file.store_pascal_string(JSON.stringify(TempDevTasks, "\t", false, true))
	file.close()

func Load():
	var file = FileAccess.open(SaveFile, FileAccess.READ)
	if file.file_exists(SaveFile):
		DevTasks = JSON.parse_string(file.get_pascal_string())
	file.close()

func _exit_tree() -> void:
	Save()
