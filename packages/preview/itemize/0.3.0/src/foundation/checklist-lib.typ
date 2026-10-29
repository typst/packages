#import "../util/parse-args.typ": *
#import "../lib/checklist.typ": *

#let get-marker-text(body) = {
  // content
  if body == [ ] {
    " "
  } else if body == ["] {
    "\""
  } else if body == ['] {
    "'"
  } else if body.has("text") {
    body.text
  } else {
    none
  }
}

#let parse-checklist(
  rel-level,
  curr-level,
  checklist,
  setting,
  character-symbol,
) = {
  let curr-checklist = get-depth-value(checklist, rel-level)
  assert(type(curr-checklist) == bool, message: "`checklist` must be a bool; " + "\nbut found: " + repr(curr-checklist))

  let fill-check
  let radius-check
  let solid-check
  let symbol-map = (:)
  let format-map = (:)
  let symbol-list
  let enable-character = false
  let checklist-label-baseline = none
  if curr-checklist {
    checklist-label-baseline = get-depth-value(setting.label-baseline, curr-level)
    if checklist-label-baseline != auto {
      assert(
        checklist-label-baseline in ("center", "top", "bottom", "baseline", auto),
        message: "The `baseline` of checklist should be: \"center\", \"top\", \"bottom\", \"baseline\", or `auto`."
          + "\nBut found: "
          + repr(checklist-label-baseline)
          + ".",
      )
    }

    fill-check = get-depth-value(setting.checklist-fill, curr-level)
    assert(
      type(fill-check) == color or fill-check == auto or fill-check == none,
      message: "`fill` must be a color, `none` or `auto`; " + "\nbut found: " + repr(fill-check),
    )

    radius-check = get-depth-value(setting.checklist-radius, curr-level)
    assert(
      type(radius-check) in length-type or radius-check == auto or type(radius-check) == dictionary,
      message: "`radius` must be a relative, `auto` or a dictionary; " + "\nbut found: " + repr(radius-check),
    )

    solid-check = get-depth-value(setting.checklist-solid, curr-level)
    assert(
      type(solid-check) == color or solid-check == none,
      message: "`solid` must be a color or `none`; " + "\nbut found: " + repr(solid-check),
    )

    let checklist-map = get-depth-value(setting.checklist-map, curr-level)
    let _temp-symbol-map
    if type(checklist-map) == function {
      _temp-symbol-map = checklist-map(
        (fill: fill-check, radius: radius-check, solid: solid-check),
      )
    } else if type(checklist-map) == dictionary {
      _temp-symbol-map = checklist-map
    } else {
      panic("`symbol-map` must be a dictionary or a function; " + "\nbut found: " + repr(checklist-map))
    }
    if type(_temp-symbol-map) == dictionary {
      symbol-map = for (k, v) in _temp-symbol-map { (str(k): small-text(v)) }
    }

    enable-character = get-depth-value(setting.enable-character, curr-level)
    assert(
      type(enable-character) == bool,
      message: "`enable-character` must be a bool; " + "\nbut found: " + repr(enable-character),
    )

    let extras = get-depth-value(setting.extras, curr-level)
    assert(
      type(extras) == bool,
      message: "`extras` must be a bool; " + "\nbut found: " + repr(extras),
    )

    symbol-list = (
      default-symbol-map(
        fill: fill-check,
        radius: radius-check,
        solid: solid-check,
        extras: extras,
      )
        + symbol-map
    )
    let enable-format = get-depth-value(setting.enable-format, curr-level)
    assert(
      type(enable-format) == bool,
      message: "`enable-format` must be a bool; " + "\nbut found: " + repr(enable-format),
    )
    if enable-format {
      let checklist-format-map = get-depth-value(setting.checklist-format-map, curr-level)
      assert(
        type(checklist-format-map) == dictionary,
        message: "`format-map` must be a dictionary; " + "\nbut found: " + repr(checklist-format-map),
      )
      format-map = default-format-map + checklist-format-map
    }
  }

  // `none` means no checklist, otherwise (checklist-marker, checklist-format, checklist-baseline)
  let symbol-func(body) = if curr-checklist {
    let marker = get-marker-text(body)
    if marker != none {
      let marker-text = symbol-list.at(marker, default: none)
      let checklist-marker = if marker-text != none {
        marker-text
      } else {
        if enable-character {
          character-symbol(fill: fill-check, radius: radius-check, solid: solid-check, symbol: marker)
        }
      }
      let checklist-format = format-map.at(marker, default: none)
      if checklist-marker != none {
        return (
          checklist-marker: checklist-marker,
          checklist-format: checklist-format,
          checklist-baseline: checklist-label-baseline,
        )
      }
    }
  }
  return (checklist-check: curr-checklist, symbol-func: symbol-func)
}
