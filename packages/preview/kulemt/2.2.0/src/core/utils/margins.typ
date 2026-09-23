// Page geometry.
//
// This file was a two-line "TODO after everything else works" in 0.1.0, and
// lib.typ hard-coded `margin: (left: 28mm, right: 28mm, bottom: 45mm, top:
// 37mm)`. The vertical values were right; the horizontal ones were not. 28 mm
// is kulemt's INNER margin -- the outer one is 42 mm -- so the text block came
// out 154 mm wide instead of 140 mm.
//
// From kulemt-layout.dtx:
//
//   10pt: \textwidth 13cm  \textheight 20cm
//   11pt: \textwidth 14cm  \textheight 21.5cm
//
//   \foremargin  = 0.6 * (\paperwidth - \textwidth - bind)
//   \spinemargin = 0.4 * (\paperwidth - \textwidth - bind) + bind
//
// with 0.5/0.5 instead of 0.4/0.6 when equal margins are asked for
// (the `twosidelrequal` class option).
//
//   \setulmargins{*}{*}{1.2}  ->  lower margin = 1.2 * upper margin
//
// On A4 at 11pt with no binding loss that gives 28 mm / 42 mm horizontally and
// 37.3 mm / 44.7 mm vertically.

#let PAPER-WIDTH = 210mm
#let PAPER-HEIGHT = 297mm

/// Text block dimensions for a body font size.
/// kulemt only defines 10pt and 11pt.
/// -> dictionary
#let body-size(font-size) = {
  if font-size == 10pt {
    (width: 130mm, height: 200mm)
  } else if font-size == 11pt {
    (width: 140mm, height: 215mm)
  } else {
    panic(
      "kulemt only defines a page layout for 10pt and 11pt body text, got "
        + repr(font-size)
        + ". Pick one of those two.",
    )
  }
}

/// Margins for the body of the thesis.
///
/// - font-size (length): 10pt or 11pt.
/// - bind (length): paper lost to the binding (kulemt's `bind` option).
/// - twoside (bool): mirror the margins on facing pages.
/// - lr-equal (bool): make the visible margins equal (`twosidelrequal`).
/// -> dictionary
#let thesis-margins(
  font-size: 11pt,
  bind: 0mm,
  twoside: false,
  lr-equal: false,
) = {
  let body = body-size(font-size)

  let free-h = PAPER-WIDTH - body.width - bind
  let spine-factor = if lr-equal { 0.5 } else { 0.4 }
  let fore-factor = if lr-equal { 0.5 } else { 0.6 }
  let spine = free-h * spine-factor + bind
  let fore = free-h * fore-factor

  // lower = 1.2 * upper, and upper + lower = paperheight - textheight
  let free-v = PAPER-HEIGHT - body.height
  let upper = free-v / 2.2
  let lower = free-v - upper

  if twoside {
    (inside: spine, outside: fore, top: upper, bottom: lower)
  } else {
    (left: spine, right: fore, top: upper, bottom: lower)
  }
}
