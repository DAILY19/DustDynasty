extends Control
## SettingsPanel — volume, mute, reset save.
## Attached to SettingsContent inside SettingsSheet's ContentSlot.
## Emits confirm_requested so ClickerHUD can show the shared confirm dialog.

signal confirm_requested(title: String, body: String, action: Callable)

@onready var volume_slider: HSlider    = %VolumeSlider
@onready var mute_button:   CheckButton = %MuteButton
@onready var reset_button:  Button      = %ResetButton


func _ready() -> void:
	volume_slider.value = UserConfig.get_setting("volume")
	mute_button.button_pressed = AudioServer.is_bus_mute(0)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)
	reset_button.pressed.connect(_on_reset_button_pressed)


func _on_volume_slider_value_changed(value: float) -> void:
	UserConfig.update_setting(value, "volume")


func _on_mute_button_toggled(pressed: bool) -> void:
	AudioServer.set_bus_mute(0, pressed)


func _on_reset_button_pressed() -> void:
	confirm_requested.emit(
		"Reset Save?",
		"This will delete all progress.\nAre you sure?",
		func(): ClickerSaveManager.delete_save(); get_tree().reload_current_scene()
	)



func _on_volume_slider_value_changed(value: float) -> void:
	UserConfig.update_setting(value, "volume")


func _on_mute_button_toggled(pressed: bool) -> void:
	AudioServer.set_bus_mute(0, pressed)



