#let zint-wasm = plugin("./zint_typst_plugin.wasm")

// One unit of Zint's layout, in which an X-dimension is two units at scale 1.
// The package used to embed Zint's SVG, which Typst reads at 96 units to the
// inch, so this keeps every barcode the size it has always had.
#let _unit = 0.75pt

// The colours Ultracode encodes data in, given as inks so that a printed
// symbol separates onto the plates the standard means.
#let _inks = (
  cyan: cmyk(100%, 0%, 0%, 0%),
  blue: cmyk(100%, 100%, 0%, 0%),
  magenta: cmyk(0%, 100%, 0%, 0%),
  red: cmyk(0%, 100%, 100%, 0%),
  yellow: cmyk(0%, 0%, 100%, 0%),
  green: cmyk(100%, 0%, 100%, 0%),
  black: cmyk(0%, 0%, 0%, 100%),
  white: cmyk(0%, 0%, 0%, 0%),
)

// A paint for `fill` or `background`, which may also be given the way
// `fg-color` and `bg-color` have always been given: as HEX text, with or
// without the `#`.
//
// Input:  "1F4788", or "#1F478880", or cmyk(0%, 0%, 0%, 100%)
// Output: rgb("#1F4788"), rgb("#1F478880"), or the CMYK colour unchanged
#let _paint(value, name) = {
  if value == none or type(value) in (color, gradient, tiling) {
    value
  } else if type(value) == str {
    rgb(if value.starts-with("#") { value } else { "#" + value })
  } else {
    panic(name + " must be a color, gradient, tiling or HEX color string; found " + str(type(value)))
  }
}

// Every spelling of the colour options the package has accepted. Zint no
// longer draws the colours, so each of them is read here as another name for
// `fill` or `background` and never sent to the plugin, which refuses them.
#let _foreground-options = ("fg-color", "fg-colour", "stroke")
#let _background-options = ("bg-color", "bg-colour", "fill")

// `fill` or `background`, from the argument or from whichever option spells it.
// Giving it twice would leave one of the two silently ignored, so that is an
// error instead.
//
// Input:  auto, (stroke: "1F4788"), ("fg-color", "fg-colour", "stroke")
// Output: rgb("#1F4788")
#let _aliased(given, options, aliases, name, default) = {
  let named = aliases.filter(it => options.at(it, default: none) != none)
  let given-as = if given == auto { named } else { (name,) + named }
  if given-as.len() > 1 {
    panic(
      name + " is given more than once, as " + given-as.join(" and ")
        + "; they are all the same setting, so give one of them",
    )
  }
  if given != auto {
    _paint(given, name)
  } else if named.len() == 1 {
    _paint(options.at(named.first()), named.first())
  } else {
    default
  }
}

// A width or height given the way `image` takes one, as an absolute length in
// the region it is laid out in. A ratio of a side the region does not bound
// comes to nothing, as it does for `image`.
//
// Input:  50% + 1em in a region 400pt wide, with 1em being 11pt
// Output: 211pt
#let _resolve(size, available, name) = {
  let base = if available == float.inf * 1pt { 0pt } else { available }
  if size == auto {
    auto
  } else if type(size) == length {
    size.to-absolute()
  } else if type(size) == ratio {
    size * base
  } else if type(size) == relative {
    size.ratio * base + size.length.to-absolute()
  } else {
    panic(name + " must be auto, a length or a ratio; found " + str(type(size)))
  }
}

// Where a drawing of `natural` size goes, sized the way Typst sizes an
// `image`, step for step: a side that is given is filled, and a side that is
// not keeps the natural size, but no more than `available` has room for.
// `given` holds the resolved width and height, either of which may be auto.
//
// The result is the space taken (`width`, `height`), the size the drawing is
// scaled to inside it (`fitted-width`, `fitted-height`), centred, and whether
// the drawing overflows that space and has to be clipped.
//
// Input:  natural 200pt x 100pt, given 100pt x 100pt, fit "contain"
// Output: 100pt x 100pt, fitted 100pt x 50pt, no clip
#let _fit(natural, given, available, fit) = {
  let (natural-width, natural-height) = natural
  let (given-width, given-height) = given
  let available-width = if given-width == auto { available.at(0) } else { given-width }
  let available-height = if given-height == auto { available.at(1) } else { given-height }
  let ratio = natural-width / natural-height

  let (width, height) = if given-width != auto and given-height != auto {
    (available-width, available-height)
  } else if given-width != auto {
    (available-width, calc.min(available-height, available-width / ratio))
  } else if given-height != auto {
    (calc.min(available-width, available-height * ratio), available-height)
  } else {
    (
      calc.min(natural-width, available-width, available-height * ratio),
      calc.min(natural-height, available-height, available-width / ratio),
    )
  }

  // The drawing is wider than the space it is fitted into, in proportion. A
  // space unbounded both ways has no proportion, and is not narrower.
  let available-ratio = available-width / available-height
  let wide = available-ratio == available-ratio and ratio > available-ratio
  let (fitted-width, fitted-height) = if fit == "stretch" {
    (width, height)
  } else if wide == (fit == "contain") {
    (width, width / ratio)
  } else {
    (height * ratio, height)
  }

  (
    width: width,
    height: height,
    fitted-width: fitted-width,
    fitted-height: fitted-height,
    // Only "cover" can overflow, and only then is anything cut off, so text
    // set larger than Zint laid it out for stays visible otherwise.
    clip: fitted-width - width > 0.001pt or fitted-height - height > 0.001pt,
  )
}

// The shapes the plugin returned, drawn with `x-unit` and `y-unit` to one unit
// of Zint's layout.
#let _shapes(plot, fill, background, hrt, x-unit, y-unit) = {
  let width = plot.width * x-unit
  let height = plot.height * y-unit
  box(width: width, height: height, {
    if background != none {
      place(rect(width: width, height: height, fill: background, stroke: none))
    }

    // A path drawn in Zint's own units, scaled as a whole. The PDF then holds
    // Zint's coordinates, mostly small integers, under one transform, rather
    // than every corner in points with decimals, which roughly halves the
    // size of a large symbol's drawing.
    let in-units(body) = place(scale(
      x: x-unit / 1pt * 100%,
      y: y-unit / 1pt * 100%,
      origin: top + left,
      reflow: false,
      body,
    ))

    // One path per ink, as Zint's own writers draw them: rectangles that touch
    // are then filled as a single area, with no hairline seam between them
    // where a viewer anti-aliases two edges that meet.
    let inks = plot.rectangles.map(it => it.ink).dedup()
    for ink in inks {
      let corners = plot
        .rectangles
        .filter(it => it.ink == ink)
        .map(it => {
          let (left, top) = (it.x * 1pt, it.y * 1pt)
          let (right, bottom) = ((it.x + it.width) * 1pt, (it.y + it.height) * 1pt)
          // A straight close is the fourth side. The default, smooth one
          // writes a degenerate curve back to the start for every rectangle.
          (
            curve.move((left, top)),
            curve.line((right, top)),
            curve.line((right, bottom)),
            curve.line((left, bottom)),
            curve.close(mode: "straight"),
          )
        })
        .join()
      let paint = if ink == "foreground" { fill } else { _inks.at(ink) }
      in-units(curve(fill: paint, stroke: none, ..corners))
    }

    // MaxiCode modules. At 0 and 180 degrees an apex points up, at 90 and 270
    // one points left; the corners are the ones Zint's SVG writer draws.
    if plot.hexagons.len() > 0 {
      let corners = plot
        .hexagons
        .map(it => {
          let radius = it.diameter / 2
          let half = it.diameter / 4
          let apothem = it.diameter * calc.sqrt(3) / 4
          let points = if it.rotation == 0 or it.rotation == 180 {
            ((0, radius), (apothem, half), (apothem, -half), (0, -radius), (-apothem, -half), (-apothem, half))
          } else {
            ((-radius, 0), (-half, apothem), (half, apothem), (radius, 0), (half, -apothem), (-half, -apothem))
          }
          let (first, ..rest) = points.map(((dx, dy)) => ((it.x + dx) * 1pt, (it.y + dy) * 1pt))
          (curve.move(first), ..rest.map(curve.line), curve.close(mode: "straight"))
        })
        .join()
      in-units(curve(fill: fill, stroke: none, ..corners))
    }

    // Dots in dotty mode, and the rings of the MaxiCode bullseye.
    for it in plot.circles {
      let paint = if it.background { background } else { fill }
      if paint != none {
        let shape = if it.stroke == 0 {
          ellipse(width: it.diameter * x-unit, height: it.diameter * y-unit, fill: paint, stroke: none)
        } else {
          ellipse(
            width: it.diameter * x-unit,
            height: it.diameter * y-unit,
            fill: none,
            stroke: (paint: paint, thickness: it.stroke * x-unit),
          )
        }
        place(dx: (it.x - it.diameter / 2) * x-unit, dy: (it.y - it.diameter / 2) * y-unit, shape)
      }
    }

    // Human readable text. Zint gives the baseline and an anchor that the
    // alignment says how to read, and lays the symbol out for a font of the
    // size it gives; `hrt` may override any of it.
    for it in plot.texts {
      let body = text(
        font: "DejaVu Sans Mono",
        size: it.size * y-unit,
        weight: if it.bold { "bold" } else { "regular" },
        fill: fill,
        // A frame of no height whose top is the baseline, so that placing it
        // at Zint's `y` puts the baseline there.
        top-edge: "baseline",
        bottom-edge: "baseline",
        ..hrt,
        it.text,
      )
      let shift = if it.align == "center" {
        measure(body).width / 2
      } else if it.align == "right" {
        measure(body).width
      } else {
        0pt
      }
      place(
        dx: it.x * x-unit,
        dy: it.y * y-unit,
        rotate(it.rotation * 1deg, origin: top + left, reflow: false, move(dx: -shift, body)),
      )
    }
  })
}

/// Draw a barcode of any supported `symbology`.
///
/// The barcode is drawn with Typst's own shapes, so `fill` and `background`
/// reach the document as they are given: a `cmyk` colour stays CMYK in the
/// PDF.
///
/// *Example:*
///
/// ```example
/// #tiaoma.barcode("12345678", "QRCode", fill: gradient.linear(blue, red), background: green.lighten(70%), options: (
///   scale: 2.0,
///   output-options: (
///     barcode-dotty-mode: true
///   ),
///   dot-size: 1.2,
/// ))
/// ```
///
/// - data (str, bytes, array): Data to encode. Bytes are passed to Zint as
///     they are, so a payload that is not text needs `input-mode` set to
///     `data`.
/// - symbology (str): Symbology type name; must be one of #l(<symbology>)[supported types].
///
///     Example values: #typst-val("\"Code11\""), #typst-val("\"C25Standard\""), ...
/// - options (dictionary): Additional options to pass to Zint.
///
///     See the #l(<options>)[configuration section] for details on available options and how to use them.
/// - fill (auto, color, gradient, tiling, str): What the bars, modules and human readable text are drawn with. `auto` is the `fg-color` option if it is given, and black otherwise.
/// - background (auto, none, color, gradient, tiling, str): What the area behind the symbol, quiet zones included, is filled with. `auto` is the `bg-color` option if it is given, and nothing otherwise.
/// - hrt (dictionary): Arguments for the #l("https://typst.app/docs/reference/text/text/", raw("text", lang: "typ")) function that sets the human readable text, such as `font` or `size`. A `size` given here is used as it is, however large the barcode is drawn; by default the text is set in DejaVu Sans Mono at the size Zint lays it out for.
/// - width (auto, relative): The width of the barcode, as for #l("https://typst.app/docs/reference/visualize/image/", raw("image", lang: "typ")).
/// - height (auto, relative): The height of the barcode, as for `image`.
/// - fit (str): How the barcode fills a `width` and `height` of a different shape, as for `image`: #typst-val("\"cover\""), #typst-val("\"contain\"") or #typst-val("\"stretch\"").
/// -> content
#let barcode(
  data,
  symbology,
  options: (:),
  fill: auto,
  background: auto,
  hrt: (:),
  width: auto,
  height: auto,
  fit: "cover",
) = {
  let data = data
  if type(data) == str {
    data = bytes(data)
  } else if type(data) == array {
    data = bytes(data)
  }
  if fit not in ("cover", "contain", "stretch") {
    panic("fit must be \"cover\", \"contain\" or \"stretch\"; found " + repr(fit))
  }

  let fill = _aliased(fill, options, _foreground-options, "fill", black)
  let background = _aliased(background, options, _background-options, "background", none)
  // The colours are drawn here rather than by Zint, so they are not sent.
  let options = options
  for key in _foreground-options + _background-options {
    let _ = options.remove(key, default: none)
  }

  let plot = cbor(zint-wasm.gen_with_options(
    cbor.encode((symbology: symbology, ..options)),
    data,
  ))
  let natural-width = plot.width * _unit
  let natural-height = plot.height * _unit

  box(layout(region => {
    // Everything below is positioned from the top left corner. `place` starts
    // from `start`, which has no vertical part and flips with the text
    // direction, so an alignment or direction around the barcode would get
    // through, and a shape laid out larger than the space it is drawn into,
    // such as a path in Zint's units, would move against the rest.
    set place(top + left)

    let placed = _fit(
      (natural-width, natural-height),
      (_resolve(width, region.width, "width"), _resolve(height, region.height, "height")),
      (region.width, region.height),
      fit,
    )

    box(
      width: placed.width,
      height: placed.height,
      clip: placed.clip,
      place(
        dx: (placed.width - placed.fitted-width) / 2,
        dy: (placed.height - placed.fitted-height) / 2,
        _shapes(
          plot,
          fill,
          background,
          hrt,
          _unit * (placed.fitted-width / natural-width),
          _unit * (placed.fitted-height / natural-height),
        ),
      ),
    )
  }))
}

/// Returns the #typst-type("int") `option-2` value that fixes a Data Matrix to the given _height_ and _width_.
///
/// A fixed size is an `option-2` value, as it selects one entry of Zint's size table. #l(<opt_3>, "Option 3") is a different setting: its `DM_SQUARE` and `DM_DMRE` values only constrain the size Zint picks on its own.
///
/// - height (int): Data Matrix height
/// - width (int): Data Matrix width
/// -> int
#let dm-size(height, width) = {
  // Copied from DM size table
  if height == 10 and width == 10 {
    return int(1)
  }
  if height == 12 and width == 12 {
    return int(2)
  }
  if height == 14 and width == 14 {
    return int(3)
  }
  if height == 16 and width == 16 {
    return int(4)
  }
  if height == 18 and width == 18 {
    return int(5)
  }
  if height == 20 and width == 20 {
    return int(6)
  }
  if height == 22 and width == 22 {
    return int(7)
  }
  if height == 24 and width == 24 {
    return int(8)
  }
  if height == 26 and width == 26 {
    return int(9)
  }
  if height == 32 and width == 32 {
    return int(10)
  }
  if height == 36 and width == 36 {
    return int(11)
  }
  if height == 40 and width == 40 {
    return int(12)
  }
  if height == 44 and width == 44 {
    return int(13)
  }
  if height == 48 and width == 48 {
    return int(14)
  }
  if height == 52 and width == 52 {
    return int(15)
  }
  if height == 64 and width == 64 {
    return int(16)
  }
  if height == 72 and width == 72 {
    return int(17)
  }
  if height == 80 and width == 80 {
    return int(18)
  }
  if height == 88 and width == 88 {
    return int(19)
  }
  if height == 96 and width == 96 {
    return int(20)
  }
  if height == 104 and width == 104 {
    return int(21)
  }
  if height == 120 and width == 120 {
    return int(22)
  }
  if height == 132 and width == 132 {
    return int(23)
  }
  if height == 144 and width == 144 {
    return int(24)
  }
  if height == 8 and width == 18 {
    return int(25)
  }
  if height == 8 and width == 32 {
    return int(26)
  }
  if height == 12 and width == 26 {
    return int(27)
  }
  if height == 12 and width == 36 {
    return int(28)
  }
  if height == 16 and width == 36 {
    return int(29)
  }
  if height == 16 and width == 48 {
    return int(30)
  }

  // Copied from DMRE table
  if height == 8 and width == 48 {
    return int(31)
  }
  if height == 8 and width == 64 {
    return int(32)
  }
  if height == 8 and width == 80 {
    return int(33)
  }
  if height == 8 and width == 96 {
    return int(34)
  }
  if height == 8 and width == 120 {
    return int(35)
  }
  if height == 8 and width == 144 {
    return int(36)
  }
  if height == 12 and width == 64 {
    return int(37)
  }
  if height == 12 and width == 88 {
    return int(38)
  }
  if height == 16 and width == 64 {
    return int(39)
  }
  if height == 20 and width == 36 {
    return int(40)
  }
  if height == 20 and width == 44 {
    return int(41)
  }
  if height == 20 and width == 64 {
    return int(42)
  }
  if height == 22 and width == 48 {
    return int(43)
  }
  if height == 24 and width == 48 {
    return int(44)
  }
  if height == 24 and width == 64 {
    return int(45)
  }
  if height == 26 and width == 40 {
    return int(46)
  }
  if height == 26 and width == 48 {
    return int(47)
  }
  if height == 26 and width == 64 {
    return int(48)
  }
  panic("Data Matrix with dimensions " + str(width) + "x" + str(height) + " not supported")
}

#let code11(data, options: (:), ..args) = barcode(
  data,
  "Code11",
  options: options,
  ..args,
)
#let c25-standard(data, options: (:), ..args) = barcode(
  data,
  "C25Standard",
  options: options,
  ..args,
)
#let c25-inter(data, options: (:), ..args) = barcode(
  data,
  "C25Inter",
  options: options,
  ..args,
)
#let c25-iata(data, options: (:), ..args) = barcode(
  data,
  "C25IATA",
  options: options,
  ..args,
)
#let c25-logic(data, options: (:), ..args) = barcode(
  data,
  "C25Logic",
  options: options,
  ..args,
)
#let c25-ind(data, options: (:), ..args) = barcode(
  data,
  "C25Ind",
  options: options,
  ..args,
)
#let code39(data, options: (:), ..args) = barcode(
  data,
  "Code39",
  options: options,
  ..args,
)
#let ex-code39(data, options: (:), ..args) = barcode(
  data,
  "ExCode39",
  options: options,
  ..args,
)
#let ean8(data, options: (:), ..args) = barcode(
  data,
  "EAN8",
  options: options,
  ..args,
)
#let ean-2addon(data, options: (:), ..args) = barcode(
  data,
  "EAN2Addon",
  options: options,
  ..args,
)
#let ean-5addon(data, options: (:), ..args) = barcode(
  data,
  "EAN5Addon",
  options: options,
  ..args,
)
#let eanx(data, options: (:), ..args) = barcode(
  data,
  "EANX",
  options: options,
  ..args,
)
#let eanx-chk(data, options: (:), ..args) = barcode(
  data,
  "EANXChk",
  options: options,
  ..args,
)
#let ean13(data, options: (:), ..args) = barcode(
  data,
  "EAN13",
  options: options,
  ..args,
)
#let ean(data, options: (:), ..args) = eanx-chk(data, options: options, ..args)
#let gs1-128(data, options: (:), ..args) = barcode(
  data,
  "GS1128",
  options: options,
  ..args,
)
#let codabar(data, options: (:), ..args) = barcode(
  data,
  "Codabar",
  options: options,
  ..args,
)
#let code128(data, options: (:), ..args) = barcode(
  data,
  "Code128",
  options: options,
  ..args,
)
#let dp-leitcode(data, options: (:), ..args) = barcode(
  data,
  "DPLEIT",
  options: options,
  ..args,
)
#let dp-ident(data, options: (:), ..args) = barcode(
  data,
  "DPIDENT",
  options: options,
  ..args,
)
#let code16k(data, options: (:), ..args) = barcode(
  data,
  "Code16k",
  options: options,
  ..args,
)
#let code49(data, options: (:), ..args) = barcode(
  data,
  "Code49",
  options: options,
  ..args,
)
#let code93(data, options: (:), ..args) = barcode(
  data,
  "Code93",
  options: options,
  ..args,
)
#let flat(data, options: (:), ..args) = barcode(
  data,
  "Flat",
  options: options,
  ..args,
)
#let dbar-omn(data, options: (:), ..args) = barcode(
  data,
  "DBarOmn",
  options: options,
  ..args,
)
#let dbar-ltd(data, options: (:), ..args) = barcode(
  data,
  "DBarLtd",
  options: options,
  ..args,
)
#let dbar-exp(data, options: (:), ..args) = barcode(
  data,
  "DBarExp",
  options: options,
  ..args,
)
#let telepen(data, options: (:), ..args) = barcode(
  data,
  "Telepen",
  options: options,
  ..args,
)
#let upca(data, options: (:), ..args) = barcode(
  data,
  "UPCA",
  options: options,
  ..args,
)
#let upca-chk(data, options: (:), ..args) = barcode(
  data,
  "UPCAChk",
  options: options,
  ..args,
)
#let upce(data, options: (:), ..args) = barcode(
  data,
  "UPCE",
  options: options,
  ..args,
)
#let upce-chk(data, options: (:), ..args) = barcode(
  data,
  "UPCEChk",
  options: options,
  ..args,
)
#let postnet(data, options: (:), ..args) = barcode(
  data,
  "Postnet",
  options: options,
  ..args,
)
#let msi-plessey(data, options: (:), ..args) = barcode(
  data,
  "MSIPlessey",
  options: options,
  ..args,
)
#let fim(data, options: (:), ..args) = barcode(
  data,
  "FIM",
  options: options,
  ..args,
)
#let logmars(data, options: (:), ..args) = barcode(
  data,
  "Logmars",
  options: options,
  ..args,
)
#let pharma(data, options: (:), ..args) = barcode(
  data,
  "Pharma",
  options: options,
  ..args,
)
#let pzn(data, options: (:), ..args) = barcode(
  data,
  "PZN",
  options: options,
  ..args,
)
#let pharma-two(data, options: (:), ..args) = barcode(
  data,
  "PharmaTwo",
  options: options,
  ..args,
)
#let cepnet(data, options: (:), ..args) = barcode(
  data,
  "CEPNet",
  options: options,
  ..args,
)
#let pdf417(data, options: (:), ..args) = barcode(
  data,
  "PDF417",
  options: options,
  ..args,
)
#let pdf417-comp(data, options: (:), ..args) = barcode(
  data,
  "PDF417Comp",
  options: options,
  ..args,
)
#let maxicode(data, options: (:), ..args) = barcode(
  data,
  "MaxiCode",
  options: options,
  ..args,
)
#let qrcode(data, options: (:), ..args) = barcode(
  data,
  "QRCode",
  options: options,
  ..args,
)
#let code128ab(data, options: (:), ..args) = barcode(
  data,
  "Code128AB",
  options: options,
  ..args,
)
#let aus-post(data, options: (:), ..args) = barcode(
  data,
  "AusPost",
  options: options,
  ..args,
)
#let aus-reply(data, options: (:), ..args) = barcode(
  data,
  "AusReply",
  options: options,
  ..args,
)
#let aus-route(data, options: (:), ..args) = barcode(
  data,
  "AusRoute",
  options: options,
  ..args,
)
#let aus-redirect(data, options: (:), ..args) = barcode(
  data,
  "AusRedirect",
  options: options,
  ..args,
)
#let isbnx(data, options: (:), ..args) = barcode(
  data,
  "ISBNX",
  options: options,
  ..args,
)
#let rm4scc(data, options: (:), ..args) = barcode(
  data,
  "RM4SCC",
  options: options,
  ..args,
)
#let data-matrix(data, options: (:), ..args) = barcode(
  data,
  "DataMatrix",
  options: options,
  ..args,
)
#let ean14(data, options: (:), ..args) = barcode(
  data,
  "EAN14",
  options: options,
  ..args,
)
#let vin(data, options: (:), ..args) = barcode(
  data,
  "VIN",
  options: options,
  ..args,
)
#let codablock-f(data, options: (:), ..args) = barcode(
  data,
  "CodablockF",
  options: options,
  ..args,
)
#let nve18(data, options: (:), ..args) = barcode(
  data,
  "NVE18",
  options: options,
  ..args,
)
#let japan-post(data, options: (:), ..args) = barcode(
  data,
  "JapanPost",
  options: options,
  ..args,
)
#let korea-post(data, options: (:), ..args) = barcode(
  data,
  "KoreaPost",
  options: options,
  ..args,
)
#let dbar-stk(data, options: (:), ..args) = barcode(
  data,
  "DBarStk",
  options: options,
  ..args,
)
#let dbar-omn-stk(data, options: (:), ..args) = barcode(
  data,
  "DBarOmnStk",
  options: options,
  ..args,
)
#let dbar-exp-stk(data, options: (:), ..args) = barcode(
  data,
  "DBarExpStk",
  options: options,
  ..args,
)
#let planet(data, options: (:), ..args) = barcode(
  data,
  "Planet",
  options: options,
  ..args,
)
#let micro-pdf417(data, options: (:), ..args) = barcode(
  data,
  "MicroPDF417",
  options: options,
  ..args,
)
#let usps-imail(data, options: (:), ..args) = barcode(
  data,
  "USPSIMail",
  options: options,
  ..args,
)
#let plessey(data, options: (:), ..args) = barcode(
  data,
  "Plessey",
  options: options,
  ..args,
)
#let telepen-num(data, options: (:), ..args) = barcode(
  data,
  "TelepenNum",
  options: options,
  ..args,
)
#let itf14(data, options: (:), ..args) = barcode(
  data,
  "ITF14",
  options: options,
  ..args,
)
#let kix(data, options: (:), ..args) = barcode(
  data,
  "KIX",
  options: options,
  ..args,
)
#let aztec(data, options: (:), ..args) = barcode(
  data,
  "Aztec",
  options: options,
  ..args,
)
#let daft(data, options: (:), ..args) = barcode(
  data,
  "DAFT",
  options: options,
  ..args,
)
#let dpd(data, options: (:), ..args) = barcode(
  data,
  "DPD",
  options: options,
  ..args,
)
#let micro-qr(data, options: (:), ..args) = barcode(
  data,
  "MicroQR",
  options: options,
  ..args,
)
#let hibc-128(data, options: (:), ..args) = barcode(
  data,
  "HIBC128",
  options: options,
  ..args,
)
#let hibc-39(data, options: (:), ..args) = barcode(
  data,
  "HIBC39",
  options: options,
  ..args,
)
#let hibc-dm(data, options: (:), ..args) = barcode(
  data,
  "HIBCDM",
  options: options,
  ..args,
)
#let hibc-qr(data, options: (:), ..args) = barcode(
  data,
  "HIBCQR",
  options: options,
  ..args,
)
#let hibc-pdf(data, options: (:), ..args) = barcode(
  data,
  "HIBCPDF",
  options: options,
  ..args,
)
#let hibc-mic-pdf(data, options: (:), ..args) = barcode(
  data,
  "HIBCMicPDF",
  options: options,
  ..args,
)
#let hibc-codablock-f(data, options: (:), ..args) = barcode(
  data,
  "HIBCCodablockF",
  options: options,
  ..args,
)
#let hibc-aztec(data, options: (:), ..args) = barcode(
  data,
  "HIBCAztec",
  options: options,
  ..args,
)
#let dotcode(data, options: (:), ..args) = barcode(
  data,
  "DotCode",
  options: options,
  ..args,
)
#let hanxin(data, options: (:), ..args) = barcode(
  data,
  "HanXin",
  options: options,
  ..args,
)
#let upus10(data, options: (:), ..args) = barcode(
  data,
  "UPUS10",
  options: options,
  ..args,
)
#let mailmark-4s(data, options: (:), ..args) = barcode(
  data,
  "Mailmark4S",
  options: options,
  ..args,
)
#let azrune(data, options: (:), ..args) = barcode(
  data,
  "AzRune",
  options: options,
  ..args,
)
#let code32(data, options: (:), ..args) = barcode(
  data,
  "Code32",
  options: options,
  ..args,
)
#let channel(data, options: (:), ..args) = barcode(
  data,
  "Channel",
  options: options,
  ..args,
)
#let code-one(data, options: (:), ..args) = barcode(
  data,
  "CodeOne",
  options: options,
  ..args,
)
#let grid-matrix(data, options: (:), ..args) = barcode(
  data,
  "GridMatrix",
  options: options,
  ..args,
)
#let upnqr(data, options: (:), ..args) = barcode(
  data,
  "UPNQR",
  options: options,
  ..args,
)
#let ultra(data, options: (:), ..args) = barcode(
  data,
  "Ultra",
  options: options,
  ..args,
)
#let rmqr(data, options: (:), ..args) = barcode(
  data,
  "RMQR",
  options: options,
  ..args,
)
#let bc412(data, options: (:), ..args) = barcode(
  data,
  "BC412",
  options: options,
  ..args,
)
#let dx-film-edge(data, options: (:), ..args) = barcode(
  data,
  "DXFilmEdge",
  options: options,
  ..args,
)

#let mailmark-2d(height, width, data, options: (:), ..args) = barcode(
  data,
  "Mailmark2D",
  options: (
    option-2: dm-size(height, width),
    ..options,
  ),
  ..args,
)

#let barcode-primary(primary, data, type, options: (:), ..args) = barcode(
  data,
  type,
  options: (
    primary: primary,
    ..options,
  ),
  ..args,
)

#let barcode-composite(
  primary,
  data,
  mode,
  type,
  options: (:),
  ..args,
) = barcode-primary(
  primary,
  data,
  type,
  options: (
    option-1: int(mode),
    ..options,
  ),
  ..args,
)

// Composite symbols carry a linear component alongside the 2D one, so their
// shortcuts take it as `primary` the way `barcode-primary` does. Zint chooses
// the composite mode by itself; `option-1` overrides it, as `barcode-composite`
// does.
#let ean8-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "EAN8CC",
  options: options,
  ..args,
)
#let ean13-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "EAN13CC",
  options: options,
  ..args,
)
#let eanx-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "EANXCC",
  options: options,
  ..args,
)
#let gs1-128-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "GS1128CC",
  options: options,
  ..args,
)
#let dbar-omn-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarOmnCC",
  options: options,
  ..args,
)
#let dbar-ltd-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarLtdCC",
  options: options,
  ..args,
)
#let dbar-exp-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarExpCC",
  options: options,
  ..args,
)
#let dbar-stk-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarStkCC",
  options: options,
  ..args,
)
#let dbar-omn-stk-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarOmnStkCC",
  options: options,
  ..args,
)
#let dbar-exp-stk-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "DBarExpStkCC",
  options: options,
  ..args,
)
#let upca-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "UPCACC",
  options: options,
  ..args,
)
#let upce-cc(primary, data, options: (:), ..args) = barcode-primary(
  primary,
  data,
  "UPCECC",
  options: options,
  ..args,
)
