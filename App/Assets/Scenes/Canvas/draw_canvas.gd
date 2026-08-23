extends Item

var Initialized := false
var Editing := false
var ClickedOnce := false

var StartPos = Vector2.ZERO

var Data: = {
	"Type": "Canvas", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"ItemID" : "",
	"Pixels" : {},
	"Tags" : []
}

var Options := [
	"Capture",
	"Clear"
]

func _ready() -> void:
	initItem()
	if Data["Pixels"].size() >= 1:
		var Total := 0
		for i in Data["Pixels"].values():
			AddPixel(i["Pos"], i["Size"], i["Col"], int(i["ID"]))
	User.connect("AllFocusLost", Callable(self, "DoneEditing"))
	User.connect("ItemFocusLost", Callable(self, "DoneEditing"))

func DoneEditing():
	Editing = false

func _process(delta: float) -> void:
	Data["Size"] = size
	Data["Pos"] = position
	$Holder/Edit.size = size
	$Holder/Edit.visible = !Editing

func AddPixel(Pos, Size, Col, index = -1):
	if index == -1:
		index = str(Data["Pixels"].size())
	else:
		index = str(index)
	var TempData := {
		"Pos" : Pos,
		"Size" : Size,
		"Col" : Col,
		"ID" : index
	}
	if !Data["Pixels"].has(index):
		Data["Pixels"].merge({index : TempData},true)
	var Pixel = preload("res://App/Assets/Scenes/Canvas/pixel_block.tscn").instantiate()
	Pixel.position = Pos
	Pixel.scale = Vector2(Size, Size)
	Pixel.modulate = Col
	Pixel.name = index
	$DrawCanvas/View/Pixels.add_child(Pixel)

func RemovePixel(ID):
	Data["Pixels"].erase(ID)

func Capture():
	var txt = $DrawCanvas/View.get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("user://CanvasImages")
	var Total = DirAccess.get_files_at("user://CanvasImages").size()
	txt.save_png("user://CanvasImages/" + str(Total)  + ".png")
	System.AddObject(preload("res://App/Assets/Scenes/File/File.tscn"),
	false,
	Settings.Data["CurrentPage"],
	{
		"Pos" : position,
		"Size" : size,
		"CachedImage" : ImageTexture.create_from_image(txt)
	}
	)
	Delete()

func _on_draw_canvas_mouse_entered() -> void:
	Canvas.InCanvas = true

func _on_draw_canvas_mouse_exited() -> void:
	Canvas.InCanvas = false

func Clear():
	Data["Pixels"] = {}
	for i in $DrawCanvas/View/Pixels.get_children():
		i.queue_free()

func _on_edit_pressed() -> void:
	if ClickedOnce:
		Editing = true
		ClickedOnce = false
	else:
		ClickedOnce = true
		$Holder/Timer.start()

func _on_timer_timeout() -> void:
	ClickedOnce = false
