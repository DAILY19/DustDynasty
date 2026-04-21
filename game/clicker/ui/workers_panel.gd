extends PanelContainer
## WorkersPanel — lists all WorkerDefinitions from the registry.

const WORKER_ROW_SCENE: String = "res://game/clicker/ui/worker_row.tscn"

@onready var scroll_content: VBoxContainer = $VBoxContainer/ScrollContainer/ScrollContent
@onready var close_button: Button = $VBoxContainer/Header/CloseButton

var _row_scene: PackedScene
var _rows: Array = []


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
	_row_scene = load(WORKER_ROW_SCENE)
	_build_rows()
	close_button.pressed.connect(_on_close_button_pressed)
	ClickerGameState.dust_changed.connect(_refresh_rows)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	visible = false


func _build_rows() -> void:
	Utils.free_children(scroll_content)
	_rows.clear()
	for worker in ClickerDataManager.workers:
		var row: Node = _row_scene.instantiate()
		scroll_content.add_child(row)
		row.setup(worker)
		_rows.append(row)


func _refresh_rows(_ignored: Variant = null) -> void:
	for row in _rows:
		row.refresh()


func _on_worker_hired(_worker: WorkerDefinition, _count: int) -> void:
	_refresh_rows()


func _on_close_button_pressed() -> void:
	visible = false
