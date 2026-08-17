extends Control

signal WarningSelectted

var Info := ""

func _ready() -> void:
	$Holder/Info.text = Info
	print("2")

func _on_accept_pressed() -> void:
	emit_signal("WarningSelectted", true)
	queue_free()

func _on_decline_pressed() -> void:
	emit_signal("WarningSelectted", false)
	queue_free()
