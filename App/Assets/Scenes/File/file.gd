extends Item

var Data: = {
	"Type": "File", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Dir": "",
	"CachedImage" : null,
	"ItemID" : "",
	"Tags" : []
}

var Options := [
	"Directory",
	"Ratio",
	"Open"
]

func _ready() -> void :
	initItem()
	LoadFile()

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["CachedImage"] = $Open/Image.texture

func LoadFile():
	var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
	var imgTxt = ImageTexture.new()
	var texture
	if img:
		texture = imgTxt.create_from_image(img)
	else:
		texture = Has("CachedImage")
	if texture:
		$Open / Image.texture = texture
		$Open / Holder.visible = false
		$Open / Title.text = ""
	else:
		$Open / Image.texture = null
		$Open / Title.text = "Preview:"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		var txt
		if file:
			txt = file.get_as_text()
			$Open / Holder / Preview.text = txt
			file.close()
