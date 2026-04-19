extends PanelContainer
## CraftingPanel — crafting recipes panel.
## Currently a stub; full recipe system planned for a future update.
## When recipes are added, drop new CraftingRecipe .tres files in
## game/clicker/registries/recipes/ — no code changes required.

@onready var close_button: Button = $CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	visible = false


func _on_close_pressed() -> void:
	visible = false
