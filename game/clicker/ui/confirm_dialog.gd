class_name GameConfirmDialog
extends Control
## Full-screen confirmation dialog with a darkened backdrop.
## Call show_dialog() then listen to confirmed / cancelled signals.

signal confirmed
signal cancelled

@onready var _title_label: Label  = %TitleLabel
@onready var _body_label:  Label  = %BodyLabel
@onready var _yes_btn:     Button = %YesButton
@onready var _no_btn:      Button = %NoButton


func _ready() -> void:
	_yes_btn.pressed.connect(_on_yes)
	_no_btn.pressed.connect(_on_no)
	visible = false


func show_dialog(title: String, body: String) -> void:
	_title_label.text = title
	_body_label.text  = body
	visible = true


func _on_yes() -> void:
	visible = false
	confirmed.emit()


func _on_no() -> void:
	visible = false
	cancelled.emit()
