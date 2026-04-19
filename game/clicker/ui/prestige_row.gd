extends HBoxContainer
## PrestigeRow — one bonus entry inside PrestigePanel.

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var cost_label: Label = %CostLabel
@onready var buy_button: Button = %BuyButton
@onready var description_label: Label = %DescriptionLabel

var _prestige: PrestigeDefinition


func setup(prestige: PrestigeDefinition) -> void:
	_prestige = prestige
	name_label.text = prestige.get_display_name()
	description_label.text = prestige.description
	if prestige.icon:
		icon_texture.texture = prestige.icon
	refresh()


func refresh() -> void:
	if _prestige == null:
		return
	var level: int = ClickerGameState.prestige_levels.get(_prestige.name, 0)
	var cost: float = _prestige.cost_per_level * (level + 1)
	var can_afford: bool = ClickerGameState.dust >= cost

	level_label.text = "Lv %d" % level
	cost_label.text = "%s Dust" % ClickerGameState.format_number(cost)
	buy_button.disabled = not can_afford


func _on_buy_button_pressed() -> void:
	ClickerGameState.buy_prestige_bonus(_prestige)
	refresh()
