extends Camera2D

@onready var drag: Area2D = $Drag


var Dragging = false
var DragSelecting := false
var DragSelectPos := Vector2.ZERO
var ZoomScale = Vector2(0.01, 0.01)

#Smooth zoom and positon to designated place
var ToPos : Vector2
var ToZoom : Vector2
var Travelled := true

#Drawing
var StartPos = Vector2.ZERO
var TempObj = null

func _ready() -> void :
	$ClearFocus.visible = true
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))

func SettingsChanged():
	$ClearFocus.self_modulate = Settings.Data["BackgroundCol"]

func ResetCam():
	position = Vector2(640, 352)
	zoom = Vector2(1, 1)

func ChangeBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352), CamZoom = Vector2(1, 1)):
	User.PreviousPos = position
	ToPos = CamPos
	ToZoom = CamZoom if typeof(CamZoom) == TYPE_VECTOR2 else Vector2(1,1)
	Travelled = false
	

func _draw() -> void:
	if User.DragSelecting and !get_node("../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		draw_polyline(
				System.CreateRectangle(DragSelectPos, get_local_mouse_position()),
			Settings.Data["DragCol"],
			2 / User.CamZoom.x
		)

func _physics_process(delta: float) -> void :
	if !Travelled:
		if (position.distance_to(ToPos) > 1) or (zoom.distance_to(ToZoom) > 1):
			position = lerp(position, ToPos, 0.21)
			zoom = lerp(zoom, ToZoom, 0.21)
		else:
			Travelled = true

	match Canvas.Action:
		"Create":
			if Input.is_action_just_pressed("Click"):
				Canvas.Canvases += 1
				StartPos = get_global_mouse_position()
				TempObj = preload("res://App/Assets/Scenes/Canvas/Canvas.tscn").instantiate()
				get_node("../Boards/" + Settings.Data["CurrentPage"]).add_child(TempObj)
				TempObj.Data["ID"] = Canvas.Canvases
				TempObj.Data["ParentID"] = Settings.Data["CurrentPage"]
			if Input.is_action_pressed("Click") and TempObj:
				TempObj.position = StartPos
				TempObj.size = get_global_mouse_position() - StartPos
			if Input.is_action_just_released("Click") and TempObj:
				Canvas.Action = "draw"
				TempObj.Initialized = true
				TempObj = null
	
	User.CamZoom = zoom
	User.CamPos = position
	if Settings.Data["CurrentPage"] in ["Settings", "Home", "Calendar"]:
		Settings.Data["CamPos" + Settings.Data["CurrentPage"]] = position
		Settings.Data["CamZoom" + Settings.Data["CurrentPage"]] = zoom

	if Input.is_action_just_pressed("Special") and CamConditions():
		Settings.Data["GridSnap"] = !Settings.Data["GridSnap"]
	if Input.is_action_just_pressed("ResetCam"):
		ResetCam()
	if Input.is_action_pressed("Drag") and CamConditions():
		Dragging = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("Drag"):
		Dragging = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	User.MousePos = get_local_mouse_position() + position

	if Input.is_action_pressed("ZoomIn") and zoom.x <= 10 and CamConditions():
		zoom += ZoomScale
	if Input.is_action_pressed("ZoomOut") and zoom.x >= 0.1 and CamConditions():
		zoom -= ZoomScale
	
	if Input.is_action_pressed("Click") and User.DragSelecting and !get_node("../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		drag.get_node("CollisionPolygon2D").polygon = System.CreateRectangle(DragSelectPos, get_local_mouse_position())
	if Input.is_action_just_pressed("Click") and !User.MouseInCanvas and !User.InFocus:
		DragSelectPos = get_local_mouse_position()
		DragSelecting = true
		$Timer.start()
	if Input.is_action_just_released("Click"):
		User.DragSelecting = false
		DragSelecting = false
	drag.get_node("CollisionPolygon2D").disabled = !User.DragSelecting

func CamConditions():
	if (!User.InFocus or Input.is_action_pressed("MultiSelect")) and (!User.MouseInCanvas or User.CanvasHidden or User.RemovedHistory.size() <= 9):
		return true
	else :
		return false

func _process(delta: float) -> void :
	$ClearFocus.scale = Vector2(1, 1) / User.CamZoom
	$ClearFocus.position = Vector2(-640, -352) / User.CamZoom
	queue_redraw()

func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x < 10 and CamConditions():
			zoom += ZoomScale
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x > 0.1 and CamConditions():
			zoom -= ZoomScale
	if event is InputEventMouseMotion:
		if Dragging:
			position += - event.relative / User.CamZoom


func _on_drag_body_entered(body: Node2D) -> void:
	if User.DragSelecting:
		body.get_parent().call_deferred("FocusItem")

func _on_drag_body_exited(body: Node2D) -> void:
	if User.DragSelecting:
		body.get_parent().call_deferred("ext", true)


func _on_timer_timeout() -> void:
	if DragSelecting:
		User.DragSelecting = true
	else :
		User.DragSelecting = false
	DragSelecting = false
