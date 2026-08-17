extends Item

var Data: = {
	"Type": "Board", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Board": "Getting ID...", 
	"Title": "Untitled Board", 
	"ID": "Home", 
	"Cover" : null,
	"CamPos" : Vector2(640, 352),
	"ItemID" : 0
}

var Options := ["Cover", "BoardName", "Board"]

var Preview := false
var ClickedOnce := false

func _ready() -> void :
	Settings.TotalBoards += 1
	initItem()
	UpdateValues($New, "Title", "text")
	UpdateValues($New/Cover, "Cover", "texture")
	if Data["Board"] == "Getting ID..." and !Preview:
		Data["Board"] = str(Settings.TotalBoards)
		User.Boards.merge({Data["Board"] : {"Title" : Data["Title"], "ID" : Data["ID"]}}, true)
	$New/ID.text = "ID: " + Data["Board"]
	if Data.has("Cover"):
		$New.text = "" if Data["Cover"] else "Board"
		$New/ID.visible = false if Data["Cover"] else true



func ChangeID(value):
	Data["Board"] = str(value).trim_suffix(".0")
	$New/ID.text = "ID: " + Data["Board"]

func SetTitle(title):
	$New.text = title

func ChangeCover(txt):
	$New.text = "" if txt else "Board"
	$New/ID.visible = false if txt else true
	$New/Cover.texture = txt
	Data["Cover"] = txt

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Title"] = $New.text
	if User.CurrentPage == Data["Board"]:
		Data["CamPos"] = User.CamPos
		User.Boards[Data["Board"]]["CamPos"] = Data["CamPos"]

func _on_new_pressed() -> void :
	if ClickedOnce:
		if Data.has("CamPos"):
			User.emit_signal("ChangeBoard", Data["Board"], Data["Title"], Data["ID"], Data["CamPos"])
		else :
			Data.merge({"CamPos" : Vector2(640, 352)}, true)
			User.emit_signal("ChangeBoard", Data["Board"], Data["Title"], Data["ID"], Vector2(640, 352))
	ClickedOnce = true
	$Timer.start()

func _on_board_name_text_changed(new_text: String) -> void :
	if User.Boards.size() >= 1:
		if User.Boards.has(User.Boards[Data["Board"]]):
			User.Boards[User.Boards[Data["Board"]]]["Title"] = new_text
	else :
		User.Boards.merge({Data["Board"] : {"Title" : Data["Title"], "ID" : Data["ID"]}}, true)
	Data["Title"] = new_text

func _on_board_name_text_submitted(new_text: String) -> void :
	release_focus()

func _on_timer_timeout() -> void:
	ClickedOnce = false
