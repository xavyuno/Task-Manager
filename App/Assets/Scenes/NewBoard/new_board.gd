extends Control

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "settingChanged"))

func _process(delta: float) -> void:
	$Grid.visible = Settings.GridSnap
	$Grid.scale = Vector2(Settings.GridSize / 16, Settings.GridSize / 16)
	$Grid.position = (get_global_mouse_position() - size * $Grid.scale).snapped(Vector2(Settings.GridSize, Settings.GridSize))
	

func settingChanged():
	$Center.visible = Settings.ShowCenter
	$Grid.self_modulate = Settings.GridCol

func _on_clean_timeout() -> void:
	if name.contains("@"):
		queue_free()
