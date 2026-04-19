extends Node
## ClickerGameState — runtime state for the clicker game.
## All formulas reference ClickerDataManager registry data.
## Emit signals whenever state changes; UI nodes connect to these.

signal coins_changed(new_amount: float)  # kept for compat — connects to dust_changed
signal dust_changed(new_amount: float)
signal depth_changed(new_depth: int)
signal upgrade_purchased(upgrade: UpgradeDefinition, new_level: int)
signal worker_hired(worker: WorkerDefinition, new_count: int)
signal prestige_activated(new_prestige_count: int)
signal offline_earnings_awarded(amount: float, seconds_elapsed: float)

# ── Persistent state (saved/loaded by ClickerSaveManager) ──────────────────
var dust: float = 0.0
var total_dust_earned: float = 0.0
var depth: int = 0
var prestige_count: int = 0
var upgrade_levels: Dictionary = {}   # upgrade name -> int level
var worker_counts: Dictionary = {}    # worker name -> int count
var prestige_levels: Dictionary = {}  # prestige bonus name -> int level

# ── Derived / cached values (recalculated via recalculate()) ───────────────
var tap_power: float = 0.0
var tap_cooldown: float = 0.0
var crit_chance: float = 0.0
var crit_multiplier: float = 1.0
var ore_value_bonus: float = 1.0
var offline_rate: float = 1.0
var worker_total_dps: float = 0.0     # dust per second from all workers
var prestige_multiplier: float = 1.0

# ── Tap cooldown tracking ──────────────────────────────────────────────────
var _tap_ready: bool = true
var _tap_timer: float = 0.0


func _ready() -> void:
	recalculate()


func _process(delta: float) -> void:
	# Tap cooldown
	if not _tap_ready:
		_tap_timer -= delta
		if _tap_timer <= 0.0:
			_tap_ready = true

	# Worker passive income
	if worker_total_dps > 0.0:
		add_dust(worker_total_dps * delta)


## Called after any purchase or prestige to refresh derived values.
func recalculate() -> void:
	var cfg: ClickerConfig = ClickerDataManager.config

	tap_power = cfg.base_tap_power
	tap_cooldown = cfg.base_tap_cooldown
	crit_chance = 0.0
	crit_multiplier = 1.0
	ore_value_bonus = 1.0
	offline_rate = 1.0

	# Apply upgrades
	for upgrade in ClickerDataManager.upgrades:
		var level: int = upgrade_levels.get(upgrade.name, 0)
		if level == 0:
			continue
		var effect: float = upgrade.effect_per_level * level
		match upgrade.type:
			UpgradeDefinition.UpgradeType.TAP_POWER:
				tap_power += effect
			UpgradeDefinition.UpgradeType.TAP_SPEED:
				tap_cooldown = maxf(0.05, tap_cooldown - effect)
			UpgradeDefinition.UpgradeType.CRIT_CHANCE:
				crit_chance = minf(0.95, crit_chance + effect)
			UpgradeDefinition.UpgradeType.CRIT_MULTIPLIER:
				crit_multiplier += effect
			UpgradeDefinition.UpgradeType.ORE_VALUE_BONUS:
				ore_value_bonus += effect
			UpgradeDefinition.UpgradeType.OFFLINE_RATE:
				offline_rate += effect

	# Apply prestige bonuses
	prestige_multiplier = 1.0
	for prestige in ClickerDataManager.prestige_bonuses:
		var level: int = prestige_levels.get(prestige.name, 0)
		if level == 0:
			continue
		var bonus: float = pow(prestige.base_multiplier, level)
		match prestige.type:
			PrestigeDefinition.BonusType.EARNINGS_MULTIPLIER:
				prestige_multiplier *= bonus
			PrestigeDefinition.BonusType.WORKER_EFFICIENCY:
				pass  # applied in worker DPS calc below
			PrestigeDefinition.BonusType.TAP_POWER_BONUS:
				tap_power *= bonus

	# Apply prestige multiplier to tap power
	tap_power *= prestige_multiplier

	# Calculate worker DPS
	worker_total_dps = 0.0
	for worker in ClickerDataManager.workers:
		var count: int = worker_counts.get(worker.name, 0)
		if count == 0:
			continue
		var efficiency: float = _get_prestige_worker_efficiency()
		worker_total_dps += worker.dig_power * worker.dig_speed * count * efficiency * prestige_multiplier


func _get_prestige_worker_efficiency() -> float:
	var efficiency: float = 1.0
	for prestige in ClickerDataManager.prestige_bonuses:
		if prestige.type == PrestigeDefinition.BonusType.WORKER_EFFICIENCY:
			var level: int = prestige_levels.get(prestige.name, 0)
			if level > 0:
				efficiency *= pow(prestige.base_multiplier, level)
	return efficiency


## Add dust, applying ore value bonus and prestige multiplier.
func add_dust(amount: float) -> void:
	var final_amount: float = amount * ore_value_bonus * prestige_multiplier
	dust += final_amount
	total_dust_earned += final_amount
	dust_changed.emit(dust)
	coins_changed.emit(dust)  # back-compat for panels still connected to coins_changed


## Add coins is an alias kept for milestone reward compatibility.
func add_coins(amount: float) -> void:
	add_dust(amount)


## Attempt a tap. Returns dust earned (0 if on cooldown).
func try_tap(ore: OreDefinition) -> float:
	if not _tap_ready:
		return 0.0
	_tap_ready = false
	_tap_timer = tap_cooldown

	var earned: float = ore.value * tap_power
	if randf() < crit_chance:
		earned *= crit_multiplier
	add_dust(earned)
	return earned


## Mine an ore block directly. No cooldown check.
## Used by the traversal mining loop for sequential block breaks.
func mine_ore(ore: OreDefinition) -> float:
	var earned: float = ore.value * tap_power
	if randf() < crit_chance:
		earned *= crit_multiplier
	add_dust(earned)
	return earned


## Buy one level of an upgrade. Returns true if successful.
func buy_upgrade(upgrade: UpgradeDefinition) -> bool:
	var current_level: int = upgrade_levels.get(upgrade.name, 0)
	if current_level >= upgrade.max_level:
		return false
	var cost: float = get_upgrade_cost(upgrade)
	if dust < cost:
		return false
	dust -= cost
	dust_changed.emit(dust)
	coins_changed.emit(dust)
	upgrade_levels[upgrade.name] = current_level + 1
	recalculate()
	upgrade_purchased.emit(upgrade, current_level + 1)
	ClickerSaveManager.save()
	return true


func get_upgrade_cost(upgrade: UpgradeDefinition) -> float:
	var level: int = upgrade_levels.get(upgrade.name, 0)
	return upgrade.base_cost * pow(upgrade.cost_scaling, level)


## Hire one worker. Returns true if successful.
func hire_worker(worker: WorkerDefinition) -> bool:
	if depth < worker.unlock_depth:
		return false
	var cost: float = get_worker_cost(worker)
	if dust < cost:
		return false
	dust -= cost
	dust_changed.emit(dust)
	coins_changed.emit(dust)
	worker_counts[worker.name] = worker_counts.get(worker.name, 0) + 1
	recalculate()
	worker_hired.emit(worker, worker_counts[worker.name])
	ClickerSaveManager.save()
	return true


func get_worker_cost(worker: WorkerDefinition) -> float:
	var count: int = worker_counts.get(worker.name, 0)
	return worker.base_cost * pow(worker.cost_scaling, count)


## Spend prestige currency on a prestige bonus.
func buy_prestige_bonus(prestige: PrestigeDefinition) -> bool:
	var level: int = prestige_levels.get(prestige.name, 0)
	var cost: float = prestige.cost_per_level * (level + 1)
	if dust < cost:
		return false
	dust -= cost
	dust_changed.emit(dust)
	prestige_levels[prestige.name] = level + 1
	recalculate()
	ClickerSaveManager.save()
	return true


## Prestige: reset progress, award dust bonus, keep prestige_levels.
func prestige() -> void:
	var cfg: ClickerConfig = ClickerDataManager.config
	var earned_dust: float = sqrt(total_dust_earned / cfg.prestige_cost_divisor)
	dust += earned_dust
	dust_changed.emit(dust)

	prestige_count += 1
	total_dust_earned = 0.0
	upgrade_levels.clear()
	worker_counts.clear()
	set_depth(cfg.prestige_reset_depth)
	recalculate()

	prestige_activated.emit(prestige_count)
	ClickerSaveManager.save()


## Advance depth by one.
func advance_depth() -> void:
	set_depth(depth + 1)


func set_depth(new_depth: int) -> void:
	depth = new_depth
	depth_changed.emit(depth)


## Award offline earnings. Called by ClickerSaveManager on load.
func award_offline_earnings(seconds_elapsed: float) -> void:
	var cfg: ClickerConfig = ClickerDataManager.config
	var capped_seconds: float = minf(seconds_elapsed, cfg.offline_earnings_cap_hours * 3600.0)
	var earned: float = worker_total_dps * capped_seconds * offline_rate
	if earned > 0.0:
		add_coins(earned)
		offline_earnings_awarded.emit(earned, capped_seconds)


## Format a large number as a readable string (1.5K, 2.3M, etc.)
func format_number(value: float) -> String:
	if value < 1000.0:
		return str(int(value))
	var cfg: ClickerConfig = ClickerDataManager.config
	var suffixes: PackedStringArray = cfg.number_suffixes
	var tier: int = 0
	var v: float = value
	while v >= 1000.0 and tier < suffixes.size() - 1:
		v /= 1000.0
		tier += 1
	return "%.2f%s" % [v, suffixes[tier - 1]]


## Returns prestige currency that would be earned right now.
func get_pending_dust() -> float:
	var cfg: ClickerConfig = ClickerDataManager.config
	return sqrt(total_dust_earned / cfg.prestige_cost_divisor)
