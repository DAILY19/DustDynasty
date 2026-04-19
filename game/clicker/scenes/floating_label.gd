extends Label
## FloatingLabel — rises and fades after showing a coin/damage value.
## Instantiated by DiggingView on each tile break.

@export var rise_distance: float = 80.0
@export var duration: float = 0.9


func show_value(text: String) -> void:
	self.text = text
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.chain().tween_callback(queue_free)
