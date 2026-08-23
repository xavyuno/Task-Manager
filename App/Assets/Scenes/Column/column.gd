extends Item

@onready var items: VBoxContainer = $Items

var Data: = {
	"Type": "Column", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Title": "", 
	"Items": [], 
	"ID": "Home",
	"ItemID" : "",
	"Tags" : []
}

var Options := [
	"Ratio"
]

var MouseIndropBar = false

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Title"] = $Title.text
	if User.DraggingObject:
		if User.DraggedObject.instantiate().name != "Line":
			$DropBar.visible = true
		else :
			$DropBar.visible = false
	else :
		$DropBar.visible = false

func _ready() -> void :
	initItem()
	User.connect("StoppedDragging", Callable(self, "StoppedDragging"))
	UpdateValues($Title, "Title", "text")
	for i in Data["Items"]:
		if Settings.ProgressiveLoading:
			await get_tree().create_timer(User.LoadDur).timeout
		InitObjectData(i)

func UpdateList():
	var tempData = []
	for i in items.get_children(true):
		if i.has_method("GetData"):
			tempData.append(i.GetData())
	Data["Items"] = tempData

func GetData():
	UpdateList()
	return Data

func InitObjectData(data):
	var object = load("res://App/Assets/Scenes/" + data["Type"] + "/" + data["Type"] + ".tscn")
	var item : Item = object.instantiate()
	item.Data = data
	item.InColumn = true
	$Items.add_child(item)
	
	item.custom_minimum_size = Vector2(96, 96)

func InitObject(object):
	var item : Item = object.instantiate()
	$Items.add_child(item)
	item.InColumn = true
	Data["Items"].append(item.Data)
	User.TotalItems += 1
	item.custom_minimum_size = Vector2(96, 96)

func StoppedDragging():
	if User.DraggingObject and MouseIndropBar and User.DraggedObject.instantiate().name != "Line":
		User.DraggingObject = false
		InitObject(User.DraggedObject)

func _on_drop_bar_mouse_entered() -> void :
	MouseIndropBar = true

func _on_drop_bar_mouse_exited() -> void :
	MouseIndropBar = false
