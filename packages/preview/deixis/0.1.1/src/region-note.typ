#import "core.typ": *
#import "pin.typ": *

// Shared Region Rendering Engine
#let _deixis-render-region-shape(
  sys,
  reg,
  all-pins,
  current-page,
  base-pos: none,
  draw-shape: true,
  draw-marker: true,
) = {
  let active-pins = ()
  for pin-name in reg.pins {
    let matches = all-pins.filter(p => p.value.name == pin-name)
    for m in matches { active-pins.push(m) }
  }

  if active-pins.len() == 0 { return none }

  let sorted-pins = active-pins.sorted(key: p => (p.location().page(), p.location().position().y))
  let first-page = sorted-pins.first().location().page()
  let last-page = sorted-pins.last().location().page()

  if current-page < first-page or current-page > last-page { return none }

  let min-x = 1e10pt
  let max-x = -1e10pt

  for p in active-pins {
    let px = deixis-utils.resolve-signed-len(p.location().position().x)
    let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
    let px-l = px - deixis-utils.resolve-signed-len(p-pad.left)
    let px-r = px + deixis-utils.resolve-signed-len(p-pad.right)
    if px-l < min-x { min-x = px-l }
    if px-r > max-x { max-x = px-r }
  }

  let p-margins = deixis-utils.get-page-margins(current-page)
  let page-h = deixis-utils.resolve-len(if type(page.height) == length { page.height } else {
    deixis-utils.default-page-size.height
  })
  let text-top = deixis-utils.resolve-len(p-margins.top)
  let text-bottom = page-h - deixis-utils.resolve-len(p-margins.bottom)

  let min-y = text-top
  let max-y = text-bottom

  let page-pins = active-pins.filter(p => p.location().page() == current-page)

  if page-pins.len() > 0 {
    let local-min-y = 1e10pt
    let local-max-y = -1e10pt
    for p in page-pins {
      let py = deixis-utils.resolve-signed-len(p.location().position().y)
      let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
      let py-t = py - deixis-utils.resolve-signed-len(p-pad.top)
      let py-b = py + deixis-utils.resolve-signed-len(p-pad.bottom)
      if py-t < local-min-y { local-min-y = py-t }
      if py-b > local-max-y { local-max-y = py-b }
    }
    if current-page == first-page { min-y = local-min-y }
    if current-page == last-page { max-y = local-max-y }
  }

  let reg-pad = deixis-utils.get-margins(reg.styles.at("padding", default: 0pt))
  min-x -= deixis-utils.resolve-signed-len(reg-pad.left)
  max-x += deixis-utils.resolve-signed-len(reg-pad.right)

  if current-page == first-page { min-y -= deixis-utils.resolve-signed-len(reg-pad.top) }
  if current-page == last-page { max-y += deixis-utils.resolve-signed-len(reg-pad.bottom) }

  let box-w = max-x - min-x
  let box-h = max-y - min-y

  // Cross-page style adjustments
  let c-styles = reg.styles
  if first-page != last-page {
    let c-rad = deixis-utils.get-radius(reg.styles.at("radius", default: 0pt))
    let c-stroke = deixis-utils.get-stroke(reg.styles.at("stroke", default: none))

    if current-page == first-page {
      c-rad.bottom-left = 0pt
      c-rad.bottom-right = 0pt
      if c-stroke != none { c-stroke.bottom = none }
    } else if current-page == last-page {
      c-rad.top-left = 0pt
      c-rad.top-right = 0pt
      if c-stroke != none { c-stroke.top = none }
    } else {
      c-rad = (top-left: 0pt, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt)
      if c-stroke != none {
        c-stroke.top = none
        c-stroke.bottom = none
      }
    }
    c-styles.radius = c-rad
    c-styles.stroke = c-stroke
  }

  let active-shape-func = reg.at("shape-func", default: deixis-rect-region)
  let highlight-box = active-shape-func(width: box-w, height: box-h, ..c-styles)

  let body-exists = if reg.body-lbl != none { query(selector(reg.body-lbl)).len() > 0 } else { false }

  let anchor = if current-page == first-page and reg.mark-lbl != none {
    [#metadata(none)#reg.mark-lbl]
  } else { none }

  let mark-marker-style = _deixis-resolve-typed-param(
    sys,
    reg.at("marker-style", default: auto),
    "marker-style",
    "region-mark",
    component: "mark",
  )

  let marker = if reg.marker-str == none {
    anchor
  } else if body-exists {
    [#anchor#std.link(reg.body-lbl)[#mark-marker-style(reg.marker-str)]]
  } else {
    [#anchor#mark-marker-style(reg.marker-str)]
  }

  let c-mark-pos = reg.styles.at("marker-position", default: top + right)
  let pos-dict = if type(c-mark-pos) == dictionary { c-mark-pos } else { (align: c-mark-pos, dx: 0pt, dy: 0pt) }

  let m-align = pos-dict.at("align", default: top + left)

  let resolve-relative(val, base-len) = {
    if type(val) == length { return val }
    if type(val) == ratio { return val * base-len }
    if type(val) == relative { return val.length + (val.ratio * base-len) }
    return 0pt
  }

  let m-dx = resolve-relative(pos-dict.at("dx", default: 0pt), box-w)
  let m-dy = resolve-relative(pos-dict.at("dy", default: 0pt), box-h)

  // Coordinate Relativity
  let offset-x = min-x
  let offset-y = min-y
  if base-pos != none {
    offset-x -= deixis-utils.resolve-signed-len(base-pos.x)
    offset-y -= deixis-utils.resolve-signed-len(base-pos.y)
  }

  place(top + left, dx: offset-x, dy: offset-y, box(width: box-w, height: box-h, {
    if draw-shape { highlight-box }

    if draw-marker and marker != none {
      let m-size = measure(marker)
      let m-str = repr(m-align)

      let align-x = if "left" in m-str { -1 } else if "right" in m-str { 1 } else { 0 }
      let align-y = if "top" in m-str { -1 } else if "bottom" in m-str { 1 } else { 0 }

      let out-dx = (m-size.width / 2.0) * align-x + m-dx
      let out-dy = (m-size.height / 2.0) * align-y + m-dy

      place(m-align, dx: out-dx, dy: out-dy, marker)
    }
  }))
}

/// A visual enclose mark of a specific region in the document.
///
/// Region marks are highly versatile. They can dynamically wrap a continuous block of text provided as a
/// positional argument, or they can asynchronously draw a shape spanning between pre-defined `#deixis-pin` coordinates.
/// They natively support crossing page boundaries when using the background or foreground layers.
///
/// ```example
/// Inline marks cannot highlight equations or `raw`:
///
/// #deixis-inline-mark[*Sigmoid:* $f(x) = frac(1, 1 + e^(-x))$ or `torch.sigmoid`.]
///
/// This is where region marks shine:
///
/// #deixis-region-mark(inline: true)[*ReLU:* $f(x) = max(0, x)$ or `torch.relu`]
/// ```
///
/// ```example
/// #let highlight-cell = deixis-region-mark.with(stroke: blue, fill: blue.transparentize(95%))
///
/// #set text(0.8em)
/// #table(
///   columns: (auto, 1fr, auto, 1fr),
///   align: center + horizon,
///   fill: (x, y) => if y == 0 { gray.lighten(80%) },
///
///   table.header([*Function*], [*Equation*], [*Output\ Range*], [*Common\ Usecase*]),
///   [*Sigmoid*], [$1 / (1 + e^(-x))$], [$(0, 1)$], [Binary classifier],
///   [*Tanh*], [$(e^x - e^(-x)) / (e^x + e^(-x))$], [$(-1, 1)$], [RNNs],
///   [*ReLU*], [$max(0, x)$], [$[0, inf)$], [CNNs],
///   [*GELU*], highlight-cell(padding: 4pt)[$x Phi(x)$], [$approx [-0.17, inf)$], [*Transformers*],
/// )
/// ```
///
/// - ..args (arguments): Accepts at most 1 positional argument: `[body]`.
/// - id (none, str, label): The unique identifier linking this region to its data/body state.
/// - pins (array): An array of pin names (e.g., `("pinA", "pinB")`). If provided, the note draws between these pins instead of wrapping a positional body. Cannot be used simultaneously with a positional body argument.
/// - numbering (auto, str, function): The numbering style for the region's marker.
/// - marker (auto, content): A hardcoded marker to use instead of the automatic counter.
/// - target (int, label, str): The specific block/minipage counter context this mark belongs to.
/// - series (str): The counter series this mark belongs to.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the generated marker.
/// - marker-position (auto, alignment, dictionary): Where to place the marker relative to the bounding box.
/// - stroke (auto, stroke, none): The border stroke of the region highlight.
/// - fill (auto, color, none): The background fill color of the region highlight.
/// - radius (auto, length, dictionary): The border radius of the region shape. Automatically adjusts when breaking across pages.
/// - padding (auto, length, str): The padding between the highlighted text and the border. Using `"text"` aligns to font metrics.
/// - region-shape (auto, function): Shape drawing function.
/// - layer (auto, str): The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
/// - inline (bool): If `true`, the region wraps the text in an inline `box` instead of a standard `block`.
///
/// -> content
#let deixis-region-mark(
  /// Accepts at most 1 positional argument: `[body]`.
  /// -> arguments
  ..args,
  /// The unique identifier linking this region to its data/body state.
  /// -> none | str | label
  id: none,
  /// An array of pin names (e.g., `("pinA", "pinB")`). If provided, the note draws between these pins instead of wrapping a positional body. Cannot be used simultaneously with a positional body argument.
  ///
  /// See @deixis-pin and @deixis-attach.
  ///
  /// -> array
  pins: (),
  /// The numbering style for the region's marker.
  /// -> auto | str | function
  numbering: auto,
  /// A hardcoded marker to use instead of the automatic counter.
  /// -> auto | content
  marker: auto,
  /// The specific block/minipage counter context this mark belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this mark belongs to.
  /// -> str
  series: "default",
  /// A custom styling function `(string) => content` for the generated marker.
  /// -> auto | function
  marker-style: auto,
  /// Where to place the marker relative to the bounding box.
  /// - If `alignment`, align to one of the 9 locations.
  /// ```example
  /// #deixis-region-mark(
  ///   id: <celibate-region1>,
  ///   marker-position: top + center)[#lorem(10)]
  /// ```
  /// - If `dictionary` of `length` or `relative`, place the mark at `(dx, dy)` relative to the top left corner of the region. `relative` is understood as to the dimensions of the region.
  /// ```example
  /// #deixis-region-mark(
  ///   id: <celibate-region2>,
  ///   marker-position: (dx: 100% + 5pt, dy: 5pt))[#lorem(10)]
  /// ```
  ///
  /// -> auto | alignment | dictionary
  marker-position: auto,
  /// The border stroke of the region highlight.
  /// -> auto | stroke | none
  stroke: auto,
  /// The background fill color of the region highlight.
  /// -> auto | color | none
  fill: auto,
  /// The border radius of the region shape. Automatically adjusts when breaking across pages.
  /// -> auto | length | dictionary
  radius: auto,
  /// The padding between the highlighted text and the border. Using `"text"` aligns to font metrics.
  /// -> auto | length | str
  padding: auto,
  /// Shape drawing function.
  ///
  /// ```example
  /// *Kepler’s First Law of Planetary Motion* states that every planet’s orbit is an ellipse:
  /// #align(
  ///   center,
  ///   deixis-region-mark(padding: (x: 8pt, y: 8pt), region-shape: deixis-ellipse-region)[$r = frac(1 - e^2, 1 + e cos(theta))$]
  /// )
  /// ```
  ///
  /// -> auto | function
  region-shape: auto,
  /// The rendering layer context. Choices: `"flow"` | `"foreground"` | `"background"`.
  /// - With `"foreground"` layer, the region is rendered in the foreground of the page, and may occlude the highlighted content.
  /// - With `"background"` layer, the region will be rendered in the background of the page, and might be occluded by other contents.
  /// ```example
  /// // pins already placed in manual.typ
  /// This example draws the #box(width: 0.6em, height: 0.6em, stroke: yellow) yellow region around this documentation chapter.
  /// #deixis-region-mark(
  ///   pins: ("region-mark-chapter-start", "region-mark-chapter-end"),
  ///   padding: (x: 5pt, top: -5pt, bottom: 5pt),
  ///   stroke: yellow + 2pt,
  ///   fill: yellow.transparentize(98%),
  ///   radius: 10pt,
  ///   layer: "background",
  /// )
  /// ```
  /// - With `"flow"` layer, the placement of the region is synchronuous.
  /// ```example
  /// #deixis-region-mark(
  ///   pins: ("test-layer3", "test-layer4"),
  ///   stroke: none,
  ///   fill: purple.transparentize(25%),
  ///   layer: "flow",
  /// )  // below the highlighted text
  ///
  /// #quote(attribution: [Messmer the Impaler], block: true)[*#deixis-pin("test-layer1")Mongrel#deixis-pin("test-layer2") #deixis-pin("test-layer3")intruder#deixis-pin("test-layer4").*]
  ///
  /// #deixis-region-mark(
  ///   pins: ("test-layer1", "test-layer2"),
  ///   stroke: none,
  ///   fill: red.transparentize(25%),
  ///   layer: "flow",
  /// )  // above the highlighted text
  /// ```
  ///
  /// ```tip
  /// - Use `"flow"` for highlighting images, diagrams, ...
  ///   Be aware that it will trigger a `#parbreak`.
  ///
  /// - Use `"background"` for highlighting texts, equations, ... _if they are not in a non-transparent container_.
  ///
  /// - Use `"foreground"` or `"background"` where the region can span across multiple pages.
  /// ```
  ///
  /// -> auto | str
  layer: auto,
  /// If `true`, the region wraps the text in an inline `box` instead of a standard `block`.
  /// -> bool
  inline: false,
) = {
  let named = args.named()
  if named.len() > 0 {
    panic(
      "deixis: Unknown named argument(s) "
        + repr(named.keys())
        + ". Styling arguments are not allowed in mark-only note functions.",
    )
  }

  let styles = (stroke: stroke, fill: fill, radius: radius)

  let pos = args.pos()
  if pos.len() > 1 { panic("#deixis-region-mark accepts at most 1 positional argument [body].") }

  let body = if pos.len() == 1 { deixis-utils._deixis-trim-content(pos.first()) } else { none }
  let has-body = body != none
  let has-pins = type(pins) == array and pins.len() > 0

  if has-pins == has-body {
    panic("#deixis-region-mark requires either 'pins' or a positional body, but not both.")
  }

  let padding = if padding == auto {
    if inline and has-body { "text" } else { 0pt }
  } else { padding }

  if id == none {
    return [
      #std.counter("deixis-anon-region").step()
      #context {
        let sys = deixis-system.get()
        let m-styles = _deixis-resolve-mark-styles(
          sys,
          "region-mark",
          marker-position: marker-position,
          stroke: stroke,
          fill: fill,
          radius: radius,
        )
        let c-shape = _deixis-resolve-typed-param(sys, region-shape, "region-shape", "region-mark")
        let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "region-mark", component: "mark")

        let c-pins = pins
        let rendered-body = none
        let c-padding = if padding == "text" { text-padding } else { padding }

        if has-body {
          let internal-id = std.counter("deixis-anon-region").get().first()
          let auto-prefix = "deixis-reg-anon-" + str(internal-id)

          let pin-tl = auto-prefix + "-tl"
          let pin-br = auto-prefix + "-br"
          c-pins = (pin-tl, pin-br)

          if inline {
            rendered-body = [#deixis-pin(pin-tl, padding: padding)#body#deixis-pin(pin-br, padding: padding)]
          } else {
            let attach-pins = (:)
            attach-pins.insert(pin-tl, (
              dx: 0%,
              dy: 0%,
              padding: if padding == "text" {
                (top: text-padding.top - measure([T]).height, bottom: text-padding.bottom, x: text-padding.x)
              } else { padding },
            ))
            attach-pins.insert(pin-br, (
              dx: 100%,
              dy: 100%,
              padding: if padding == "text" { text-padding } else { padding },
            ))

            rendered-body = deixis-attach(body, pins: attach-pins)
          }
          c-padding = 0pt
        }

        let is-multipage = false
        let all-pins = query(<deixis-pin>)
        let active-pins = ()
        for pin-name in c-pins {
          for m in all-pins.filter(p => p.value.name == pin-name) { active-pins.push(m) }
        }

        if active-pins.len() > 0 {
          let sorted = active-pins.sorted(key: p => p.location().page())
          if sorted.first().location().page() != sorted.last().location().page() {
            is-multipage = true
          }
        }

        if c-layer == "flow" and is-multipage {
          panic(
            "deixis: cannot render multi-page region with 'flow' layer, please switch to asynchronuous layers: 'foreground' or 'background'.",
          )
        }

        let meta-payload = (
          internal-id: none,
          mark-lbl: none,
          body-lbl: none,
          marker-str: none,
          marker-style: auto,
          pins: c-pins,
          shape-func: c-shape,
          layer: c-layer,
          styles: m-styles + (padding: c-padding),
        )

        let rendered-region = none
        if c-layer == "flow" {
          let drawing-context = context {
            let all-pins = query(<deixis-pin>)
            _deixis-render-region-shape(
              deixis-system.get(),
              meta-payload,
              all-pins,
              here().page(),
              base-pos: here().position(),
            )
          }
          if inline {
            rendered-region = box(width: 0pt, height: 0pt, drawing-context)
          } else {
            rendered-region = place(drawing-context)
          }
        }

        let mark-body = if inline {
          [#rendered-region#rendered-body]
        } else {
          [#rendered-body#rendered-region]
        }
        [#mark-body#metadata(meta-payload)<deixis-region-mark>]
      }
    ]
  }

  _deixis-validate-target(target)

  deixis-system.update(sys => {
    if id != none and str(id) in sys.at("id-index", default: (:)) { return sys }

    let new-note-uid = sys.at("note-uid", default: 0) + 1
    let uid-str = str(new-note-uid)

    let resolved = _deixis-resolve-target(sys, target)
    let full-c-id = resolved.count-id + ":" + series

    let new-counters = sys.counters
    let current-count = new-counters.at(full-c-id, default: 0) + 1
    new-counters.insert(full-c-id, current-count)

    let new-blocks = sys.blocks
    if resolved.render-id != "page" and type(target) in (str, label) and str(target) not in new-blocks {
      new-blocks.insert(str(target), (
        render-id: resolved.render-id,
        count-id: resolved.count-id,
        inst-id: resolved.inst-id,
      ))
    }

    let c-numbering = _deixis-resolve-typed-param(sys, numbering, "numbering", "region-mark")
    let m-styles = _deixis-resolve-mark-styles(sys, "region-mark", marker-position: marker-position)

    let payload = (
      internal-id: new-note-uid,
      target-id: resolved.render-id,
      inst-id: resolved.inst-id,
      series: series,
      count: current-count,
      numbering: c-numbering,
      marker: marker,
      mark-type: "region",
      marker-style: marker-style,
      marker-position: m-styles.marker-position,
      styles: styles,
      has-mark-body: has-body,
    )

    let new-notes = sys.at("notes", default: (:))
    let new-id-index = sys.at("id-index", default: (:))

    new-notes.insert(uid-str, payload)

    if id == deixis-auto-id {
      sys.insert("last-auto-uid", uid-str)
    } else if id != none {
      let id-str = str(id)
      if id-str in new-id-index and not id-str.starts-with("deixis-auto-") {
        panic("deixis: Duplicate note ID detected: '" + id-str + "'.\nNote IDs must be unique across the document.")
      }
      new-id-index.insert(id-str, uid-str)
    }

    return (
      ..sys,
      note-uid: new-note-uid,
      blocks: new-blocks,
      counters: new-counters,
      notes: new-notes,
      id-index: new-id-index,
    )
  })

  context {
    let sys = deixis-system.get()

    let target-uid = if id == deixis-auto-id { sys.at("last-auto-uid", default: none) } else if id != none {
      sys.id-index.at(str(id), default: none)
    } else { none }
    let reg = if target-uid != none { sys.notes.at(target-uid, default: none) } else { none }

    let saved-styles = if reg != none { reg.at("styles", default: (:)) } else { styles }
    let c-styles = _deixis-merge-styles(saved-styles, styles, allowed-keys: ("stroke", "fill", "radius"))

    let m-styles = _deixis-resolve-mark-styles(
      sys,
      "region-mark",
      marker-position: marker-position,
      ..c-styles,
    )

    let c-shape = _deixis-resolve-typed-param(sys, region-shape, "region-shape", "region-mark")
    let c-layer = _deixis-resolve-typed-param(sys, layer, "layer", "region-mark", component: "mark")

    let c-pins = pins
    let rendered-body = none
    let c-padding = if padding == "text" { text-padding } else { padding }

    let internal-id = if reg != none { reg.internal-id } else { "temp-pass-1" }

    if has-body {
      let auto-prefix = "deixis-reg-" + str(internal-id)
      let pin-tl = auto-prefix + "-tl"
      let pin-br = auto-prefix + "-br"
      c-pins = (pin-tl, pin-br)

      if inline {
        rendered-body = [#deixis-pin(pin-tl, padding: padding)#body#deixis-pin(pin-br, padding: padding)]
      } else {
        let attach-pins = (:)
        attach-pins.insert(pin-tl, (
          dx: 0%,
          dy: 0%,
          padding: if padding == "text" {
            (top: text-padding.top - measure([T]).height, bottom: text-padding.bottom, x: text-padding.x)
          } else { padding },
        ))
        attach-pins.insert(pin-br, (
          dx: 100%,
          dy: 100%,
          padding: if padding == "text" { text-padding } else { padding },
        ))

        rendered-body = deixis-attach(body, pins: attach-pins)
      }
      c-padding = 0pt
    }

    let is-multipage = false
    let all-pins = query(<deixis-pin>)
    let active-pins = ()
    for pin-name in c-pins {
      for m in all-pins.filter(p => p.value.name == pin-name) { active-pins.push(m) }
    }

    if active-pins.len() > 0 {
      let sorted = active-pins.sorted(key: p => p.location().page())
      if sorted.first().location().page() != sorted.last().location().page() {
        is-multipage = true
      }
    }

    if c-layer == "flow" and is-multipage {
      panic(
        "deixis: cannot render multi-page region with 'flow' layer, please switch to asynchronuous layers: 'foreground' or 'background'.",
      )
    }

    if reg == none {
      let meta-payload = (
        internal-id: none,
        mark-lbl: none,
        body-lbl: none,
        marker-str: none,
        marker-style: auto,
        pins: c-pins,
        shape-func: c-shape,
        layer: c-layer,
        styles: m-styles + (padding: c-padding),
      )
      return [#rendered-body#metadata(meta-payload)<deixis-region-mark>#anchor]
    }

    let count = reg.count
    let c-numbering = reg.at("numbering", default: "1")
    let c-marker = reg.at("marker", default: auto)

    let marker-str = if c-marker != auto {
      c-marker
    } else if c-numbering != none {
      std.numbering(c-numbering, count)
    } else {
      none
    }

    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let body-lbl = std.label("deixis-body-" + str(internal-id))

    let mark-marker-style = _deixis-resolve-typed-param(
      sys,
      marker-style,
      "marker-style",
      "region-mark",
      component: "mark",
    )

    let meta-payload = (
      internal-id: internal-id,
      mark-lbl: mark-lbl,
      body-lbl: body-lbl,
      marker-str: marker-str,
      marker-style: mark-marker-style,
      pins: c-pins,
      shape-func: c-shape,
      layer: c-layer,
      styles: m-styles + (padding: c-padding),
    )

    let rendered-region = none
    if c-layer == "flow" {
      let drawing-context = context {
        let all-pins = query(<deixis-pin>)
        _deixis-render-region-shape(
          deixis-system.get(),
          meta-payload,
          all-pins,
          here().page(),
          base-pos: here().position(),
        )
      }
      if inline {
        rendered-region = box(width: 0pt, height: 0pt, drawing-context)
      } else {
        rendered-region = place(drawing-context)
      }
    }

    let mark-body = if inline {
      [#rendered-region#rendered-body]
    } else {
      [#rendered-body#rendered-region]
    }
    [#mark-body#metadata(meta-payload)<deixis-region-mark>]
  }
}

#let _deixis-region-marks-overlay(layer: "foreground") = context {
  let regions = query(<deixis-region-mark>).map(x => x.value)
  let all-pins = query(<deixis-pin>)
  let current-page = here().page()
  let sys = deixis-system.get()

  for reg in regions {
    let note-layer = reg.at("layer", default: "foreground")

    if note-layer == "flow" { continue }

    let draw-shape = note-layer == layer
    let draw-marker = layer == "foreground"

    if not draw-shape and not draw-marker { continue }

    _deixis-render-region-shape(
      sys,
      reg,
      all-pins,
      current-page,
      base-pos: none,
      draw-shape: draw-shape,
      draw-marker: draw-marker,
    )
  }
}
