extends PanelContainer
## OfflineEarningsPanel — shown on launch when offline earnings are awarded.

@onready var earnings_label: Label = %EarningsLabel
@onready var time_label: Label = %TimeLabel
@onready var collect_button: Button = %CollectButton


func _ready() -> void:
	ClickerGameState.offline_earnings_awarded.connect(_on_earnings_awarded)
	visible = false


func _on_earnings_awarded(amount: float, seconds: float) -> void:
	var hours: int = int(seconds / 3600)
	var minutes: int = int(fmod(seconds, 3600) / 60)
	earnings_label.text = "While you were away you earned:\n%s coins!" % ClickerGameState.format_number(amount)
	time_label.text = "(%dh %dm offline)" % [hours, minutes]
	popup_centered()


func _on_collect_button_pressed() -> void:
	visible = false
