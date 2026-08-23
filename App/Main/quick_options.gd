extends Panel

var selected := 0

func _ready() -> void:
	for i in Settings.AvailableQuickOptions:
		var butt = Button.new()
		butt.custom_minimum_size = Vector2(32, 32)
		butt.name = i.to_kebab_case().replace("-", " ").capitalize()
		butt.text = i.to_kebab_case().replace("-", " ").capitalize()
		butt.pressed.connect(EditOption.bind(i))
		$ScrollHolder/Options.add_child(butt)
	for i in $QuickHolder.get_children():
		i.connect("pressed", Pressed.bind(int(i.name)))
	ShowSelected()

func Pressed(ID):
	selected = ID-1
	ShowSelected()

func _physics_process(delta: float) -> void:
	$Title.text = Settings.Data["QuickOptions"][selected]

func ShowSelected():
	for i in 3:
		if i == selected:
			get_node("Selected" + str(1+i)).visible = true
		else:
			get_node("Selected" + str(1+i)).visible = false

func EditOption(opt):
	Settings.Data["QuickOptions"][selected] = opt.replace("_", "")
	Settings.emit_signal("SettingsChanged")
