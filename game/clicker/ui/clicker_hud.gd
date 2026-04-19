extends Control
## ClickerHUD — always-visible heads-up display.
## Binds to ClickerGameState signals; no polling in _process.

@onready var coin_label: Label = %CoinLabel
@onready var depth_label: Label = %DepthLabel
@onready var dust_label: Label = %DustLabel
@onready var dps_label: Label = %DpsLabel
@onready var shop_button: BaseButton = %ShopButton
@onready var workers_button: BaseButton = %WorkersButton
@onready var prestige_button: BaseButton = %PrestigeButton
@onready var crafting_button: BaseButton = %CraftingButton
@onready var settings_button: BaseButton = %SettingsButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var workers_panel: PanelContainer = %WorkersPanel
@onready var prestige_panel: PanelContainer = %PrestigePanel
@onready var crafting_panel: PanelContainer = %CraftingPanel
@onready var settings_panel: PanelContainer = %SettingsPanel


func _ready() -> void:
	shop_button.pressed.connect(_on_shop_button_pressed)
	workers_button.pressed.connect(_on_workers_button_pressed)
	prestige_button.pressed.connect(_on_prestige_button_pressed)
	crafting_button.pressed.connect(_on_crafting_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	ClickerGameState.coins_changed.connect(_on_coins_changed)
	ClickerGameState.depth_changed.connect(_on_depth_changed)
	ClickerGameState.dust_changed.connect(_on_dust_changed)
	# Initial display
	_on_coins_changed(ClickerGameState.coins)
	_on_depth_changed(ClickerGameState.depth)
	_on_dust_changed(ClickerGameState.dust)


func _on_coins_changed(amount: float) -> void:
	coin_label.text = ClickerGameState.format_number(amount)
	var dps: float = ClickerGameState.worker_total_dps
	dps_label.text = "%s/s" % ClickerGameState.format_number(dps)


func _on_depth_changed(new_depth: int) -> void:
	depth_label.text = "Depth: %d" % new_depth


func _on_dust_changed(amount: float) -> void:
	dust_label.text = "Dust: %s" % ClickerGameState.format_number(amount)


func _on_shop_button_pressed() -> void:
	_toggle_panel(shop_panel)


func _on_workers_button_pressed() -> void:
	_toggle_panel(workers_panel)


func _on_prestige_button_pressed() -> void:
	_toggle_panel(prestige_panel)


func _on_crafting_button_pressed() -> void:
	_toggle_panel(crafting_panel)


func _on_settings_button_pressed() -> void:
	_toggle_panel(settings_panel)


func _close_all_panels() -> void:
	var all_panels: Array = [shop_panel, workers_panel, prestige_panel, crafting_panel, settings_panel]
	for p in all_panels:
		p.visible = false


func _toggle_panel(panel: PanelContainer) -> void:
	var all_panels: Array = [shop_panel, workers_panel, prestige_panel, crafting_panel, settings_panel]
	var was_visible: bool = panel.visible
	for p in all_panels:
		p.visible = false
	panel.visible = not was_visible
	if panel.visible:
		ClickerSoundPlayer.play_ui_click()
