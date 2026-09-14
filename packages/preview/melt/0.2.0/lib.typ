#let melt = plugin("./melt.wasm")
#import "@preview/oxifmt:1.0.0": strfmt

// NOTE: for accurately checking if the codepoint is an _assigned_ Unicode codepoint
// we need to query the Unicode database, which is not yet implemented
#let _is-valid-unicode(codepoint) = {
  (
    type(codepoint) == int
      and 0 <= codepoint
      and codepoint <= 0x10FFFF
      and not (0xD800 <= codepoint and codepoint <= 0xDFFF) // not a surrogate
  )
}

/// Returns an array of information of fonts in collection.
/// If it's not a font collection, it will be in length 1.
/// If some fatal parsing errors happened internal, it will be `()`
///
/// - data (bytes): font data
/// -> array
#let fonts-collection-info(data) = cbor(melt.fonts_collection_info(data))

/// Return a dictionary of information of a font.
/// If some fatal parsing errors happened internal, it will be `()`
///
/// - data (bytes): font data
/// - index (int): index of the font in collection, if not a collection, it shall be 0.
/// -> dictionary
#let font-info(data, index: 0) = fonts-collection-info(data).at(index)

/// Return a bool indicating if the font contains the given codepoint.
/// Notice that we'll not check whether provided `parsed-data` is valid.
///
/// - parsed-data (dictionary): font information from `font-info`
/// - codepoint (int): a valid Unicode point of character
/// -> bool
#let contains(parsed-data, codepoint) = {
  assert(
    _is-valid-unicode(codepoint),
    message: "codepoint must be a valid Unicode codepoint.",
  )
  let inside = false
  let cursor = 0
  let coverage = parsed-data.typst.coverage

  for run in coverage {
    if cursor <= codepoint and codepoint < cursor + run {
      return inside
    }
    cursor += run
    inside = not inside
  }
  false
}

/// Return an array of glyph information for the given codepoints.
///
/// - data (bytes): font data
/// - index (int): index of the font in the collection
/// - codepoints (array): array of valid Unicode codepoints
/// -> array
#let glyphs-info(data, index, codepoints) = {
  assert(
    type(index) == int and 0 <= index and index < 0xFFFFFFFF,
    message: "index must be an integer between 0 and 2^32 - 1",
  )
  assert(
    type(codepoints) == array and codepoints.all(_is-valid-unicode),
    message: "codepoints must be an array of valid Unicode codepoints.",
  )
  cbor(melt.glyphs_infos(data, cbor.encode(index), cbor.encode(codepoints)))
}

#let _into_css_color(c) = {
  if type(c) == str {
    c
  } else if type(c) == color {
    c.to-hex()
  } else if c == none {
    "none"
  } else {
    panic(
      strfmt(
        "type of `fill` shall be either `str`, `color` or `none`, find {}",
        repr(type(fill)),
      ),
    )
  }
}

/// Return a dictionary containing styles of SVG path
///
/// - scale (int, float, ratio): scale to applied to SVG path, additional px -> pt is already considerred.
/// - fill (str, color, none):
/// - fill-opacity (str, int, float, ratio):
/// - stroke (str, color, none):
/// - stroke-width (str, int, length): notice that if in length it must be a absolute length.
/// - extra (str, none):
/// -> dictionary
#let svg-path-styles(
  scale: 1.0,
  fill: "black",
  fill-opacity: "100%",
  stroke: none,
  stroke-width: "0",
  extra: "",
) = {
  assert(
    type(scale) in (int, float, ratio),
    message: "`scale` must be numeric.",
  )
  let fill = _into_css_color(fill)
  let stroke = _into_css_color(stroke)
  assert(
    type(fill-opacity) == str
      or (
        type(fill-opacity) in (ratio, int, float)
          and 0. <= float(fill-opacity)
          and float(fill-opacity) <= 1.
      ),
    message: strfmt(
      "`fill-opacity` shall be `str`, `ratio`, or a number in [0, 1], find {:?}",
      fill-opacity,
    ),
  )
  let stroke-width = if type(stroke-width) == str {
    stroke-width
  } else if type(stroke-width) in (int, float) {
    // px
    stroke-width
  } else if type(stroke-width) == length {
    stroke-width / 1pt * 1 / 0.75
  } else {
    panic(
      strfmt(
        "type of `strokw-width` shall be either `str`, `int`, `float`, or `length`, find {}",
        repr(type(stroke-width)),
      ),
    )
  }
  assert(
    type(extra) in (none, str),
    message: strfmt(
      "type of `extra` shall be `none` or `str`, find {}",
      repr(type(extra)),
    ),
  )
  (
    scale: float(scale) * 1.0 / 0.75, // additional pt -> px factor.
    fill: fill,
    fill-opacity: fill-opacity,
    stroke: stroke,
    stroke-width: stroke-width,
    extra: extra,
  )
}

/// Return an array of glyph shapes for the given codepoints.
///
/// - data (bytes): font data
/// - index (int): index of the font in the collection
/// - codepoints (array): array of valid Unicode codepoints
/// - styles (auto, dictionary, function): styles to be applied to SVG template
/// -> array
#let glyphs-shapes(data, index, codepoints, styles: auto) = {
  let styles-applier = if styles == auto {
    let styles = svg-path-styles()
    let scale = styles.scale
    (template, metrics) => strfmt(
      template,
      ..svg-path-styles(),
      ..metrics
        .keys()
        .zip(
          metrics.values().map(it => it * scale),
        )
        .to-dict(),
      ..styles,
    )
  } else if type(styles) == dictionary {
    let scale = styles.scale
    (template, metrics) => strfmt(
      template,
      ..svg-path-styles(),
      ..metrics
        .keys()
        .zip(
          metrics.values().map(it => it * scale),
        )
        .to-dict(),
      ..styles,
    )
  } else if type(styles) == function {
    styles
  } else {
    panic(strfmt(
      "type of `styles` must be `dictionary`, `function`, or `auto`, find {}",
      repr(type(styles)),
    ))
  }
  assert(
    type(index) == int and 0 <= index and index < 0xFFFFFFFF,
    message: "index must be an integer between 0 and 2^32 - 1",
  )
  assert(
    type(codepoints) == array and codepoints.all(_is-valid-unicode),
    message: "codepoints must be an array of valid Unicode codepoints.",
  )
  cbor(melt.glyphs_shapes(
    data,
    cbor.encode(index),
    cbor.encode(codepoints),
  )).map(
    shape => {
      styles-applier(shape.template, shape.metrics)
    },
  )
}
