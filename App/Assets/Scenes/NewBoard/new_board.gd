extends Control

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "settingChanged"))

func _process(delta: float) -> void:
	$Grid.visible = Settings.Data["GridSnap"]
	$Grid.scale = Vector2(Settings.Data["GridSize"] / 16, Settings.Data["GridSize"] / 16)
	$Grid.position = (get_global_mouse_position() - size * $Grid.scale).snapped(Vector2(Settings.Data["GridSize"], Settings.Data["GridSize"]))
	

func settingChanged():
	$Center.visible = Settings.Data["ShowCenter"]
	$Grid.self_modulate = Settings.Data["GridCol"]

func _on_clean_timeout() -> void:
	if name.contains("@"):
		queue_free()
