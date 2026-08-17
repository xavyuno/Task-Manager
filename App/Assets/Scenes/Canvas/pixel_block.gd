extends StaticBody2D

var Data := {}

func _ready() -> void:
	Data = {
		"Pos" : position,
		"Size" : scale,
		"Col" : modulate
	}
