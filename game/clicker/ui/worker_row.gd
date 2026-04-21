extends PanelContainer
## WorkerRow — one row inside WorkersPanel for a single WorkerDefinition.

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var count_label: Label = %CountLabel
@onready var dps_label: Label = %DpsLabel
@onready var cost_label: Label = %CostLabel
@onready var hire_button: Button = %HireButton
@onready var description_label: Label = %DescriptionLabel

var _worker: WorkerDefinition


func _ready() -> void:
	add_theme_stylebox_override("panel", UIStyle.make_row_bg())
	name_label.add_theme_color_override("font_color", UIStyle.TEXT_WHITE)
	description_label.add_theme_color_override("font_color", UIStyle.TEXT_DIM)
	dps_label.add_theme_color_override("font_color", UIStyle.TEXT_DIM)
	count_label.add_theme_color_override("font_color", UIStyle.TEXT_DIM)
	cost_label.add_theme_color_override("font_color", UIStyle.GOLD_ACCENT)
	hire_button.add_theme_stylebox_override("normal", UIStyle.make_button_normal())
	hire_button.add_theme_stylebox_override("hover", UIStyle.make_button_hover())
	hire_button.add_theme_stylebox_override("pressed", UIStyle.make_button_pressed())
	hire_button.pressed.connect(_on_hire_button_pressed)


func setup(worker: WorkerDefinition) -> void:
	_worker = worker
	name_label.text = worker.get_display_name()
	description_label.text = worker.description
	if worker.icon:
		icon_texture.texture = worker.icon
	refresh()


func refresh() -> void:
	if _worker == null:
		return
	var count: int = ClickerGameState.worker_counts.get(_worker.name, 0)
	var cost: float = ClickerGameState.get_worker_cost(_worker)
	var can_afford: bool = ClickerGameState.dust >= cost

	count_label.text = "x%d" % count
	dps_label.text = "%s/s" % ClickerGameState.format_number(_worker.dig_power * _worker.dig_speed * count)
	cost_label.text = ClickerGameState.format_number(cost)
	hire_button.disabled = not can_afford
	hire_button.text = "Hire"
	modulate.a = 1.0


func _on_hire_button_pressed() -> void:
	ClickerGameState.hire_worker(_worker)
