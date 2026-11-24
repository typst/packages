#import "../core/internal.typ": *
#import "../render/commands.typ": _deixis-paint-command
#import "region-paint.typ": *
#import "repeat.typ": _deixis-repeat-mark
#import "../core/native.typ": *

/// A visual enclose mark of a specific region in the document.
///
/// Region marks are highly versatile. They can dynamically wrap a continuous block of text provided as a
/// positional argument, or they can asynchronously draw a shape spanning between pre-defined `#deixis-pin` coordinates.
/// They support crossing page boundaries with background/foreground layers,
/// including automatic corner pins around breakable block content.
/// With `of: id`, it creates another region occurrence of an existing annotation.
/// Its own pins/content determine geometry; the original still owns the number,
/// body placement, and implicit connector. Name it with `occurrence` for an
/// explicit connection, including automatic page-fragment selection.
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
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - pins (array): Pin names or `(name:, scope:, select:, page:)` targets. Strings combine all occurrences; records default to a unique match. Cannot be used simultaneously with a positional body.
/// - numbering (auto, none, str, function, dictionary): The numbering style for the region's marker.
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
  /// Custom annotation fields, owned by the original. Omit with of.
  /// -> dictionary
  data: (:),
  /// Reuse an annotation with new region geometry, without a new number/body.
  /// -> none | str | label
  of: none,
  /// Optional occurrence name, scoped to the reused annotation.
  /// -> none | str | label
  occurrence: none,
  /// Pin names or structured targets, e.g. `((name: "corner", scope: "diagram"),)`.
  /// Strings combine all occurrences. Records require a match and default to
  /// unique selection; select can be all, first, last, or unique, and page can
  /// restrict to a positive physical page number. Cannot also wrap a body.
  ///
  /// See `deixis-pin` and `deixis-attach`.
  ///
  /// -> array
  pins: (),
  /// The numbering style for the region's marker.
  /// A record `(restart: "page", pattern: "1")` restarts displayed markers per original page; assigned counters stay unchanged.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
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
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
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
  let render-with-order-hints() = {
    _deixis-check-note-data(data, of: of)
    let named = args.named()
    // Private: the note wrapper that created this mark (numbering family).
    let family = named.remove("_family", default: none)
    if named.len() > 0 {
      panic(
        "deixis: Unknown named argument(s) "
          + repr(named.keys())
          + ". Use id to declare an annotation or of to reuse it.",
      )
    }

    let styles = (stroke: stroke, fill: fill, radius: radius)

    let pos = args.pos()
    if pos.len() > 1 { panic("#deixis-region-mark accepts at most 1 positional argument [body].") }

    let body = if pos.len() == 1 { deixis-utils._deixis-trim-content(pos.first()) } else { none }
    if of != none {
      _deixis-check-identities(id, of)
      assert(numbering == auto and target == 0 and series == "default",
        message: "deixis: Reused region marks inherit numbering, scope target, and series. Configure those on the original declaration.")
      return _deixis-repeat-mark(of: of, mark-type: "region", occurrence: occurrence,
        pins: pins, marker: marker, marker-style: marker-style, marker-position: marker-position,
        stroke: stroke, fill: fill, radius: radius, z-index: z-index, padding: padding,
        region-shape: region-shape, layer: layer, inline: inline, ..if body == none { () } else { (body,) })
    }
    assert(occurrence == none, message: "deixis: occurrence requires of on a region mark.")
    let has-body = body != none
    let has-pins = type(pins) == array and pins.len() > 0

    if has-pins == has-body {
      panic("#deixis-region-mark requires either 'pins' or a positional body, but not both.")
    }

    let padding = if padding == auto {
      if inline and has-body { "text" } else { 0pt }
    } else { padding }

    if id == none {
      // Name corner pins from this stable call-site location. The palette
      // output's location hashes its settings payload and settles later.
      return context { let prefix = here(); _deixis-palette-anonymous(deixis-system.get(), sys => {
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

        let prepared = _deixis-region-content(body, pins, padding, inline, prefix)

        let meta-payload = (
          render-context: _deixis-render-context(),
          internal-id: none,
          accent: sys.at("annotation-accent", default: none),
          id: none,
          data: data,
          target-id: _deixis-resolve-target(sys, target).render-id,
          series: series,
          body: body,
          mark-lbl: none,
          body-lbl: none,
          marker-str: none,
          marker-style: auto,
          pins: prepared.pins,
          shape-func: c-shape,
          layer: c-layer,
          z-index: _deixis-resolve-z-index(sys, z-index, "region-mark", "mark"),
          styles: m-styles + (padding: prepared.padding),
        )

        let rendered-region = none
        if c-layer == "flow" and _std-target() != "html" {
          let drawing-context = context {
            let pin-index = _deixis-pin-index()
            _deixis-render-region-shape(
              deixis-system.get(),
              meta-payload,
              pin-index,
              here().page(),
              base-pos: here().position(),
            )
          }
          rendered-region = _deixis-immediate-region(drawing-context, inline)
        }

        let mark-body = if inline {
          [#rendered-region#prepared.body]
        } else {
          [#prepared.body#rendered-region]
        }
        [#mark-body#_deixis-metadata(meta-payload, <deixis-region-mark>)]
      }) }
    }

    _deixis-validate-target(target)

    _deixis-declaration(id, {
      _deixis-with-target-scopes(target, scopes => {
        deixis-system.update(sys => {
          let sys = _deixis-palette-next(sys)
          let resolved = _deixis-resolve-target(sys, target, scopes: scopes)
          let m-styles = _deixis-resolve-mark-styles(sys, "region-mark", marker-position: marker-position, ..styles)
          let payload = (
            numbering: _deixis-resolve-typed-param(sys, numbering, "numbering", "region-mark", family: family),
            data: data, marker: marker, mark-type: "region",
            marker-style: _deixis-resolve-typed-param(sys, marker-style, "marker-style", "region-mark", component: "mark"),
            marker-position: m-styles.marker-position, styles: styles, mark-styles: m-styles,
            z-index: z-index, mark-z-index: _deixis-resolve-z-index(sys, z-index, "region-mark", "mark"), has-mark-body: has-body,
            region-shape: _deixis-resolve-typed-param(sys, region-shape, "region-shape", "region-mark"),
            layer: _deixis-resolve-typed-param(sys, layer, "layer", "region-mark", component: "mark"),
            padding: padding,
          )
          _deixis-register-mark(sys, id, resolved, series, payload)
        })
      })
    }, passage: body)

    context {
      let sys = deixis-system.get()

      let reg = _deixis-resolve-note(deixis-system.final(), id)

      let saved-styles = if reg != none { reg.at("styles", default: (:)) } else { styles }
      let c-styles = _deixis-merge-styles(saved-styles, styles, allowed-keys: ("stroke", "fill", "radius"))

      let m-styles = if reg != none { reg.mark-styles } else {
        _deixis-resolve-mark-styles(
          sys,
          "region-mark",
          marker-position: marker-position,
          ..c-styles,
        )
      }

      let c-shape = if reg != none { reg.region-shape } else {
        _deixis-resolve-typed-param(sys, region-shape, "region-shape", "region-mark")
      }
      let c-layer = if reg != none { reg.layer } else {
        _deixis-resolve-typed-param(sys, layer, "layer", "region-mark", component: "mark")
      }
      let c-z-index = if reg != none { reg.mark-z-index } else {
        _deixis-resolve-z-index(sys, z-index, "region-mark", "mark")
      }

      let internal-id = if reg != none { reg.internal-id } else { "temp-pass-1" }
      let prepared = _deixis-region-content(body, pins, padding, inline, "deixis-reg-" + str(internal-id))

      if reg == none {
        let meta-payload = (
          render-context: _deixis-render-context(),
          internal-id: none,
          accent: sys.at("annotation-accent", default: none),
          id: none,
          data: data,
          mark-lbl: none,
          body-lbl: none,
          marker-str: none,
          marker-style: auto,
          pins: prepared.pins,
          shape-func: c-shape,
          layer: c-layer,
          z-index: c-z-index,
          styles: m-styles + (padding: prepared.padding),
        )
        return [#prepared.body#_deixis-metadata(meta-payload, <deixis-region-mark>)]
      }

      let count = reg.count
      let marker-str = _deixis-evaluate-marker-str(reg)

      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let body-lbl = _std-label("deixis-body-" + str(internal-id))

      let mark-marker-style = if reg != none { reg.marker-style } else {
        _deixis-resolve-typed-param(
          sys,
          marker-style,
          "marker-style",
          "region-mark",
          component: "mark",
        )
      }

      let meta-payload = (
        render-context: _deixis-render-context(),
        internal-id: internal-id,
        accent: reg.at("accent", default: none),
        id: reg.id,
        data: reg.at("data", default: (:)),
        target-id: reg.target-id,
        inst-id: reg.inst-id,
        series: reg.series,
        count: reg.count,
        body: body,
        mark-lbl: mark-lbl,
        body-lbl: body-lbl,
        marker-str: marker-str,
        marker-style: mark-marker-style,
        pins: prepared.pins,
        shape-func: c-shape,
        layer: c-layer,
        z-index: c-z-index,
        styles: m-styles + (padding: prepared.padding),
      )

      if _std-target() == "html" {
        return [#prepared.body#_deixis-html-region-marker(sys, meta-payload)#_deixis-metadata(meta-payload, <deixis-region-mark>)]
      }
      let rendered-region = none
      if c-layer == "flow" {
        let drawing-context = context {
          let pin-index = _deixis-pin-index()
          _deixis-render-region-shape(
            deixis-system.get(),
            meta-payload,
            pin-index,
            here().page(),
            base-pos: here().position(),
          )
        }
        rendered-region = _deixis-immediate-region(drawing-context, inline)
      }

      let mark-body = if inline {
        [#rendered-region#prepared.body]
      } else {
        [#prepared.body#rendered-region]
      }
      [#mark-body#_deixis-metadata(meta-payload, <deixis-region-mark>)]
    }
  }
  _deixis-replayable(args.pos().at(0, default: none), [#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: series)
}

#let _deixis-region-paint-commands(layer: "foreground") = {
  let regions = query(selector(<deixis-region-mark>).or(<deixis-region-occurrence>))
  let pin-index = _deixis-pin-index()
  let current-page = here().page()
  let sys = deixis-system.get()
  let commands = ()

  for element in regions {
    let reg = element.value
    let note-layer = reg.at("layer", default: "foreground")

    if note-layer == "flow" { continue }

    let draw-shape = note-layer == layer
    let draw-marker = layer == "foreground"

    if not draw-shape and not draw-marker { continue }

    commands.push(_deixis-paint-command("region", element.location(), () =>
      _deixis-render-region-shape(sys, reg, pin-index, current-page,
        base-pos: none, draw-shape: draw-shape, draw-marker: draw-marker),
      priority: reg.at("z-index", default: 0)))
  }
  commands
}
