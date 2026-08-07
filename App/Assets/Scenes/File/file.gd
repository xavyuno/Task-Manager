extends Item

var Data: = {
	"Type": "File", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Dir": "",
	"CachedImage" : null,
	"ItemID" : 0
}

var Options := [
	"Dir",
	"Ratio",
	"Open"
]

func _ready() -> void :
	initItem()
	InitFile()

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size

func InitFile():
	if Data["Dir"] == "":
		return
	var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
	var imgTxt = ImageTexture.new()
	var texture
	if img:
		texture = imgTxt.create_from_image(img)
	if texture is Texture:
		$Open / Image.texture = texture
		$Open / Holder.visible = false
		$Open / Title.text = ""
		if Has("CachedImage"):
			Data["CachedImage"] = texture
		else:
			Data["CachedImage"] = texture
	else:
		if Has("CachedImage"):
			Data["CachedImage"] = null
		$Open / Image.texture = null
		$Open / Title.text = "Open"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		var txt
		if file:
			txt = file.get_as_text()
			$Open / Holder / Preview.text = "Preview:\n" + txt
			file.close()

func LoadFile():
	if Data["Dir"] == "":
		return
	var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
	var imgTxt = ImageTexture.new()
	var texture
	if img:
		texture = imgTxt.create_from_image(img)
	if texture is Texture:
		$Open / Image.texture = texture
		$Open / Holder.visible = false
		$Open / Title.text = ""
		if Has("CachedImage"):
			Data["CachedImage"] = texture
		else:
			Data["CachedImage"] = texture
	else:
		if Has("CachedImage"):
			Data["CachedImage"] = null
		$Open / Image.texture = null
		$Open / Title.text = "Open"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		var txt
		if file:
			txt = file.get_as_text()
			$Open / Holder / Preview.text = "Preview:\n" + txt
			file.close()
	print(Data)
