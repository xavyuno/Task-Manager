extends Node

@onready var Par = $"../../.."
var Selected := false
var Action := ""
var Holding := false
var StillHolding := false
var TechnicallyInFocus := false

var buttons := []

func _ready() -> void :
	User.connect("StoppedSelecting", Callable(self, "StoppedSelecting"))
	for i in get_parent().get_children(true):
		if i.get_child_count() >= 1:
			for j in i.get_children(true):
				if j.has_signal("focus_entered"):
					j.connect("focus_entered", Callable(self, "FocusEntered"))
					j.connect("focus_exited", Callable(self, "FocusExited"))
					
				if j.has_signal("button_down"):
					j.connect("button_down", Callable(self, "button_down"))
					buttons.append(j)
					j.connect("button_up", Callable(self, "button_up"))

		if i.has_signal("focus_entered"):
			i.connect("focus_entered", Callable(self, "FocusEntered"))
			i.connect("focus_exited", Callable(self, "FocusExited"))

		if i.has_signal("button_down"):
			i.connect("button_down", Callable(self, "button_down"))
			i.connect("button_up", Callable(self, "button_up"))
			buttons.append(i)

func button_up():
	if !StillHolding:
		Holding = false
	$Timer.stop()

func button_down():
	$Timer.start()

func StoppedSelecting():
	Selected = false
	Action = ""

func _physics_process(delta: float) -> void:
	if TechnicallyInFocus and !User.MouseInCanvas:
		ext()
	if Holding and Input.is_action_just_released("Click"):
		StillHolding = false
		Holding = false
		if User.MultiSelecting:
			if !(Par.get_path() in User.MultiSelectedObjects):
				User.MultiSelectedObjects.append(Par.get_path())
				Selected = true
			User.SelectedObject = null
		else:
			User.MultiSelectedObjects = []
			User.SelectedObject = Par.get_path()
			Selected = true
			User.emit_signal("ItemFocused", Par.get_path())
		User.emit_signal("SaveObjectData")
	if Input.is_action_just_pressed("Click") and (Action == "Moving" or Action == "Resizing"):
		Action = ""
		Selected = false
	if Input.is_action_just_pressed("Move") and Selected:
		if Action != "Moving":
			Action = "Moving"
		else :
			Action = ""
	if Input.is_action_just_pressed("Resize") and Selected:
		if Action != "Resizing":
			Action = "Resizing"
		else :
			Action = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Holding:
			Par.position += event.relative / User.CamZoom
		if Action == "Moving":
			Par.position += event.relative / User.CamZoom
		if Action == "Resizing" :
			Par.size += event.relative / User.CamZoom

func FocusEntered():
	if User.MultiSelecting:
		if !(Par.get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(Par.get_path())
			Selected = true
		User.SelectedObject = null
	else:
		User.MultiSelectedObjects = []
		User.SelectedObject = Par.get_path()
		Selected = true
		User.emit_signal("ItemFocused", Par.get_path())
	User.emit_signal("SaveObjectData")

func ext():
	TechnicallyInFocus = false
	User.emit_signal("ItemFocusLost")
	User.emit_signal("SaveObjectData")
	if !User.MultiSelecting:
		Selected = false
		Action = ""

func FocusExited():
	if !User.MouseInCanvas or TechnicallyInFocus:
		ext()
	else :
		TechnicallyInFocus = true

func _on_timer_timeout() -> void:
	Holding = true
	StillHolding = true
	for i in buttons:
		i.release_focus()
