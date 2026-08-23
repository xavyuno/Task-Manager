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
	NODE.call_deferred("set", parameter, Has(value))

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
		if CustomValue:
			self.Data[ITEM] = CustomValue
		return self.Data[ITEM]
	else:
		self.Data.merge({ITEM : CustomValue}, true)
		return self.Data[ITEM]

func initItem():
	if self.Data["Size"] != Vector2.ZERO:
		size = self.Data["Size"]
		position = self.Data["Pos"]
	User.TotalItems += 1
	if str(Has("ItemID", "")) == "" or !(typeof(Has("ItemID", "")) == TYPE_STRING) or int(Has("ItemID", "")) <= -1:
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
	User.connect("SearchByQuery", Callable(self, "SearchByQuery"))
	User.connect("DeleteAllItemsByBoard", Callable(self, "DeleteAllItemsByBoard"))
	
	Connect(self.get_children(true), ["focus_entered", "focus_exited", "button_down", "button_up"])

func Connect(NODES : Array, SIGNALS : Array):
	#This ladies and gentlemen is called "Recurrsion" (probably)
	for i in NODES:
		for j in SIGNALS:
			if i.has_signal(j) and !is_connected(j, Callable(self, j)):
				i.connect(j, Callable(self, j))
		if i.get_children(true).size() >= 1:
			Connect(i.get_children(true), SIGNALS)

func SearchByQuery(ID : String):
	var TempFound := false
	var Query = ID.split(":", true, 1)
	if Query.size() <= 1:
		var NewQuery = User.SearchQueries
		NewQuery.erase("Type:")
		for i in NewQuery:
			if TempFound:
				break
			if SearchSimilarity(ID, i.replace(":", ""), true) and !TempFound:
				TempFound = true
				System.GoTo(self.Data)
	else:
		if Query[0].capitalize() + ":" in User.SearchQueries:
			if SearchSimilarity(Query[1].capitalize(), Query[0].capitalize(), true):
				System.GoTo(self.Data)

func Delete():
	User.emit_signal("ItemFocusLost")
	if self.Data["Type"] == "Board":
		Settings.Data["TotalBoards"] -= 1
	User.TotalItems -= 1
	User.emit_signal("StoppedSelecting")
	User.SelectedObject = null
	User.MultiSelectedObjects = []
	User.TotalItems -= 1
	if !Input.is_action_pressed("Special"):
		User.emit_signal("ObjectRemoved", self.Data)
	User.emit_signal("ItemFocusLost")
	if self.Data["Type"] == "Board":
		if Settings.Data["WarnDeleteAllBoard"]:
			System.CreateWarning("Do you wish to delete all objects within this board?").connect("WarningSelectted", Callable(self, "Warning"))
		else:
			queue_free()
	else:
		queue_free()

func Warning(output):
	if output:
		User.emit_signal("DeleteAllItemsByBoard", self.Data["Board"])
	queue_free()

func AddTag(ID):
	self.Data["Tags"].append(ID)

func DeleteAllItemsByBoard(ID):
	if self.Data["ID"] == ID:
		Delete()

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

func SearchSimilarity(Search : String, Query : String, Temp = false):
	var TempData : Dictionary = self.Data
	var Result = false
	if self.Data.has(Query):
		if self.Data[Query] is Array:
			for i in self.Data[Query]:
				Result = ReturnSearchResult(Query, Search, TempData, i, Temp)
		else:
			Result = ReturnSearchResult(Query, Search, TempData, null, Temp)
	return Result

func ReturnSearchResult(Query, Search, TempData, TempValue = null, isTest = false):
	var Temp : String = str(self.Data[Query])
	if TempValue != null:
		Temp = TempValue
	Temp = Temp.to_lower()
	if Temp.similarity(Search.to_lower()) >= User.SearchSen and !(TempData in User.SearchResults):
		TempData.merge({"Search" : Temp, "Query" : Query}, true)
		if TempData["ID"] != "Home":
			if User.Boards[TempData["ID"]]["Title"] != "":
				if !isTest:
					User.emit_signal("SearchResultSend", TempData)
				return true
			else:
				return false
		else:
			if !isTest:
				User.emit_signal("SearchResultSend", TempData)
			return true
	else:
		return false

func StoppedSelecting():
	Selected = false
	Action = ""

func _draw() -> void:
	if Selected and Settings.Data["CanSelectCol"]:
		draw_rect(
			Rect2(0, 0, size.x, size.y),
			Settings.Data["SelectCol"],
			false,
			4 / User.CamZoom.x,
			true
		)

var InitialMousePos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("SelectAll") and self.Data["ID"] == Settings.Data["CurrentPage"] and !User.InFocus:
		focus_entered()
	if Settings.Data["CurrentPage"] == self.Data["ID"]:
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
	if Input.is_action_just_pressed("Delete") and (Selected or DragSelected or MultiSelected):
		Delete()
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
	Col.polygon = System.CreateRectangle(Vector2.ZERO, size)
	var current_mouse = get_global_mouse_position()
	var offset = current_mouse - vec
	var NewPos = vec + (event.relative / User.CamZoom)
	if Settings.Data["GridSnap"]:
		NewPos = vec + offset
		NewPos = NewPos.snapped(Vector2(Settings.Data["GridSize"], Settings.Data["GridSize"]))
	return NewPos

func FocusItem():
	if !Selected or !MultiSelected:
		focus_entered(true)

func AllFocusLost():
	if Selected or MultiSelected:
		Canvas.SelectedCanvas = false
		ext(true)

func ItemFocusLost():
	pass
	#if DragSelected:
		#DragSelected = false
		#ext(true)

func focus_entered(MultiSelect = false):
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
	if self.Data["Type"] == "Canvas":
		Canvas.SelectedCanvas = true
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

func focus_exited():
	if Selected or MultiSelected:
		if (!User.MouseInCanvas or TechnicallyInFocus):
			ext()
		else :
			TechnicallyInFocus = true

func Timeout() -> void:
	Holding = true
	StillHolding = true
	for i in buttons:
		i.release_focus()
