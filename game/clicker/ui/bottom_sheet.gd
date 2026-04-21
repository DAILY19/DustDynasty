class_name BottomSheet
extends Control
## Reusable bottom-sheet panel that slides up from below the NavBar.
## Each sheet's content is defined inline in clicker_game.tscn under the
## Panel/VBox/ContentSlot hierarchy. Call open() / close() from ClickerHUD.

signal panel_closed

## Title shown in the sheet header — set per-sheet in the inspector.
@export var sheet_title: String = "":
	set(v):
		sheet_title = v
		if is_node_ready() and _title_label:
			_title_label.text = v

const _SLIDE_DURATION := 0.18
## Closed: Panel is fully below the NavBar (off-screen).
const _CLOSED_Y := 640.0
## Open: Panel's bottom edge aligns with the NavBar top (y=576).
const _OPEN_Y   := UIStyle.SHEET_OPEN_Y   # 160.0

@onready var _panel:       PanelContainer = $Panel
@onready var _title_label: Label          = $Panel/VBox/Header/TitleLabel
@onready var _close_btn:   Button         = $Panel/VBox/Header/CloseButton

var _tween: Tween = null
var _is_open: bool = false


func _ready() -> void:
	_panel.custom_minimum_size = Vector2(UIStyle.SHEET_WIDTH, UIStyle.SHEET_HEIGHT)
	_panel.size = Vector2(UIStyle.SHEET_WIDTH, UIStyle.SHEET_HEIGHT)
	_panel.position = Vector2(0.0, _CLOSED_Y)
	_panel.add_theme_stylebox_override("panel", UIStyle.make_sheet_bg())
	_title_label.text = sheet_title
	_close_btn.pressed.connect(close)
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false


func is_open() -> bool:
	return _is_open


func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	_kill_tween()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_panel, "position:y", _OPEN_Y, _SLIDE_DURATION)


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	_kill_tween()
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_panel, "position:y", _CLOSED_Y, _SLIDE_DURATION)
	_tween.tween_callback(_on_slide_finished)


func _on_slide_finished() -> void:
	visible = false
	panel_closed.emit()


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null

