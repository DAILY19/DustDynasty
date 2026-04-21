extends PanelContainer
## AreaCard — one entry in the Areas panel.
## Shows area name, cost, and Unlock / Enter / Active buttons.

@onready var area_name_label: Label = %AreaNameLabel
@onready var cost_label: Label = %CostLabel
@onready var switch_button: Button = %SwitchButton
@onready var unlock_button: Button = %UnlockButton

var _area: DiggingViewVariant


func _ready() -> void:
	add_theme_stylebox_override("panel", UIStyle.make_row_bg())
	switch_button.pressed.connect(_on_switch_pressed)
	unlock_button.pressed.connect(_on_unlock_pressed)
	ClickerGameState.area_changed.connect(_on_state_changed)
	ClickerGameState.area_unlocked.connect(_on_state_changed)
	ClickerGameState.dust_changed.connect(_on_state_changed)


func setup(area: DiggingViewVariant) -> void:
	_area = area
	area_name_label.text = area.area_name if area.area_name != "" else area.name
	refresh()


func refresh() -> void:
	if _area == null:
		return
	var is_active: bool = ClickerGameState.current_area == _area
	var is_unlocked: bool = ClickerGameState.unlocked_areas.has(_area)
	var can_afford: bool = ClickerGameState.dust >= _area.purchase_cost

	if is_active:
		switch_button.text = "Active"
		switch_button.disabled = true
		unlock_button.visible = false
		cost_label.text = ""
	elif is_unlocked:
		switch_button.text = "Enter"
		switch_button.disabled = false
		unlock_button.visible = false
		cost_label.text = ""
	else:
		switch_button.text = "Locked"
		switch_button.disabled = true
		unlock_button.visible = true
		unlock_button.text = "Unlock"
		unlock_button.disabled = not can_afford
		cost_label.text = "%s Dust" % ClickerGameState.format_number(_area.purchase_cost)

	modulate.a = 1.0 if (is_unlocked or can_afford) else 0.6


func _on_switch_pressed() -> void:
	ClickerGameState.switch_area(_area)


func _on_unlock_pressed() -> void:
	ClickerGameState.unlock_area(_area)


func _on_state_changed(_ignored: Variant = null) -> void:
	refresh()
