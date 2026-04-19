extends Node2D
## PlayerMiner — the player's character in the digging view.
## Drives a simple state machine: IDLE → DIGGING → MOVING → IDLE.
## Emits hit_frame when the pickaxe connects; DiggingView handles game logic.
## Emits move_finished when a tween-based move completes.

signal hit_frame
signal move_finished

enum State { IDLE, DIGGING, MOVING, RESETTING }

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var state: int = State.IDLE


func _ready() -> void:
	sprite.play("idle")
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)


## Called by DiggingView to start the pickaxe swing.
func start_digging() -> void:
	if state != State.IDLE:
		push_warning("PlayerMiner: start_digging called in non-IDLE state (%d) — ignored" % state)
		return
	state = State.DIGGING
	sprite.play("mine")


## Called by DiggingView after the hit frame breaks a block.
## Tweens the player to target_pos over duration seconds.
func move_to(target_pos: Vector2, duration: float) -> void:
	state = State.MOVING
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_pos, duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_on_tween_finished)


## Called by DiggingView to snap/tween the player back to the grid start.
func reset_to(target_pos: Vector2, duration: float) -> void:
	state = State.RESETTING
	sprite.play("idle")
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_pos, duration) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(_on_reset_finished)


## Force back to idle (e.g. when a hit doesn't break the block).
func finish_digging() -> void:
	state = State.IDLE
	if sprite.animation != &"idle":
		sprite.play("idle")


func _on_frame_changed() -> void:
	if state == State.DIGGING and sprite.animation == &"mine" and sprite.frame == 2:
		hit_frame.emit()


func _on_animation_finished() -> void:
	if sprite.animation == &"mine":
		sprite.play("idle")
		# If still in DIGGING state after animation ends, the block survived.
		if state == State.DIGGING:
			state = State.IDLE


func _on_tween_finished() -> void:
	state = State.IDLE
	move_finished.emit()


func _on_reset_finished() -> void:
	state = State.IDLE
	move_finished.emit()
