extends PanelContainer
## WorkersPanel — lists all WorkerDefinitions from the registry.

const WORKER_ROW_SCENE: String = "res://game/clicker/ui/worker_row.tscn"

@onready var scroll_content: VBoxContainer = $ScrollContainer/ScrollContent
@onready var close_button: Button = $CloseButton

var _row_scene: PackedScene
var _rows: Array = []


func _ready() -> void:
	_row_scene = load(WORKER_ROW_SCENE)
	_build_rows()
	close_button.pressed.connect(_on_close_button_pressed)
	ClickerGameState.coins_changed.connect(_refresh_rows)
	ClickerGameState.worker_hired.connect(_on_worker_hired)
	ClickerGameState.depth_changed.connect(_refresh_rows)
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
