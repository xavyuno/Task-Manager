extends TabContainer

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))
	User.connect("SaveObjectData", Callable(self, "saveItems"))
	User.emit_signal("ChangeBoard", "Home", "Home", "")

func _exit_tree() -> void :
	saveItems()

func saveItems():
	if User.StillLoading:
		return
	User.StoredHistory = []
	for i in get_children(true):

		if i.name.similarity("Settings") < 1:
			if i.has_method("GetData"):

				User.StoredHistory.append(i.GetData())
			for j in i.get_children(true):

				if j.has_method("GetData"):

					User.StoredHistory.append(j.GetData())

func ChangeBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352)):
	var Found = false
	for i in get_tab_count():
		if get_tab_control(i).name == Board:
			current_tab = i
			User.CurrentPage = Board
			User.PageTitle = Title
			Found = true

	if !Found:
		var NewBoard = preload("res://App/Assets/Scenes/NewBoard/NewBoard.tscn").instantiate()
		NewBoard.name = Board
		get_parent().get_node("Boards/").add_child(NewBoard)
		current_tab = get_tab_count() - 1

		User.CurrentPage = Board
		User.PageTitle = Title
