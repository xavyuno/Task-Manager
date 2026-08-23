extends HBoxContainer

@onready var title: Label = $Title

var Event := ""
var Changing := false

func _ready() -> void:
	title.text = Event
	for i in InputMap.action_get_events(Event):
		var KB = preload("res://App/Components/Keybind/keybind.tscn").instantiate()
		KB.Keybind = i
		KB.ShowCtrl = false
		KB.Event = Event
		InputMap.action_add_event(Event, i)
		$Holder.add_child(KB)
	if Settings.Data["SavedKeybinds"][Event].size() >= 1:
		for i in Settings.Data["SavedKeybinds"][Event]:
			var KB = preload("res://App/Components/Keybind/keybind.tscn").instantiate()
			KB.Keybind = i
			KB.Event = Event
			InputMap.action_add_event(Event, i)
			$Holder.add_child(KB)

func _on_add_pressed() -> void:
	Changing = true

func _input(event: InputEvent) -> void:
	if event is InputEventKey and Changing:
		Changing = false
		var KB = preload("res://App/Components/Keybind/keybind.tscn").instantiate()
		KB.Keybind = event
		KB.Event = Event
		Settings.Data["SavedKeybinds"][Event].append(event)
		InputMap.action_add_event(Event, event)
		$Holder.add_child(KB)
		Settings.emit_signal("SettingsChanged")
