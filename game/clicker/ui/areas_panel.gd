extends PanelContainer
## AreasPanel — lists all DiggingViewVariants from the registry.
## Player can view, unlock, and switch between mining areas.

const AREA_CARD_SCENE: String = "res://game/clicker/ui/area_card.tscn"

@onready var scroll_content: VBoxContainer = $VBoxContainer/ScrollContainer/ScrollContent
@onready var close_button: Button = $VBoxContainer/Header/CloseButton

var _card_scene: PackedScene
var _cards: Array = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = UIStyle.MAIN_PANEL_POS
	size = UIStyle.MAIN_PANEL_SIZE
	add_theme_stylebox_override("panel", UIStyle.make_panel_bg())
	var title_lbl: Label = $VBoxContainer/Header/TitleLabel
	title_lbl.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	close_button.add_theme_stylebox_override("normal", UIStyle.make_button_normal())
	close_button.add_theme_stylebox_override("hover", UIStyle.make_button_hover())
	close_button.add_theme_stylebox_override("pressed", UIStyle.make_button_pressed())
	close_button.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	_card_scene = load(AREA_CARD_SCENE)
	_build_cards()
	close_button.pressed.connect(_on_close_button_pressed)
	ClickerGameState.area_unlocked.connect(_refresh_cards)
	visible = false


func _build_cards() -> void:
	Utils.free_children(scroll_content)
	_cards.clear()
	for area in ClickerGameState.all_areas:
		var card: Node = _card_scene.instantiate()
		scroll_content.add_child(card)
		card.setup(area)
		_cards.append(card)


func _refresh_cards(_ignored: Variant = null) -> void:
	for card in _cards:
		card.refresh()


func _on_close_button_pressed() -> void:
	visible = false
