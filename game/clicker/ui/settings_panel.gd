extends PanelContainer
## SettingsPanel — volume, mute, reset save, credits.
## Delegates to existing UserConfig singleton.

@onready var volume_slider: HSlider = %VolumeSlider
@onready var mute_button: CheckButton = %MuteButton
@onready var reset_button: Button = %ResetButton
@onready var close_button: Button = %CloseButton
@onready var confirm_reset_dialog: ConfirmationDialog = %ConfirmResetDialog


func _ready() -> void:
	volume_slider.value = UserConfig.get_setting("volume")
	mute_button.button_pressed = AudioServer.is_bus_mute(0)
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
