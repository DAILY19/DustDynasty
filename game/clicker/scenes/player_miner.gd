extends Node2D
## PlayerMiner — the player's character sprite in the digging view.
## Plays a pickaxe swing animation on each tap, then returns to idle.

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _base_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_position = position
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)


func play_mine() -> void:
	sprite.play("mine")
	# Punch the sprite down a few pixels for impact feel
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:y", _base_position.y + 4.0, 0.05)
	tween.tween_property(self, "position:y", _base_position.y, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)


func _on_animation_finished() -> void:
	if sprite.animation == &"mine":
		sprite.play("idle")
