extends HBoxContainer

func _physics_process(delta: float) -> void:
	visible = Canvas.SelectedCanvas

func _on_color_picker_button_color_changed(color: Color) -> void:
	Canvas.Col = color

func _on_pixel_size_value_changed(value: float) -> void:
	Canvas.PixelSize = value
