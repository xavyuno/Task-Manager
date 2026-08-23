extends Item

@onready var RichText: RichTextLabel = $Text
@onready var NotesText: CodeEdit = $ScrollContainer/Notes

var Data: = {
	"Type": "Notes", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Note": "", 
	"ID": "Home", 
	"Title": "", 
	"TitleOn": true, 
	"FontSize" : Settings.Data["DefaultFontSize"],
	"TitleSize": Settings.Data["DefaultTitleSize"],
	"ItemID" : "",
	"Tags" : []
}

var Options := [
	"Title",
	"FontSize",
	"TitleSize"
]

var Editing := false

func _ready() -> void :
	initItem()
	EditNotes(false)
	UpdateValues(NotesText, "Note", "text")
	UpdateText()
	UpdateValues($Title, "Title", "text")
	UpdateValues($Title, "TitleOn", "visible")
	ChangeFontSize(Has("FontSize"))
	ChangeTitleSize(Has("TitleSize"))
	for i in self.get_children(true):
		for j in i.get_children(true):
			if j.has_signal("mouse_entered"):
				j.connect("mouse_entered", Callable(self, "MouseEntered"))
				j.connect("mouse_exited", Callable(self, "MouseExited"))

		if i.has_signal("mouse_entered"):
			i.connect("mouse_entered", Callable(self, "MouseEntered"))
			i.connect("mouse_exited", Callable(self, "MouseExited"))
	User.connect("PreviewNotes", Callable(self, "PreviewNotes"))
	User.connect("AllFocusLost", Callable(self, "_on_notes_focus_exited"))
	User.connect("RecieveByID", Callable(self, "RecieveByID"))

func MouseEntered():
	if RichText.get_v_scroll_bar().max_value - RichText.size.y >= 0:
		User.InFocus = true

func MouseExited():
	User.InFocus = false

func ChangeTitleSize(value : int):
	$Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value : int):
	RichText.add_theme_font_size_override("bold_font_size", value)
	RichText.add_theme_font_size_override("bold_italics_font_size", value)
	RichText.add_theme_font_size_override("italics_font_size", value)
	RichText.add_theme_font_size_override("mono_font_size", value)
	RichText.add_theme_font_size_override("normal_font_size", value)
	Data["FontSize"] = value

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Note"] = NotesText.text
	Data["Title"] = $Title.text
	Data["TitleOn"] = $Title.visible
	
	if Input.is_action_just_pressed("Bold") and Input.is_action_pressed("Command") and Editing:
		RichTextUpdate("b")

func EditNotes(GrabFocus = true):
	RichText.visible = !Editing
	$ScrollContainer.visible = Editing
	if GrabFocus:
		NotesText.grab_focus()

func _on_notes_focus_exited() -> void:
	if Editing:
		UpdateText()
		Editing = false
		EditNotes(false)

func UpdateText():
	var Temptext : String = Data["Note"]
	if Settings.Data["OverrideText"].size() >= 1:
		for i in Settings.Data["OverrideText"]:
			var Replacement = (
				HasCommand("url=", i["Command"]) +
				HasCommand("color=", i["Color"]) +
				HasCommand("", i["Bold"]) +
				#MIDDLE/ THE TEXT BEING REPLACED
				i["Text"] +
				# END OF TEXT
				HasCommand("b", i["Bold"], true) +
				HasCommand("color", i["Color"], true) +
				HasCommand("url", i["Command"], true))
			Temptext = Temptext.replace(i["Text"], 
				Replacement
				)
	RichText.text = Temptext

func HasCommand(Code : String, text : String, end = false):
	var output = "[" + Code + text + "]"
	if end:
		output = "[/" + Code + "]"
	if text == "":
		output = ""
	return output

func _on_text_focus_entered() -> void:
	Editing = true
	EditNotes(false)

func _on_text_meta_clicked(meta ) -> void:
	meta = str(meta).to_lower().split('/')
	if !Commands.CheckCommand(meta):
		OS.shell_open(str(meta))

func RichTextUpdate(text, additonal = ""):
	if NotesText.get_selected_text():
		var selText = NotesText.get_selected_text()
		NotesText.insert_text("[" + text + additonal + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), true, true)
		NotesText.insert_text("[/" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column() + selText.length(), false, false)
	else :
		NotesText.insert_text("[" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), true, true)
		NotesText.insert_text("[/" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), false, false)

func _on_text_meta_hover_started(meta: Variant) -> void:
	RichText.tooltip_text = str(meta)

func _on_text_meta_hover_ended(meta: Variant) -> void:
	RichText.tooltip_text = ""
