extends PanelContainer
## OfflineEarningsPanel — shown on launch when offline earnings are awarded.

@onready var earnings_label: Label = $VBoxContainer/VBox/EarningsLabel
@onready var time_label: Label = $VBoxContainer/VBox/TimeLabel
@onready var collect_button: Button = $VBoxContainer/VBox/CollectButton


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = UIStyle.SMALL_PANEL_POS
	size = UIStyle.SMALL_PANEL_SIZE
	add_theme_stylebox_override("panel", UIStyle.make_panel_bg())
	var title_lbl: Label = $VBoxContainer/Header/TitleLabel
	title_lbl.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	collect_button.pressed.connect(_on_collect_button_pressed)
	ClickerGameState.offline_earnings_awarded.connect(_on_earnings_awarded)
	visible = false


func _on_earnings_awarded(amount: float, seconds: float) -> void:
	var hours: int = int(seconds / 3600)
	var minutes: int = int(fmod(seconds, 3600) / 60)
	earnings_label.text = "While you were away you earned:\n%s coins!" % ClickerGameState.format_number(amount)
	time_label.text = "(%dh %dm offline)" % [hours, minutes]
	visible = true


func _on_collect_button_pressed() -> void:
	visible = false
