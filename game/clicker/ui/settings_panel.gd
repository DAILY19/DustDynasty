extends PanelContainer
## SettingsPanel — volume, mute, reset save, credits.
## Delegates to existing UserConfig singleton.

@onready var volume_slider: HSlider = $VBoxContainer/VBox/VolumeSlider
@onready var mute_button: CheckButton = $VBoxContainer/VBox/MuteButton
@onready var reset_button: Button = $VBoxContainer/VBox/ResetButton
@onready var close_button: Button = $VBoxContainer/Header/CloseButton
@onready var confirm_reset_dialog: ConfirmationDialog = $ConfirmResetDialog


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = UIStyle.SMALL_PANEL_POS
	size = UIStyle.SMALL_PANEL_SIZE
	add_theme_stylebox_override("panel", UIStyle.make_panel_bg())
	var title_lbl: Label = $VBoxContainer/Header/TitleLabel
	title_lbl.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	close_button.add_theme_stylebox_override("normal", UIStyle.make_button_normal())
	close_button.add_theme_stylebox_override("hover", UIStyle.make_button_hover())
	close_button.add_theme_stylebox_override("pressed", UIStyle.make_button_pressed())
	close_button.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	volume_slider.value = UserConfig.get_setting("volume")
	mute_button.button_pressed = AudioServer.is_bus_mute(0)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)
	reset_button.pressed.connect(_on_reset_button_pressed)
	confirm_reset_dialog.confirmed.connect(_on_confirm_reset_dialog_confirmed)
	close_button.pressed.connect(_on_close_button_pressed)
	visible = false


func _on_volume_slider_value_changed(value: float) -> void:
	UserConfig.update_setting(value, "volume")


func _on_mute_button_toggled(pressed: bool) -> void:
	AudioServer.set_bus_mute(0, pressed)


func _on_reset_button_pressed() -> void:
	confirm_reset_dialog.popup_centered()


func _on_confirm_reset_dialog_confirmed() -> void:
	ClickerSaveManager.delete_save()
	get_tree().reload_current_scene()


func _on_close_button_pressed() -> void:
	visible = false
