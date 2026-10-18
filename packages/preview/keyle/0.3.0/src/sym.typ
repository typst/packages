// https://support.apple.com/en-hk/guide/mac-help/cpmh0011/mac

#let mac-key = (
  command: "⌘",
  shift: "⇧",
  option: "⌥",
  control: "⌃",
  "return": "↩",
  delete: "⌫",
  forward-delete: "⌦",
  escape: "⎋",
  left: "←",
  right: "→",
  up: "↑",
  down: "↓",
  pageup: "⇞",
  pagedown: "⇟",
  home: "↖",
  end: "↘",
  tab-right: "⇥",
  tab-left: "⇤",
)

#let biolinum-key = (
  Strg: "Strg",
  Alt: "Alt",
  Ctrl: "Ctrl",
  Shift: "Shift",
  Tab: "Tab",
  Enter: "Enter",
  Capslock: "Capslock",
  Home: "Home",
  Del: "Del",
  Ins: "Ins",
  End: "End",
  Space: "\u{E18C}",
  Esc: "Esc",
  PageUp: "\u{E19A}",
  PageDown: "\u{E19B}",
  Back: "Back",
  Pad_0: "\u{E1A0}",
  Pad_1: "\u{E1A1}",
  Pad_2: "\u{E1A2}",
  Pad_3: "\u{E1A3}",
  Pad_4: "\u{E1A4}",
  Pad_5: "\u{E1A5}",
  Pad_6: "\u{E1A6}",
  Pad_7: "\u{E1A7}",
  Pad_8: "\u{E1A8}",
  Pad_9: "\u{E1A9}",
  Pad_Div: "\u{E1AA}",
  Pad_Add: "\u{E1AB}",
  Pad_Sub: "\u{E1AC}",
  Pad_Mul: "\u{E1AD}",
  Pad_Enter: "\u{E1AE}",
  Mac_Cmd: "\u{2318}",
  Mac_Opt: "\u{2325}",
  Mac_FDel: "\u{2326}",
  Mac_Del: "\u{232B}",
  GNU: "GNU",
  Win: "\u{E168}",
  Tux: "Tux",
  delim_plus: "\u{E1B0}",
  delim_minus: "\u{E1B1}",
)

// Inline SVG glyphs for non-textual keys. Because a theme renders whatever
// `sym` content it is handed, these are simply another kind of symbol on the
// `sym` axis -- pass them straight to a generated `kbd`, e.g. `kbd(svg-key.up)`.
// Paths use a 24x24 viewBox (Material Symbols geometry).
#let _icon-paths = (
  up: "M4 12l1.41 1.41L11 7.83V20h2V7.83l5.58 5.59L20 12l-8-8-8 8z",
  down: "M20 12l-1.41-1.41L13 16.17V4h-2v12.17l-5.58-5.59L4 12l8 8 8-8z",
  left: "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
  right: "M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z",
  enter: "M19 7v4H5.83l3.58-3.59L8 6l-6 6 6 6 1.41-1.41L5.83 13H21V7z",
  backspace: "M22 3H7c-.69 0-1.23.35-1.59.88L0 12l5.41 8.11c.36.53.9.89 1.59.89h15c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-3 12.59L17.59 17 14 13.41 10.41 17 9 15.59 12.59 12 9 8.41 10.41 7 14 10.59 17.59 7 19 8.41 15.41 12 19 15.59z",
  tab: "M11.59 7.41L15.17 11H1v2h14.17l-3.59 3.59L13 18l6-6-6-6-1.41 1.41zM20 6v12h2V6h-2z",
  // Bootstrap Icons "windows" (16x16 viewBox, see `_icon-viewbox`).
  win: "M6.555 1.375 0 2.237v5.45h6.555V1.375zM0 13.795l6.555.933V8.313H0v5.482zm7.278-5.4.026 6.378L16 16V8.395H7.278zM16 0 7.33 1.244v6.414H16V0z",
)

// Per-glyph SVG viewBox; glyphs default to the 24x24 Material Symbols grid.
#let _icon-viewbox = (
  win: "0 0 16 16",
)

/// Render a non-textual key glyph as inline SVG content.
///
/// Available names: #(`up`, `down`, `left`, `right`, `enter`, `backspace`, `tab`, `win`).
/// -> content
#let svg-icon(
  /// Glyph name. -> str
  name,
  /// Glyph fill color. -> color
  fill: rgb("#333333"),
  /// Glyph height. -> length
  size: 0.72em,
) = box(
  baseline: 0.0em,
  height: size,
  image(
    bytes(
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='"
        + _icon-viewbox.at(name, default: "0 0 24 24")
        + "'><path d='"
        + _icon-paths.at(name)
        + "' fill='" + fill.to-hex() + "'/></svg>",
    ),
    format: "svg",
  ),
)

/// Convenience dictionary of default-styled SVG key glyphs (`svg-key.up`, ...).
#let svg-key = _icon-paths.keys().fold((:), (acc, k) => {
  acc.insert(k, svg-icon(k))
  acc
})