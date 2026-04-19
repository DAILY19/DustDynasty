extends HBoxContainer
## WorkerRow — one row inside WorkersPanel for a single WorkerDefinition.

@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var count_label: Label = %CountLabel
@onready var dps_label: Label = %DpsLabel
@onready var cost_label: Label = %CostLabel
@onready var hire_button: Button = %HireButton
@onready var description_label: Label = %DescriptionLabel

var _worker: WorkerDefinition


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
	var can_afford: bool = ClickerGameState.coins >= cost
	var unlocked: bool = ClickerGameState.depth >= _worker.unlock_depth

	count_label.text = "x%d" % count
	dps_label.text = "%s/s" % ClickerGameState.format_number(_worker.dig_power * _worker.dig_speed * count)
	cost_label.text = ClickerGameState.format_number(cost)
	hire_button.disabled = not can_afford or not unlocked
	hire_button.text = "LOCKED" if not unlocked else "Hire"
	modulate.a = 0.5 if not unlocked else 1.0


func _on_hire_button_pressed() -> void:
	ClickerGameState.hire_worker(_worker)
