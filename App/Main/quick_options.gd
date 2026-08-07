extends Panel

var selected := 0
var Options := [
	"Show_Center",
	"Reset_Cam",
	"Calendar"
]

func _ready() -> void:
	for i in Options:
		var butt = Button.new()
		butt.custom_minimum_size = Vector2(32, 32)
		butt.name = i.replace("_", " ")
		butt.text = i.replace("_", " ")
		butt.pressed.connect(EditOption.bind(i))
		$ScrollHolder/Options.add_child(butt)

func _physics_process(delta: float) -> void:
	match selected:
		0:
			$Selected1.visible = true
			$Selected2.visible = false
		1:
			$Selected1.visible = false
			$Selected2.visible = true
	$SelectedLabel.text = str(selected + 1) + ": " + Settings.QuickOptions[selected]

func EditOption(opt):
	Settings.QuickOptions[selected] = opt.replace("_", "")
	Settings.emit_signal("SettingsChanged")

func _on_q_1_pressed() -> void:
	selected = 0

func _on_q_2_pressed() -> void:
	selected = 1
