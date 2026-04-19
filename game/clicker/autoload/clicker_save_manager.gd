extends Node
## ClickerSaveManager — persists clicker game state to user://clicker_save.cfg
## Follows the same ConfigFile pattern as the existing UserConfig singleton.
## user:// maps to IndexedDB on web exports automatically.

const SAVE_PATH: String = "user://clicker_save.cfg"

var _config: ConfigFile = ConfigFile.new()
var _autosave_timer: float = 0.0


func _ready() -> void:
	# Wait for ClickerGameState to finish its _ready before loading
	load_data.call_deferred()


func _process(delta: float) -> void:
	var cfg: ClickerConfig = ClickerDataManager.config
	if not cfg:
		return
	_autosave_timer += delta
	if _autosave_timer >= cfg.autosave_interval_seconds:
		_autosave_timer = 0.0
		save()


func save() -> void:
	var state: ClickerGameState = ClickerGameState

	_config.set_value("Stats", "total_dust_earned", state.total_dust_earned)
	_config.set_value("Stats", "dust", state.dust)
	_config.set_value("Stats", "depth", state.depth)
	_config.set_value("Stats", "prestige_count", state.prestige_count)
	_config.set_value("Stats", "last_online", Time.get_unix_time_from_system())

	_config.set_value("Upgrades", "levels", state.upgrade_levels)
	_config.set_value("Workers", "counts", state.worker_counts)
	_config.set_value("Prestige", "levels", state.prestige_levels)

	_config.save(SAVE_PATH)


func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var err: int = _config.load(SAVE_PATH)
	if err != OK:
		push_warning("ClickerSaveManager: failed to load save (%d)" % err)
		return

	var state: ClickerGameState = ClickerGameState

	state.total_dust_earned  = _config.get_value("Stats", "total_dust_earned", 0.0)
	state.dust               = _config.get_value("Stats", "dust", 0.0)
	state.depth             = _config.get_value("Stats", "depth", 0)
	state.prestige_count    = _config.get_value("Stats", "prestige_count", 0)

	state.upgrade_levels    = _config.get_value("Upgrades", "levels", {})
	state.worker_counts     = _config.get_value("Workers",  "counts", {})
	state.prestige_levels   = _config.get_value("Prestige", "levels", {})

	state.recalculate()

	# Offline earnings
	var last_online: float = _config.get_value("Stats", "last_online", -1.0)
	if last_online > 0:
		var elapsed: float = Time.get_unix_time_from_system() - last_online
		state.award_offline_earnings(elapsed)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	_config = ConfigFile.new()
