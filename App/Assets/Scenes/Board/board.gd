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
	"CamZoom" : Vector2(1, 1),
	"ItemID" : "",
	"Tags" : []
}

var Options := ["Cover", "BoardName", "Board"]

var Preview := false
var ClickedOnce := false

func _ready() -> void :
	Settings.Data["TotalBoards"] += 1
	initItem()
	UpdateValues($New, "Title", "text")
	UpdateValues($New/Cover, "Cover", "texture")
	if Data["Board"] == "Getting ID..." and !Preview:
		Data["Board"] = str(Settings.Data["TotalBoards"])
		User.Boards.merge({Data["Board"] : Data}, true)

func ChangeID(value):
	Data["Board"] = str(value).trim_suffix(".0")

func SetTitle(title):
	$New.text = title

func ChangeCover(txt):
	$New.text = "" if txt else "Board"
	$New/Cover.texture = txt
	Data["Cover"] = txt

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Title"] = $New.text
	if Settings.Data["CurrentPage"]== Data["Board"]:
		Data["CamPos"] = User.CamPos
		Data["CamZoom"] = User.CamZoom
		User.Boards[Data["Board"]]["CamPos"] = Data["CamPos"]
		User.Boards[Data["Board"]]["CamZoom"] = Data["CamZoom"]

func _on_new_pressed() -> void :
	if ClickedOnce:
		System.SwitchBoard(Data["Board"], Data["Title"])
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
