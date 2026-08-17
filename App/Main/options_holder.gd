extends ScrollContainer

var ItemNode = null
var Options := []
var popupConst = null

func _ready() -> void:
	User.connect("ItemFocused", Callable(self, "ItemFocused"))
	User.connect("ItemFocusLost", Callable(self, "ItemFocusLost"))

func DeletePressed():
	ItemNode.Delete()

func RatioPressed():
	var Lowest: float = ItemNode.size.x
	if ItemNode.size.y < Lowest:
		Lowest = ItemNode.size.y
	ItemNode.size = Vector2(Lowest, Lowest)

func TitlePressed():
	if ItemNode.has_node("Title"):
		ItemNode.get_node("Title").visible = !ItemNode.get_node("Title").visible
	else :
		ItemNode.get_node("Top/Title").visible = !ItemNode.get_node("Top/Title").visible

func NotePressed():
	ItemNode.get_node("Preview").visible = !ItemNode.get_node("Preview").visible

func DirectoryPressed():
	var dirarray: Array = ItemNode.Data["Dir"].split("/")
	$"../../FileDialog".current_dir = ItemNode.Data["Dir"].trim_suffix(dirarray[dirarray.size() - 1])
	$"../../FileDialog".popup(Rect2(0, 0, 600, 600))

func CoverPressed():
	var popup := FileDialog.new()
	popup.connect("file_selected", Callable(self, "popup"))
	popup.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	popup.access = FileDialog.ACCESS_FILESYSTEM
	for i in ["png", "jpeg"]:
		popup.add_filter("*." + i)
	get_tree().root.add_child(popup)
	popup.popup(Rect2i(500, 500, 600, 600))
	popupConst = popup

func OpenPressed():
	OS.shell_open(ProjectSettings.globalize_path(ItemNode.Data["Dir"]))

func popup(path):
	var img = Image.load_from_file(ProjectSettings.globalize_path(path))
	var texture = ImageTexture.new()
	var imgtxt = texture.create_from_image(img)
	ItemNode.ChangeCover(imgtxt)
	popupConst.queue_free()

func ItemFocusLost():
	User.SelectedObject = null
	if get_node("../../../../Boards/" + User.CurrentPage).is_in_group("NoCanvas"):
		$"../ItemHolder".visible = false
		visible = false
	else:
		$"../ItemHolder".visible = true
		visible = false

func ItemFocused(path : NodePath):
	if get_node("../../../../Boards/" + User.CurrentPage).is_in_group("NoCanvas"):
		$"../ItemHolder".visible = false
		visible = false
	else:
		$"../ItemHolder".visible = false
		visible = true
	ItemNode = get_node(path)
	Options = ItemNode.Options
	if Options.size() <= 0:
		return
	for i in $Items.get_children():
		if !i.name in ["ItemID", "ID"]: 
			i.visible = false
	for i in Options.size():
		if !$Items.get_node(Options[i]):
			var but = Button.new()
			but.name = Options[i]
			but.text = Options[i]
			$Items.get_child(0).add_sibling(but)
			but.connect("pressed", Callable(self, but.name + "Pressed"))
			but.tooltip_text = but.name
		else:
			$Items.get_node(Options[i]).visible = true
	ValidateValue($Items/ID, "ID", "text", GetValue("ID: ", "ID"))
	ValidateValue($Items/ItemID, "ItemID", "text", GetValue("Item ID: ", "ItemID"))
	ValidateValue($Items/Board, "Board", "value", GetValue("", "Board"))
	ValidateValue($Items/FontSize, "FontSize", "value", GetValue("", "FontSize"))
	ValidateValue($Items/TitleSize, "TitleSize", "value", GetValue("", "TitleSize"))
	ValidateValue($Items/Link, "Link", "text", GetValue("", "Link"))
	ValidateValue($Items/BoardName, "Title", "text", GetValue("", "Title"))

func GetValue(before, parameter, after = ""):
	if ItemNode.Data.has(parameter):
		if before == "" and after == "":
			return ItemNode.Data[parameter]
		else :
			return before + str(ItemNode.Data[parameter]) + after
	else :
		return ""

func CapturePressed():
	ItemNode.Capture()

func ClearPressed():
	ItemNode.Clear()

func ThumbnailPressed():
	OS.shell_open(ProjectSettings.globalize_path(ItemNode.GetImage()))

func GoToPressed():
	OS.shell_open(ItemNode.Data["Link"])

func ShowProgressPressed():
	ItemNode.get_node("Top/Progress").visible = !ItemNode.get_node("Top/Progress").visible

func ValidateValue(Nodepath, value, parameter, change = ""):
	change = str(change)
	if ItemNode.Data.has(value):
		if change == "":
			Nodepath.set(parameter, ItemNode.Data[value])
		else :
			Nodepath.set(parameter, change)

func _on_board_value_changed(value: float) -> void:
	ItemNode.ChangeID(value)

func _on_font_size_value_changed(value: float) -> void:
	ItemNode.ChangeFontSize(value)

func _on_title_size_value_changed(value: float) -> void:
	ItemNode.ChangeTitleSize(value)

func _on_file_dialog_file_selected(path: String) -> void:
	ItemNode.Data["Dir"] = path
	ItemNode.LoadFile()

func _on_link_focus_exited() -> void:
	ItemNode.SetLink($Items/Link.text)

func _on_board_name_text_changed(new_text: String) -> void:
	ItemNode.SetTitle(new_text)
