extends VBoxContainer
class_name Item

var InColumn := false
var DragSelected := false

func AddData(extraData : Array):
	for i in extraData:
		self.Data.merge(i, true)

func GetData() -> Dictionary:
	return self.Data

func UpdateValues(NODE, value, parameter):
	if Has(value):
		NODE.call_deferred("set", parameter, self.Data[value])

# SELECT OBJECT CODE BELOW

@export var CanDrag := true
var Selected := false
var MultiSelected := false
var Action := ""
var Holding := false
var StillHolding := false
var TechnicallyInFocus := false

var buttons := []

var TimerNode : Timer = null
var Col : CollisionPolygon2D = null
var Body : StaticBody2D = null

func Has(ITEM : String, CustomValue = null):
	if self.Data.has(ITEM):
		return self.Data[ITEM]
	else:
		self.Data.merge({ITEM : CustomValue}, true)
		return self.Data[ITEM]

func initItem():
	User.TotalItems += 1
	if str(Has("ItemID", "")) == "" or !(typeof(Has("ItemID", "")) == TYPE_STRING):
		self.Data["ItemID"] = str(User.TotalItems)
	TimerNode = Timer.new()
	TimerNode.one_shot = true
	TimerNode.wait_time = 0.5
	self.add_child(TimerNode)
	TimerNode.connect("timeout", Callable(self, "Timeout"))
	
	Body = StaticBody2D.new()
	self.add_child(Body)

	Col = CollisionPolygon2D.new()
	Body.add_child(Col)
	Col.polygon = System.CreateRectangle(Vector2.ZERO, size)
	User.connect("StoppedSelecting", Callable(self, "StoppedSelecting"))
	User.connect("Searched", Callable(self, "Searched"))
	User.connect("AllFocusLost", Callable(self, "AllFocusLost"))
	User.connect("SearchByID", Callable(self, "SearchByID"))
	
	#dont even ask
	
	for i in self.get_children(true):
		for j in i.get_children(true):
			if j.has_signal("focus_entered"):
				j.connect("focus_entered", Callable(self, "FocusEntered"))
				j.connect("focus_exited", Callable(self, "FocusExited"))
			if j.has_signal("button_down"):
				j.connect("button_down", Callable(self, "button_down"))
				j.connect("button_up", Callable(self, "button_up"))
				buttons.append(j)

		if i.has_signal("focus_entered"):
			i.connect("focus_entered", Callable(self, "FocusEntered"))
			i.connect("focus_exited", Callable(self, "FocusExited"))

		if i.has_signal("button_down"):
			i.connect("button_down", Callable(self, "button_down"))
			i.connect("button_up", Callable(self, "button_up"))
			buttons.append(i)

func SearchByID(ID : String):
	if Has("ItemID", "") == ID:
		User.emit_signal("RecieveByID", self.Data)

func button_up():
	if !StillHolding:
		Holding = false
	TimerNode.stop()

func button_down():
	if User.MultiSelecting:
		MultiSelected = true
		if !(get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(get_path())
		else :
			User.MultiSelectedObjects.erase(get_path())
			ext(true)
	if !CanDrag:
		return
	TimerNode.start()

var Found := false

func Searched(itemName : String):
	Found = false
	if itemName == "":
		visible = true
		return
	var Query = itemName.split(":", true, 1)
	if Query.size() <= 1:
		var NewQuery = User.SearchQueries
		NewQuery.erase("Type:")
		for i in NewQuery:
			if SearchSimilarity(itemName, i.replace(":", "")):
				visible = true
				Found = true
			else:
				if !Found:
					visible = false
				else:
					visible = true
	else:
		if Query[0] + ":" in User.SearchQueries:
			visible = SearchSimilarity(Query[1], Query[0])

func SearchSimilarity(Search : String, Query : String):
	var TempData : Dictionary = self.Data
	if self.Data.has(Query):
		var Temp : String = self.Data[Query]
		Temp = Temp.to_lower()
		if Temp.similarity(Search.to_lower()) >= User.SearchSen and !(TempData in User.SearchResults):
			TempData.merge({"Search" : Temp}, true)
			if TempData["ID"] != "Home":
				if User.Boards[TempData["ID"]]["Title"] != "":
					User.emit_signal("SearchResultSend", TempData)
					return true
				else:
					return false
			else:
				User.emit_signal("SearchResultSend", TempData)
				return true
		else:
			return false
	else:
		return false

func StoppedSelecting():
	Selected = false
	Action = ""

func _draw() -> void:
	if Selected and Settings.CanSelectCol:
		draw_rect(
			Rect2(0, 0, size.x, size.y),
			Settings.SelectCol,
			false,
			4 / User.CamZoom.x,
			true
		)

var InitialMousePos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("SelectAll") and self.Data["ID"] == User.CurrentPage and !User.InFocus:
		FocusEntered()
	if User.CurrentPage == self.Data["ID"]:
		if Col != null:
			Col.disabled = false
	else:
		if Col != null:
			Col.disabled = true

	if TechnicallyInFocus and !User.MouseInCanvas:
		ext()
	if Holding and Input.is_action_just_released("Click"):
		StillHolding = false
		Holding = false
		if User.MultiSelecting:
			if !(get_path() in User.MultiSelectedObjects):
				User.MultiSelectedObjects.append(get_path())
				Selected = true
			User.SelectedObject = null
		else:
			User.MultiSelectedObjects = []
			User.SelectedObject = get_path()
			Selected = true
			User.emit_signal("ItemFocused", get_path())
		User.emit_signal("SaveObjectData")
	if Input.is_action_just_pressed("Click"):
		if DragSelected:
			ItemFocusLost()
		if (Action == "Moving" or Action == "Resizing"):
			Action = ""
			Selected = false
	if Input.is_action_just_pressed("Move") and Input.is_action_pressed("Command") and Selected:
		InitialMousePos = position
		if Action != "Moving":
			Action = "Moving"
		else :
			Action = ""
	if Input.is_action_just_pressed("Resize") and Input.is_action_pressed("Command") and Selected:
		if Action != "Resizing":
			Action = "Resizing"
		else :
			Action = ""
	if Input.is_action_just_pressed("Delete"):
		User.emit_signal("ItemFocusLost")
		if Selected or DragSelected or MultiSelected:
			if self.Data["Type"] == "Board":
				Settings.TotalBoards -= 1
			User.TotalItems -= 1
			User.emit_signal("ObjectRemoved", self.Data)
			User.emit_signal("StoppedSelecting")
			User.SelectedObject = null
			User.MultiSelectedObjects = []
			queue_free()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Holding and !InColumn:
			position = MouseMove(event, position)
			User.DragSelecting = false
		if Action == "Moving" and !InColumn:
			position = MouseMove(event, position)
		if Action == "Resizing":
			if !InColumn:
				size = MouseMove(event, size)
			else :
				custom_minimum_size.y = MouseMove(event, size)

func MouseMove(event : InputEventMouseMotion, vec):
	var current_mouse = get_global_mouse_position()
	var offset = current_mouse - vec
	var NewPos = vec + (event.relative / User.CamZoom)
	if Settings.GridSnap:
		NewPos = vec + offset
		NewPos = NewPos.snapped(Vector2(Settings.GridSize, Settings.GridSize))
	return NewPos

func FocusItem():
	FocusEntered(true)

func AllFocusLost():
	ext(true)

func ItemFocusLost():
	pass
	#if DragSelected:
		#DragSelected = false
		#ext(true)

func FocusEntered(MultiSelect = false):
	if !(User.MultiSelecting or MultiSelect):
		DragSelected = false
		MultiSelected = false
		User.MultiSelectedObjects = []
		User.MultiSelectedObjects.append(get_path())
	if MultiSelect:
		DragSelected = true
		MultiSelected = true
		if !(get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(get_path())
		else :
			User.MultiSelectedObjects.erase(get_path())
			ext(true)
	User.SelectedObject = get_path()
	Selected = true
	User.emit_signal("ItemFocused", get_path())
	User.emit_signal("SaveObjectData")

func ext(force = false):
	TechnicallyInFocus = false
	User.emit_signal("SaveObjectData")
	if (!User.MultiSelecting and !DragSelected) or force:
		Selected = false
		MultiSelected = false
		Action = ""
	else :
		User.emit_signal("ItemFocusLost")

func FocusExited():
	if (!User.MouseInCanvas or TechnicallyInFocus):
		ext()
	else :
		TechnicallyInFocus = true

func Timeout() -> void:
	Holding = true
	StillHolding = true
	for i in buttons:
		i.release_focus()
