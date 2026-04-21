extends Control
## AreasPanel — lists all DiggingViewVariants from the registry.
## Player can view, unlock, and switch between mining areas.
## Attached to AreasContent inside AreasSheet's ContentSlot.

const AREA_CARD_SCENE: String = "res://game/clicker/ui/area_card.tscn"

@onready var scroll_content: VBoxContainer = $ScrollContainer/ScrollContent

var _card_scene: PackedScene
var _cards: Array = []


func _ready() -> void:
	_card_scene = load(AREA_CARD_SCENE)
	_build_cards()
	ClickerGameState.area_unlocked.connect(_refresh_cards)


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



