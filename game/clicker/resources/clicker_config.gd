class_name ClickerConfig
extends Resource

## Central config resource — all tuning numbers live here.
## Edit the .tres file in the editor; no code changes needed.

@export_category("Viewport")
@export var viewport_width: int = 720
@export var viewport_height: int = 1280

@export_category("Digging Grid")
@export var grid_columns: int = 10
@export var grid_rows: int = 15
@export var tile_size: int = 32

@export_category("Mining Traversal")
@export var blocks_per_click: int = 1
@export var player_move_duration: float = 0.15
@export var block_break_delay: float = 0.08
@export var grid_reset_pause: float = 0.4

@export_category("Tap")
@export var base_tap_power: float = 1.0
@export var base_tap_cooldown: float = 0.1

@export_category("Prestige")
## prestige_currency = sqrt(total_coins / prestige_cost_divisor)
@export var prestige_cost_divisor: float = 1_000_000.0
@export_category("Offline")
## Maximum hours of offline earnings awarded on return.
@export var offline_earnings_cap_hours: float = 4.0

@export_category("Autosave")
@export var autosave_interval_seconds: float = 30.0

@export_category("Big Numbers")
## Suffixes for formatting large numbers (index 0 = thousands).
@export var number_suffixes: PackedStringArray = ["K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No"]
