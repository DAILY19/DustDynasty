extends Control
## ClickerHUD — always-visible heads-up display.
## Manages NavBar buttons, BottomSheet panels, and the shared confirm dialog.
## Binds to ClickerGameState signals; no polling in _process.

@export var std_font: Font
@export var title_font: Font

@onready var dust_label:  Label = %DustLabel
@onready var dps_label:   Label = %DpsLabel

@onready var shop_btn:     NavButton = %ShopNavBtn
@onready var workers_btn:  NavButton = %WorkersNavBtn
@onready var areas_btn:    NavButton = %AreasNavBtn
@onready var prestige_btn: NavButton = %PrestigeNavBtn
@onready var settings_btn: NavButton = %SettingsNavBtn

@onready var shop_sheet:     BottomSheet = %ShopSheet
@onready var workers_sheet:  BottomSheet = %WorkersSheet
@onready var areas_sheet:    BottomSheet = %AreasSheet
@onready var prestige_sheet: BottomSheet = %PrestigeSheet
@onready var settings_sheet: BottomSheet = %SettingsSheet

@onready var _confirm_dialog: GameConfirmDialog = %GameConfirmDialog

## Panel content nodes — used only to connect their confirm_requested signals.
@onready var _prestige_content: Control = %PrestigeContent
@onready var _settings_content: Control = %SettingsContent

var _active_sheet: BottomSheet = null
var _nav_btns: Array[NavButton]
var _sheet_map: Dictionary  # StringName -> BottomSheet
var _pending_action: Callable


func _ready() -> void:
	theme = UIStyle.make_theme(std_font, title_font)

	_nav_btns = [shop_btn, workers_btn, areas_btn, prestige_btn, settings_btn]
	_sheet_map = {
		&"shop":     shop_sheet,
		&"workers":  workers_sheet,
		&"areas":    areas_sheet,
		&"prestige": prestige_sheet,
		&"settings": settings_sheet,
	}

	for btn: NavButton in _nav_btns:
		btn.nav_pressed.connect(_on_nav_pressed)
	for sheet: BottomSheet in _sheet_map.values():
		sheet.panel_closed.connect(_on_panel_closed.bind(sheet))

	_prestige_content.confirm_requested.connect(_on_confirm_requested)
	_settings_content.confirm_requested.connect(_on_confirm_requested)
	_confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)

	ClickerGameState.dust_changed.connect(_on_dust_changed)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	_on_dust_changed(ClickerGameState.dust)
	_refresh_dps()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _active_sheet != null:
		_close_active()
		get_viewport().set_input_as_handled()


# ── Nav handling ──────────────────────────────────────────────────────────

func _on_nav_pressed(id: StringName) -> void:
	var target: BottomSheet = _sheet_map.get(id)
	if target == null:
		return
	if _active_sheet == target:
		_close_active()
		return
	if _active_sheet != null:
		_active_sheet.close()
	_active_sheet = target
	_active_sheet.open()
	_refresh_nav_active()
	ClickerSoundPlayer.play_ui_click()


func _on_panel_closed(sheet: BottomSheet) -> void:
	if _active_sheet == sheet:
		_active_sheet = null
		_refresh_nav_active()


func _close_active() -> void:
	if _active_sheet:
		_active_sheet.close()


func _refresh_nav_active() -> void:
	for btn: NavButton in _nav_btns:
		btn.active = (_sheet_map.get(btn.id) == _active_sheet)


# ── Confirm dialog ────────────────────────────────────────────────────────

func _on_confirm_requested(title: String, body: String, action: Callable) -> void:
	_pending_action = action
	_confirm_dialog.show_dialog(title, body)


func _on_confirm_dialog_confirmed() -> void:
	if _pending_action.is_valid():
		_pending_action.call()
	_pending_action = Callable()


# ── HUD labels ────────────────────────────────────────────────────────────

func _on_dust_changed(amount: float) -> void:
	dust_label.text = "Dust: %s" % ClickerGameState.format_number(amount)


func _on_worker_hired(_worker: WorkerDefinition, _count: int) -> void:
	_refresh_dps()


func _refresh_dps() -> void:
	dps_label.text = "%s/s" % ClickerGameState.format_number(ClickerGameState.worker_total_dps)
