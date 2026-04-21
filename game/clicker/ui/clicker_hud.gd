extends Control
## ClickerHUD — always-visible heads-up display.
## Binds to ClickerGameState signals; no polling in _process.

@onready var dust_label: Label = %DustLabel
@onready var dps_label: Label = %DpsLabel
@onready var shop_button: BaseButton = %ShopButton
@onready var workers_button: BaseButton = %WorkersButton
@onready var prestige_button: BaseButton = %PrestigeButton
@onready var settings_button: BaseButton = %SettingsButton
@onready var areas_button: BaseButton = %AreasButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var workers_panel: PanelContainer = %WorkersPanel
@onready var prestige_panel: PanelContainer = %PrestigePanel
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var areas_panel: PanelContainer = %AreasPanel


func _ready() -> void:
	shop_button.pressed.connect(_on_shop_button_pressed)
	workers_button.pressed.connect(_on_workers_button_pressed)
	prestige_button.pressed.connect(_on_prestige_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	areas_button.pressed.connect(_on_areas_button_pressed)
	ClickerGameState.dust_changed.connect(_on_dust_changed)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	# Initial display
	_on_dust_changed(ClickerGameState.dust)
	_refresh_dps()


func _on_dust_changed(amount: float) -> void:
	dust_label.text = "Dust: %s" % ClickerGameState.format_number(amount)


func _on_worker_hired(_worker: WorkerDefinition, _count: int) -> void:
	_refresh_dps()


func _refresh_dps() -> void:
	dps_label.text = "%s/s" % ClickerGameState.format_number(ClickerGameState.worker_total_dps)


func _on_shop_button_pressed() -> void:
	_toggle_panel(shop_panel)


func _on_workers_button_pressed() -> void:
	_toggle_panel(workers_panel)


func _on_prestige_button_pressed() -> void:
	_toggle_panel(prestige_panel)


func _on_settings_button_pressed() -> void:
	_toggle_panel(settings_panel)


func _on_areas_button_pressed() -> void:
	_toggle_panel(areas_panel)


func _close_all_panels() -> void:
	var all_panels: Array = [shop_panel, workers_panel, prestige_panel, settings_panel, areas_panel]
	for p in all_panels:
		p.visible = false


func _toggle_panel(panel: PanelContainer) -> void:
	var all_panels: Array = [shop_panel, workers_panel, prestige_panel, settings_panel, areas_panel]
	var was_visible: bool = panel.visible
	for p in all_panels:
		p.visible = false
	panel.visible = not was_visible
	if panel.visible:
		ClickerSoundPlayer.play_ui_click()
