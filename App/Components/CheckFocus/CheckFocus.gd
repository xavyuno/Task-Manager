extends Node

@export var par = get_parent()

func _ready() -> void :
	if !par:
		par = get_parent()
	par.connect("focus_entered", Callable(self, "FocusEntered"))
	par.connect("focus_exited", Callable(self, "FocusExited"))

func FocusEntered():
	User.InFocus = true

func FocusExited():
	User.InFocus = false
