extends VBoxContainer

@onready var search_query: HBoxContainer = $SearchQuery
@onready var input: LineEdit = $Input
@onready var results: HFlowContainer = $Results

var Focued := false

func _ready() -> void:
	User.connect("AllFocusLost", Callable(self, "LostFocus"))
	User.connect("SearchResultSend", Callable(self, "SearchResultRecieved"))
	for i in User.SearchQueries:
		var butt = Button.new()
		butt.text = i
		search_query.add_child(butt)
		butt.connect("pressed", Pressed.bind(butt.text))

func _process(delta: float) -> void:
	if get_node("../../../Boards/" + User.CurrentPage).is_in_group("NoCanvas"):
		visible = false
	else:
		visible = true
	if Input.is_action_just_pressed("StartSearch"):
		if Focued:
			Focued = false
			search_query.visible = false
			results.visible = false
			input.text = ""
			User.emit_signal("Searched", input.text)
			input.release_focus()
		else:
			input.grab_focus()

func SearchResultRecieved(Info : Dictionary):
	User.SearchResults.append(Info)
	AddResults()

func AddResults():
	for i in results.get_children():
		if i is Button:
			i.queue_free()
	if User.SearchResults.size() >= 1:
		results .visible = true
		for i in User.SearchResults:
			var Butt = Button.new()
			Butt.text = i["Search"].replace("\n", "")
			Butt.text_overrun_behavior = TextServer.OVERRUN_TRIM_WORD_ELLIPSIS
			Butt.custom_minimum_size = Vector2(172, 0)
			results.add_child(Butt)
			if i["ID"] != "Home":
				Butt.tooltip_text = User.Boards[i["ID"]]["Title"] + ": \n" + i["Search"]
			else:
				Butt.tooltip_text = "Home: \n" + i["Search"]
			Butt.connect("pressed", System.GoTo.bind(i))
	else:
		results.visible = false

func Pressed(Query):
	if Query == "Clear":
		input.text = ""
	else:
		input.text = Query
	User.emit_signal("Searched", Query)
	input.grab_focus()

func _on_input_focus_entered() -> void:
	search_query.visible = true
	Focued = true
	AddResults()

func LostFocus():
	Focued = false
	search_query.visible = false
	results.visible = false

func _on_input_text_changed(new_text: String) -> void:
	User.SearchResults = []
	User.emit_signal("Searched", new_text)
	AddResults()

func _on_sen_value_changed(value: float) -> void:
	User.SearchResults = []
	User.SearchSen = value
	User.emit_signal("Searched", input.text)
