extends PanelContainer
## PrestigePanel — shows pending dust, bonus list, and prestige button.

const PRESTIGE_ROW_SCENE: String = "res://game/clicker/ui/prestige_row.tscn"

@onready var pending_dust_label: Label = %PendingDustLabel
@onready var owned_dust_label: Label = %OwnedDustLabel
@onready var scroll_content: VBoxContainer = %ScrollContent
@onready var prestige_button: Button = %PrestigeButton
@onready var close_button: Button = %CloseButton
@onready var confirm_dialog: ConfirmationDialog = %ConfirmDialog

var _row_scene: PackedScene


func _ready() -> void:
	_row_scene = load(PRESTIGE_ROW_SCENE)
	_build_rows()
	ClickerGameState.coins_changed.connect(_refresh)
	ClickerGameState.dust_changed.connect(_refresh)
	ClickerGameState.prestige_activated.connect(_on_prestige_activated)
	visible = false


func _build_rows() -> void:
	Utils.free_children(scroll_content)
	for prestige in ClickerDataManager.prestige_bonuses:
		var row: Node = _row_scene.instantiate()
		scroll_content.add_child(row)
		row.setup(prestige)


func _refresh(_ignored: Variant = null) -> void:
	var pending: float = ClickerGameState.get_pending_dust()
	pending_dust_label.text = "Earn on Prestige: %s Dust" % ClickerGameState.format_number(pending)
	owned_dust_label.text = "Owned Dust: %s" % ClickerGameState.format_number(ClickerGameState.dust)
	prestige_button.disabled = pending < 1.0


func _on_prestige_activated(_count: int) -> void:
	_refresh()
	for row in scroll_content.get_children():
		if row.has_method("refresh"):
			row.refresh()


func _on_prestige_button_pressed() -> void:
	confirm_dialog.popup_centered()


func _on_confirm_dialog_confirmed() -> void:
	ClickerGameState.prestige()


func _on_close_button_pressed() -> void:
	visible = false
