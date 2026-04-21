@tool
extends TileMap

const TILE_SET_PATH: String = "res://game/clicker/tileset/clicker_tileset.tres"


func _ready():
	load_tileset()


func load_tileset():
	if FileAccess.file_exists(TILE_SET_PATH):
		tile_set= load(TILE_SET_PATH)
	else:
		push_error("Run game once to generate tile set before using Level Editor")


func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		tile_set= null
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		load_tileset()
