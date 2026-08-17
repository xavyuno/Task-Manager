extends HBoxContainer

@onready var home: Button = $Home
@onready var previous: Button = $Previous

var PrevTitle := ""
var PrevID := ""

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))
	for i in get_children():
		i.visible = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("PreviousBoard"):
		if User.Boards.has(PrevID):
			User.emit_signal("ChangeBoard", PrevID, PrevTitle, "", User.Boards[PrevID]["CamPos"])
		else :
			User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.CamPosBoard)

func ChangedBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352)):
	User.PreviousPage = PrevID
	User.PreviousTitle = PrevTitle
	User.emit_signal("AllFocusLost")
	if get_node("../../../Boards/" + Board).is_in_group("NoCanvas"):
		home.visible = true
		home.text = "Home"
		previous.visible = false
		return
	if Board != "Home":
		if !User.Boards.has(Board):
			var board = preload("res://App/Assets/Scenes/NewBoard/NewBoard.tscn").instantiate()
			board.name = Board
			get_tree().current_scene.get_node("Boards").add_child(board)
			User.Boards.merge({Board : {"Title" : Title, "ID" : ID}}, true)
		if User.Boards[Board]["ID"] != "Home":
			PrevTitle = User.Boards[User.Boards[Board]["ID"]]["Title"]
			PrevID = User.Boards[Board]["ID"]
			if PrevTitle.is_empty():
				PrevTitle = "Untitled Board: " + PrevID
			previous.text = PrevTitle + "/"
			home.text = "Home/.../"
			home.visible = true
			previous.visible = true
		else :
			home.text = "Home/"
			previous.text = "Home/"
			PrevTitle = "Home"
			PrevID = "Home"
			home.visible = true
			previous.visible = false
	if Board.similarity("Home") == 1:
		$NewBoard.visible = false
		previous.visible = false
		home.visible = false
	else:
		var tempTitle = Title
		if tempTitle.is_empty():
			tempTitle = "Untitled Board: " + Board
		$NewBoard.text = tempTitle
		$NewBoard.visible = true

func _on_home_pressed() -> void:
	User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.CamPosBoard)

func _on_previous_pressed() -> void:
	User.emit_signal("ChangeBoard", PrevID, PrevTitle, "", User.Boards[PrevID]["CamPos"])
