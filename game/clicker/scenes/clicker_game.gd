extends Node2D
## ClickerGame — root scene for the Dust Dynasty clicker game.

@onready var digging_view: Node2D = $DiggingView
@onready var clicker_hud: Control = $ClickerHUD


func _ready() -> void:
	pass  # area_changed is handled by DiggingView directly


func _show_digging() -> void:
	digging_view.show()
