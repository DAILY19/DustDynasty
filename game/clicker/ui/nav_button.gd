class_name NavButton
extends Control
## A single nav-bar button: icon above label, full-area click region.
## Parent (ClickerHUD) sets active = true/false to tint the background.

signal nav_pressed(id: StringName)

@export var id: StringName = &""
@export var label_text: String = "":
	set(v):
		label_text = v
		if is_node_ready():
			_label.text = v
@export var icon: Texture2D:
	set(v):
		icon = v
		if is_node_ready():
			_icon.texture = v

var active: bool = false:
	set(v):
		active = v
		if is_node_ready():
			_refresh_style()

@onready var _bg:     ColorRect  = $BG
@onready var _icon:   TextureRect = $VBox/Icon
@onready var _label:  Label       = $VBox/NavLabel
@onready var _button: Button      = $Button


func _ready() -> void:
	_icon.texture = icon
	_label.text = label_text
	_button.pressed.connect(_on_pressed)
	_refresh_style()


func _refresh_style() -> void:
	_bg.color = UIStyle.NAV_ACTIVE if active else Color.TRANSPARENT


func _on_pressed() -> void:
	nav_pressed.emit(id)
