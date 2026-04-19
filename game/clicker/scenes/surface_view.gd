extends Node2D
## SurfaceView — the above-ground town hub shown between digging runs.
## Emit mine_requested to return to the digging view; clicker_game.gd listens.

signal mine_requested

@onready var mine_button: BaseButton = %MineButton


func _ready() -> void:
	mine_button.pressed.connect(_on_mine_button_pressed)


func _on_mine_button_pressed() -> void:
	ClickerSoundPlayer.play_ui_click()
	mine_requested.emit()
