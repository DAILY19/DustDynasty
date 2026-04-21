class_name UIStyle
extends RefCounted
## Shared palette, StyleBoxFlat factories, and Theme builder for all HUD panels.
## Call make_theme() once and assign to the root ClickerHUD Control.

# ── Palette ────────────────────────────────────────────────────────────────
const PANEL_BG      := Color(0.08, 0.15, 0.24, 0.97)
const PANEL_BORDER  := Color(0.27, 0.36, 0.56, 1.0)
const HEADER_BG     := Color(0.06, 0.11, 0.20, 1.0)
const HEADER_BORDER := Color(0.27, 0.36, 0.56, 1.0)
const SHEET_BG      := Color(0.07, 0.13, 0.22, 0.98)
const ROW_BG        := Color(0.10, 0.18, 0.28, 1.0)
const ROW_BG_ALT    := Color(0.09, 0.16, 0.25, 1.0)
const ROW_BORDER    := Color(0.20, 0.30, 0.45, 1.0)
const NAV_BG        := Color(0.05, 0.09, 0.16, 1.0)
const NAV_BORDER    := Color(0.27, 0.36, 0.56, 1.0)
const NAV_ACTIVE    := Color(0.18, 0.32, 0.54, 1.0)
const DRAG_HANDLE   := Color(0.35, 0.45, 0.60, 0.8)
const TEXT_WHITE    := Color(0.92, 0.90, 0.85, 1.0)
const TEXT_DIM      := Color(0.55, 0.60, 0.65, 1.0)
const GOLD_ACCENT   := Color(0.90, 0.75, 0.30, 1.0)
const BTN_NORMAL    := Color(0.14, 0.24, 0.38, 1.0)
const BTN_HOVER     := Color(0.20, 0.32, 0.50, 1.0)
const BTN_PRESSED   := Color(0.06, 0.12, 0.22, 1.0)
const BTN_DISABLED  := Color(0.10, 0.16, 0.26, 0.5)

# ── Layout constants (viewport 360×640) ────────────────────────────────────
## Bottom sheet open position: top-left Y when sheet is fully open.
## NavBar top is at y=576; sheet bottom must meet NavBar top.
const SHEET_OPEN_Y  := 160.0   ## 576 - 416
const SHEET_HEIGHT  := 416.0
const SHEET_WIDTH   := 360.0
## Nav bar height at the bottom.
const NAV_HEIGHT    := 64.0
## Drag handle strip height inside the sheet.
const HANDLE_HEIGHT := 20.0
## Header strip height inside the sheet.
const HEADER_HEIGHT := 40.0
## Confirm-dialog (small modal) dimensions.
const DIALOG_WIDTH  := 280.0
const DIALOG_HEIGHT := 160.0

# ── StyleBox factories ─────────────────────────────────────────────────────

static func make_panel_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL_BG
	s.border_color = PANEL_BORDER
	s.set_border_width_all(2)
	s.set_content_margin_all(0)
	return s


static func make_sheet_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = SHEET_BG
	s.border_color = PANEL_BORDER
	s.border_width_top = 2
	s.corner_radius_top_left = 12
	s.corner_radius_top_right = 12
	s.set_content_margin_all(0)
	return s


static func make_header_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = HEADER_BG
	s.border_color = HEADER_BORDER
	s.border_width_bottom = 2
	s.set_content_margin_all(8)
	return s


static func make_nav_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = NAV_BG
	s.border_color = NAV_BORDER
	s.border_width_top = 2
	s.set_content_margin_all(4)
	return s


static func make_nav_active_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = NAV_ACTIVE
	s.border_color = NAV_BORDER
	s.border_width_top = 2
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.set_content_margin_all(4)
	return s


static func make_row_bg() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = ROW_BG
	s.border_color = ROW_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s


static func make_row_bg_alt() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = ROW_BG_ALT
	s.border_color = ROW_BORDER
	s.set_border_width_all(1)
	s.set_content_margin_all(4)
	return s


static func make_button_normal() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_NORMAL
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	s.set_content_margin_all(6)
	return s


static func make_button_hover() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_HOVER
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	s.set_content_margin_all(6)
	return s


static func make_button_pressed() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_PRESSED
	s.border_color = PANEL_BORDER
	s.set_border_width_all(1)
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	s.set_content_margin_all(6)
	return s


static func make_button_disabled() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BTN_DISABLED
	s.border_color = ROW_BORDER
	s.set_border_width_all(1)
	s.corner_radius_top_left = 3
	s.corner_radius_top_right = 3
	s.corner_radius_bottom_left = 3
	s.corner_radius_bottom_right = 3
	s.set_content_margin_all(6)
	return s


# ── Theme builder ──────────────────────────────────────────────────────────
## Returns a fully-configured Theme. Assign to the root ClickerHUD Control so
## all child nodes inherit it without per-node overrides.
static func make_theme(std_font: Font, title_font: Font) -> Theme:
	var t := Theme.new()

	# Button
	t.set_stylebox("normal",   "Button", make_button_normal())
	t.set_stylebox("hover",    "Button", make_button_hover())
	t.set_stylebox("pressed",  "Button", make_button_pressed())
	t.set_stylebox("disabled", "Button", make_button_disabled())
	t.set_stylebox("focus",    "Button", StyleBoxEmpty.new())
	t.set_color("font_color",          "Button", TEXT_WHITE)
	t.set_color("font_hover_color",    "Button", TEXT_WHITE)
	t.set_color("font_pressed_color",  "Button", TEXT_WHITE)
	t.set_color("font_disabled_color", "Button", TEXT_DIM)
	if std_font:
		t.set_font("font", "Button", std_font)
	t.set_font_size("font_size", "Button", 11)

	# Label
	t.set_color("font_color", "Label", TEXT_WHITE)
	if std_font:
		t.set_font("font", "Label", std_font)
	t.set_font_size("font_size", "Label", 11)

	# PanelContainer
	t.set_stylebox("panel", "PanelContainer", make_panel_bg())

	# ScrollContainer — transparent background
	var scroll_empty := StyleBoxEmpty.new()
	t.set_stylebox("panel", "ScrollContainer", scroll_empty)

	# HSlider (Settings volume)
	t.set_color("font_color", "HSlider", GOLD_ACCENT)

	return t
