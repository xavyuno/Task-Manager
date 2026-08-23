extends Item

@onready var input: LineEdit = $AddHolder / Input
@onready var progress: Label = $Top/Progress

var Data: = {
	"Type": "ToDo", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"List": {}, 
	"ID": "Home", 
	"TitleOn": true, 
	"Title": "",
	"FontSize" : Settings.Data["DefaultFontSize"],
	"TitleSize": Settings.Data["DefaultTitleSize"],
	"ShowProgress" : true,
	"ItemID" : "",
	"Tags" : []
}

var Options := [
	"Ratio",
	"Title",
	"FontSize",
	"TitleSize",
	"Progress"
]
var TempTitleSize := 0

func _ready() -> void :
	initItem()
	for i in Data["List"].keys():
		var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
		Check.Text = i
		Check.get_node("Input").set_pressed_no_signal(Data["List"][i])
		$List.add_child(Check)
		for c in Check.get_children(true):
			if c.has_signal("focus_entered"):
				c.connect("focus_entered", Callable(self, "FocusEntered"))
				c.connect("focus_exited", Callable(self, "FocusExited"))
		Check.get_node("Close").connect("pressed", TodoClosed.bind(Check.get_path()))
	UpdateValues($Top/Title, "TitleOn", "visible")
	UpdateValues($Top/Title, "Title", "text")
	UpdateValues(progress, "ShowProgress", "visible")
	if Data.has("FontSize"):
		$Top/Title.add_theme_font_size_override("font_size", Data["TitleSize"])
		if $List.get_children().size() >= 1:
			for i in $List.get_children():
				i.ChangeFontSize(Data["FontSize"])
	CalculateProgress()

func TodoClosed(path):
	TempTitleSize = $Top/Title.size.y
	size.y -= get_node(path).size.y
	get_node(path).queue_free()
	$Top/Title.size.y = TempTitleSize
	Data["List"].erase(get_node(path).Text)
	CalculateProgress()

func ChangeTitleSize(value : int):
	$Top/Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value : int):
	if Data.has("FontSize"):
		if $List.get_children().size() >= 1:
			for i in $List.get_children():
				i.ChangeFontSize(Data["FontSize"])
	Data["FontSize"] = value

func CalculateProgress():
	if !Data.has("ShowProgress"):
		return
	var Total = Data["List"].size()
	if Total <= 0:
		progress.text = "0%"
		var stylebox := progress.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Color.RED
		progress.add_theme_stylebox_override("normal",stylebox)
	else :
		var Completed := 0
		for i in Data["List"].size():
			if Data["List"][Data["List"].keys()[i]]:
				Completed += 1
		var progressValue = int(float(Completed) / float(Total) * 100)
		progress.text = str(progressValue) + "%"
		var stylebox := progress.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Color(1.0 - (float(progressValue) / 100 * 1) ,(float(progressValue) / 100 * 1) ,0.0, 1.0)
		progress.add_theme_stylebox_override("normal",stylebox)

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["TitleOn"] = $Top/Title.visible
	Data["Title"] = $Top/Title.text
	Data["ShowProgress"] = progress.visible

func AddList():
	if $AddHolder / Input.text.is_empty():
		return
	var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
	Check.Text = input.text
	$List.add_child(Check)
	for c in Check.get_children(true):
		if c.has_signal("focus_entered"):
			c.connect("focus_entered", Callable(self, "FocusEntered"))
			c.connect("focus_exited", Callable(self, "FocusExited"))
	Check.get_node("Close").connect("pressed", TodoClosed.bind(Check.get_path()))
	Data["List"].merge({input.text: false}, true)
	$AddHolder / Input.text = ""
	$AddHolder/Input.grab_click_focus()
	CalculateProgress()

func _on_add_pressed() -> void :
	AddList()

func _on_input_text_submitted(new_text: String) -> void :
	AddList()

func _on_title_on_pressed() -> void :
	$Top/Title.visible = !$Top/Title.visible
