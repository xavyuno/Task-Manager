extends Area2D

var Bodies := []

func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()
	scale = Vector2(Canvas.PixelSize, Canvas.PixelSize)
	if Canvas.InCanvas:
		if Input.is_action_pressed("Click") and Canvas.Action == "draw":
			$"../../..".AddPixel(position,
			Canvas.PixelSize,
			Canvas.Col
			)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Pixel") and Input.is_action_pressed("DeletePixel"):
		$"../../..".call_deferred("RemovePixel", body.name)
		body.queue_free()
