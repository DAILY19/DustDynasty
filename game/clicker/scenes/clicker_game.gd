extends Node2D
## ClickerGame — root scene for the Dust Dynasty clicker game.
## Switches between SurfaceView and DiggingView.
## All child nodes are in the .tscn; this script only wires logic.

@onready var surface_view: Node2D = $SurfaceView
@onready var digging_view: Node2D = $DiggingView
@onready var clicker_hud: CanvasLayer = $ClickerHUD
@onready var offline_earnings_panel: PanelContainer = $ClickerHUD/OfflineEarningsPanel
@onready var depth_milestone_container: Node2D = $DepthMilestoneContainer


func _ready() -> void:
	ClickerGameState.depth_changed.connect(_on_depth_changed)
	_show_digging()


func _show_surface() -> void:
	surface_view.show()
	digging_view.hide()


func _show_digging() -> void:
	surface_view.hide()
	digging_view.show()


func _show_milestone(milestone: DepthMilestone) -> void:
	if milestone.milestone_scene == null:
		return
	# Clear any previous milestone
	Utils.free_children(depth_milestone_container)
	var instance: Node = milestone.milestone_scene.instantiate()
	depth_milestone_container.add_child(instance)
	digging_view.hide()
	surface_view.hide()
	depth_milestone_container.show()

	# When milestone is cleared, resume digging
	if instance.has_signal("milestone_cleared"):
		instance.milestone_cleared.connect(_on_milestone_cleared.bind(milestone))


func _on_milestone_cleared(milestone: DepthMilestone) -> void:
	ClickerGameState.add_coins(milestone.reward_coins)
	ClickerGameState.dust += milestone.reward_prestige_currency
	Utils.free_children(depth_milestone_container)
	_show_digging()


func _on_depth_changed(new_depth: int) -> void:
	var milestone: DepthMilestone = ClickerDataManager.get_milestone(new_depth)
	if milestone:
		_show_milestone(milestone)
