class_name UIStyle
extends RefCounted
## Shared navy-blue palette and StyleBoxFlat factory — used by all HUD panels and rows.

# Navy palette matching the pixelart UI kit
const PANEL_BG := Color(0.08, 0.15, 0.24, 0.97)
const PANEL_BORDER := Color(0.27, 0.36, 0.56, 1.0)
const ROW_BG := Color(0.10, 0.18, 0.28, 1.0)
const ROW_BORDER := Color(0.20, 0.30, 0.45, 1.0)
const TEXT_WHITE := Color(0.92, 0.90, 0.85, 1.0)
const TEXT_DIM := Color(0.55, 0.60, 0.65, 1.0)
const GOLD_ACCENT := Color(0.90, 0.75, 0.30, 1.0)
const BTN_NORMAL := Color(0.14, 0.24, 0.38, 1.0)
const BTN_HOVER := Color(0.20, 0.32, 0.50, 1.0)
const BTN_PRESSED := Color(0.06, 0.12, 0.22, 1.0)

## Fixed positions for panels — set in code to prevent editor-saved offsets from drifting.
## Viewport is always 360x640 (canvas_items stretch mode handles device scaling).
const MAIN_PANEL_POS := Vector2(18.0, 56.0)   ## Shop / Workers / Prestige / Areas
const MAIN_PANEL_SIZE := Vector2(324.0, 536.0)
const SMALL_PANEL_POS := Vector2(36.0, 144.0)  ## Settings / Offline Earnings
const SMALL_PANEL_SIZE := Vector2(288.0, 320.0)


static func make_panel_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_BG
	s.border_color = PANEL_BORDER
	s.set_border_width_all(2)
	s.set_content_margin_all(0)
	return s


static func make_row_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = ROW_BG
	s.border_color = ROW_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s


static func make_button_normal() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_NORMAL
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s


static func make_button_hover() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_HOVER
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s


static func make_button_pressed() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_PRESSED
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s
