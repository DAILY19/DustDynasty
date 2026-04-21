extends Node
## ClickerSoundPlayer — audio manager for the clicker game.
## Preloads all mining and UI sound files on startup; plays via a pool of
## AudioStreamPlayers. Fully isolated from the base game DataManager/SoundPlayer.
##
## Called from digging_view.gd and UI panels.
## Volume/mute is handled globally via AudioServer (bus 0 = Master).

const MINING_SOUNDS: Array[String] = [
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 1.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 2.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 3.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 4.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 5.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 6.mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 7.mp3",
]

const GEMSTONE_SOUNDS: Array[String] = [
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 1 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 2 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 3 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 4 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 5 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 6 (with Gemstone).mp3",
	"res://assets/sfx/Mining sfx/MP3/Mineral Mining - 7 (with Gemstone).mp3",
]

const UI_CLICK_SOUNDS: Array[String] = [
	"res://assets/sfx/UI sfx/OGG/UI_Button_Click_1.ogg",
	"res://assets/sfx/UI sfx/OGG/UI_Button_Click_2.ogg",
	"res://assets/sfx/UI sfx/OGG/UI_Button_Click_3.ogg",
	"res://assets/sfx/UI sfx/OGG/UI_Button_Click_4.ogg",
]

## Minimum interval between tap sounds to prevent audio spam on rapid tapping.
const TAP_SOUND_INTERVAL: float = 0.12

var _tap_sound_timer: float = 0.0
var _cached: Dictionary = {}  # path -> AudioStream

@onready var _pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	_pool.assign(get_children())
	_preload_sounds()


func _process(delta: float) -> void:
	if _tap_sound_timer > 0.0:
		_tap_sound_timer -= delta


## Play a random mining tap sound (rate-limited to avoid spam).
func play_tap() -> void:
	if _tap_sound_timer > 0.0:
		return
	_tap_sound_timer = TAP_SOUND_INTERVAL
	_play_from(MINING_SOUNDS, -12.0)


## Play a tile-break sound. Pass is_valuable=true for ores with high value
## to play the gemstone variant.
func play_break(is_valuable: bool = false) -> void:
	var sounds: Array[String] = GEMSTONE_SOUNDS if is_valuable else MINING_SOUNDS
	_play_from(sounds, -8.0)


## Play a UI button click sound.
func play_ui_click() -> void:
	_play_from(UI_CLICK_SOUNDS, -6.0)


## Play an arbitrary AudioStream (used for per-block sound overrides).
func play_stream(stream: AudioStream, volume_db: float = -10.0) -> void:
	var player: AudioStreamPlayer = _get_free_player()
	if player == null or stream == null:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func _preload_sounds() -> void:
	var all: Array[String] = []
	all.append_array(MINING_SOUNDS)
	all.append_array(GEMSTONE_SOUNDS)
	all.append_array(UI_CLICK_SOUNDS)
	for path in all:
		var stream: AudioStream = load(path)
		if stream:
			_cached[path] = stream


func _play_from(paths: Array[String], volume_db: float) -> void:
	var player: AudioStreamPlayer = _get_free_player()
	if player == null:
		return
	var path: String = paths[randi() % paths.size()]
	var stream: AudioStream = _cached.get(path)
	if stream == null:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.play()


func _get_free_player() -> AudioStreamPlayer:
	for p: AudioStreamPlayer in _pool:
		if not p.playing:
			return p
	return null
