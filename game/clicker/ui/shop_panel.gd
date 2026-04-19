extends PanelContainer
## ShopPanel — lists all UpgradeDefinitions from the registry.
## Rows are instanced from UpgradeRow scene; no hardcoded upgrade entries.

const UPGRADE_ROW_SCENE: String = "res://game/clicker/ui/upgrade_row.tscn"

@onready var scroll_content: VBoxContainer = $ScrollContainer/ScrollContent
@onready var close_button: Button = $CloseButton

var _row_scene: PackedScene
var _rows: Array = []


func _ready() -> void:
	_row_scene = load(UPGRADE_ROW_SCENE)
	_build_rows()
	close_button.pressed.connect(_on_close_button_pressed)
	ClickerGameState.coins_changed.connect(_refresh_rows)
	ClickerGameState.upgrade_purchased.connect(_on_upgrade_purchased)
	visible = false


func _build_rows() -> void:
	Utils.free_children(scroll_content)
	_rows.clear()
	for upgrade in ClickerDataManager.upgrades:
		var row: Node = _row_scene.instantiate()
		scroll_content.add_child(row)
		row.setup(upgrade)
		_rows.append(row)


func _refresh_rows(_ignored: Variant = null) -> void:
	for row in _rows:
		row.refresh()


func _on_upgrade_purchased(_upgrade: UpgradeDefinition, _level: int) -> void:
	_refresh_rows()


func _on_close_button_pressed() -> void:
	visible = false
