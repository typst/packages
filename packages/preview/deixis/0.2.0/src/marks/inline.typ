#import "../core/internal.typ": *
#import "../core/native.typ": *
#import "../core/html.typ": _deixis-html-anchor

#import "inline-paint.typ": *
#import "repeat.typ": _deixis-repeat-mark

/// An inline text mark with a visual marker.
///
/// This function drops a numbered (or custom) marker into the text and registers its location in the
/// annotation catalogue.
/// With `of: id`, it reuses an annotation through `deixis-mark` instead;
/// only a numbered original `id` declaration advances the counter. Reuse is forward-safe.
///
/// ```example
/// Inline note is usually just a single marker#deixis-inline-mark(id: <celibate-inline-note1>).
/// Alternatively, it can wrap #deixis-inline-mark(id: <celibate-inline-note2>)[a text content of arbitrary length with it].
/// ```
///
/// - ..args (arguments): Accepts up to one positional arguments: `[body]`.
/// - numbering (auto, none, str, function, dictionary): The numbering style (e.g., `"1"`, `"a"`) for the generated marker.
/// - marker (auto, content): A hardcoded marker (like a symbol) to use instead of the automatic counter.
/// - target (int, label, str): The specific block/minipage counter context this mark belongs to.
/// - series (str): The counter series this mark belongs to. Defaults to `"default"`.
/// - id (none, str, label): A unique identifier linking this mark to its corresponding body.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - marker-style (auto, function): A custom styling function `(string) => content` for the generated marker.
/// - marker-position (auto, alignment): The alignment/positioning of the marker relative to its anchor.
/// - inline-mode (auto, str): The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
/// - stroke (auto, stroke, none): The border stroke.
/// - fill (auto, color, none): The background fill color.
/// - radius (auto, length, dictionary): The border radius.
///
/// -> content
#let deixis-inline-mark(
  /// Accepts up to one positional arguments: `[body]`.
  /// -> arguments
  ..args,
  /// The numbering style (e.g., `"1"`, `"a"`) for the generated marker.
  /// A record `(restart: "page", pattern: "1")` restarts displayed markers per original page; assigned counters stay unchanged.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
  numbering: auto,
  /// A hardcoded marker (like a symbol) to use instead of the automatic counter.
  /// -> auto | content
  marker: auto,
  /// The specific block/minipage counter context this mark belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this mark belongs to.
  /// -> str
  series: "default",
  /// A unique identifier linking this mark to its corresponding body.
  /// -> none | str | label
  id: none,
  /// Custom annotation fields, owned by the original. Omit with of.
  /// -> dictionary
  data: (:),
  /// Reuse an existing annotation instead of declaring a new counter owner.
  /// Mutually exclusive with id; numbering/scope/series are inherited.
  /// -> none | str | label
  of: none,
  /// Optional name for a reused occurrence. Visible named repeats use one inline box.
  /// -> none | str | label
  occurrence: none,
  /// A custom styling function `(string) => content` for the generated marker.
  /// -> auto | function
  marker-style: auto,
  /// The alignment/positioning of the marker relative to its anchor.
  ///
  /// ```example
  /// #deixis-inline-mark(marker-position: left, id: <celibate-inline-note3>)[
  ///   This noted content has its mark placed on the left side.
  /// ]
  /// ```
  ///
  /// -> auto | alignment
  marker-position: auto,
  /// The visual decoration applied to the marked inline text. Choices: `"highlight"` | `"box"` | `"parentheses"` | `"underline"` | `"text-fill"` | `"none"`.
  ///
  /// ```example
  /// #deixis-inline-mark(inline-mode: "highlight")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "box")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "parentheses")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "underline")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "text-fill")[Marked content]
  /// ```
  /// ```example
  /// #deixis-inline-mark(inline-mode: "none")[Marked content]
  /// ```
  ///
  /// -> auto | str
  inline-mode: auto,
  /// The border stroke.
  /// -> auto | stroke | none
  stroke: auto,
  /// The background fill color.
  /// -> auto | color | none
  fill: auto,
  /// The border radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
) = {
  let render-with-order-hints() = {
    _deixis-check-note-data(data, of: of)
    let named = args.named()
    // Private: the note wrapper that created this mark (numbering family).
    let family = named.remove("_family", default: none)
    if named.len() > 0 {
      panic(
        "deixis: Unknown inline mark option(s) "
          + repr(named.keys())
          + ". Use id to declare an annotation or of to reuse it.",
      )
    }

    let styles = (stroke: stroke, fill: fill, radius: radius)

    let pos = args.pos()
    if pos.len() > 1 { panic("#deixis-inline-mark accepts at most 1 positional argument [body].") }
    let body = if pos.len() == 1 { deixis-utils._deixis-trim-content(pos.first()) } else { none }

    if of != none {
      _deixis-check-identities(id, of)
      assert(numbering == auto and target == 0 and series == "default",
        message: "deixis: Reused inline marks inherit numbering, scope target, and series. Configure those on the original declaration.")
      return _deixis-repeat-mark(of: of, occurrence: occurrence, marker: marker,
        marker-style: marker-style, marker-position: marker-position,
        inline-mode: inline-mode, stroke: stroke, fill: fill, radius: radius, z-index: z-index, body)
    }
    assert(occurrence == none, message: "deixis: occurrence requires of on an inline mark.")

    if id == none {
      return context _deixis-palette-anonymous(deixis-system.get(), sys => {
        let m-styles = _deixis-resolve-mark-styles(
          sys,
          "inline-mark",
          marker-position: marker-position,
          inline-mode: inline-mode,
          stroke: stroke,
          fill: fill,
          radius: radius,
        )

        let visual-mark = _deixis-inline-mark(
          body,
          marker-position: m-styles.marker-position,
          inline-mode: m-styles.inline-mode,
          fill: m-styles.fill,
          stroke: m-styles.stroke,
          radius: m-styles.radius,
        )

        let meta-payload = (
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
          marker-width: 0pt,
          text-size: text.size,
          styles: m-styles,
          z-index: _deixis-resolve-z-index(sys, z-index, "inline-mark", "mark"),
        )

        [#visual-mark#_deixis-metadata(meta-payload, <deixis-inline-mark>)]
      })
    }

    _deixis-validate-target(target)

    _deixis-declaration(id, {
      _deixis-with-target-scopes(target, scopes => {
        deixis-system.update(sys => {
          let sys = _deixis-palette-next(sys)
          let resolved = _deixis-resolve-target(sys, target, scopes: scopes)
          let m-styles = _deixis-resolve-mark-styles(sys, "inline-mark", marker-position: marker-position,
            inline-mode: inline-mode, ..styles)
          let payload = (
            numbering: _deixis-resolve-typed-param(sys, numbering, "numbering", "inline-mark", family: family),
            data: data, marker: marker, mark-type: "inline",
            marker-style: _deixis-resolve-typed-param(sys, marker-style, "marker-style", "inline-mark", component: "mark"),
            marker-position: m-styles.marker-position, inline-mode: m-styles.inline-mode,
            styles: styles, mark-styles: m-styles,
            z-index: z-index, mark-z-index: _deixis-resolve-z-index(sys, z-index, "inline-mark", "mark"), has-mark-body: body != none,
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
          "inline-mark",
          marker-position: marker-position,
          inline-mode: inline-mode,
          ..c-styles,
        )
      }

      if reg == none {
        return _deixis-inline-mark(
          body,
          marker-position: m-styles.marker-position,
          inline-mode: m-styles.inline-mode,
          fill: m-styles.fill,
          stroke: m-styles.stroke,
          radius: m-styles.radius,
        )
      }

      let internal-id = reg.internal-id
      let count = reg.count
      let marker-str = _deixis-evaluate-marker-str(reg)

      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let body-lbl = _std-label("deixis-body-" + str(internal-id))

      let mark-marker-style = if reg != none { reg.marker-style } else {
        _deixis-resolve-typed-param(
          sys,
          marker-style,
          "marker-style",
          "inline-mark",
          component: "mark",
        )
      }

      let visual-mark = _deixis-inline-mark(
        body,
        marker-style: mark-marker-style,
        marker-position: m-styles.marker-position,
        inline-mode: m-styles.inline-mode,
        fill: m-styles.fill,
        stroke: m-styles.stroke,
        radius: m-styles.radius,
        marker-str: marker-str,
        mark-lbl: mark-lbl,
        body-lbl: body-lbl,
      )

      let meta-payload = (
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
        has-inline-box: m-styles.inline-mode == "box" and body != none,
        marker-width: if marker-str != none { measure(mark-marker-style(marker-str)).width } else { 0pt },
        text-size: text.size,
        styles: m-styles,
      )

      [#visual-mark#_deixis-metadata(meta-payload, <deixis-inline-mark>)]
    }
  }
  _deixis-replayable(args.pos().at(0, default: none), [#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: series)
}

/// A semantic mark that is registered without leaving _any_ visible trace in the text.
///
/// Numbered phantom marks increment the counter (`numbering: none` does not)
/// and register a reference destination, but leave
/// no visual footprint in the paragraph.
/// This is useful for creating semantic anchors or side-channel annotations that shouldn't disrupt the reading flow.
/// With `of: id`, it reuses an annotation without advancing the counter. A named
/// phantom occurrence supplies a point endpoint for an explicit connection.
///
/// ```example
/// //| sandbox-mode: "page"
/// The library was constructed with massive stone walls to regulate the indoor climate naturally across the changing seasons.
/// #deixis-phantom-mark(id: <phantom>, marker: none)
/// This architectural choice ensured that centuries of fragile manuscripts remained perfectly preserved without the need for artificial climate control.
///
/// #deixis-margin-note-body(of: <phantom>)[Thick stone absorbs daytime heat and releases it at night.]
/// ```
///
/// - id (none, str, label): A unique identifier for linking this mark to a decoupled body.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - numbering (auto, none, str, function, dictionary): The numbering style (used for the body and outline, though invisible here).
/// - target (int, label, str): The specific block/minipage counter context this mark belongs to.
/// - series (str): The counter series this mark belongs to. Defaults to `"default"`.
/// - marker (auto, content): A hardcoded marker override (used for the body and outline, though invisible here).
/// - ..args (arguments): Accepts no public arguments; a phantom mark has no body.
///
/// -> content
#let deixis-phantom-mark(
  /// Ordering defaults for future attached overlay bodies; this mark is invisible.
  /// -> auto | int | dictionary
  z-index: auto,
  /// A unique identifier for linking this mark to a decoupled body.
  /// -> none | str | label
  id: none,
  /// Custom annotation fields, owned by the original. Omit with of.
  /// -> dictionary
  data: (:),
  /// Reuse an annotation as an invisible semantic anchor.
  /// -> none | str | label
  of: none,
  /// Optional occurrence name for explicit connection selection.
  /// -> none | str | label
  occurrence: none,
  /// The numbering style (used for the body and outline, though invisible here).
  /// Supports `(restart: "page", pattern: "1")` for page-local display numbering.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
  numbering: auto,
  /// The specific block/minipage counter context this mark belongs to.
  /// -> int | label | str
  target: 0,
  /// The counter series this mark belongs to.
  /// -> str
  series: "default",
  /// A hardcoded marker override (used for the body and outline, though invisible here).
  /// -> auto | content
  marker: auto,
  ..args,
) = {
  let render-with-order-hints() = {
    let named = args.named()
    // Private: the note wrapper that created this mark (numbering family).
    let family = named.remove("_family", default: none)
    assert(args.pos().len() == 0 and named.len() == 0,
      message: "deixis: Unknown phantom mark argument(s) " + repr(named.keys()) + "; a phantom mark has no body.")
    _deixis-check-note-data(data, of: of)
    assert(id != none or of != none or data.len() == 0,
      message: "deixis: Phantom annotation data requires an original id.")
    if of != none {
      _deixis-check-identities(id, of)
      assert(numbering == auto and target == 0 and series == "default" and marker == auto,
        message: "deixis: Reused phantom marks inherit numbering, scope target, series, and marker. Configure those on the original declaration.")
      return _deixis-repeat-mark(of: of, mark-type: "phantom", occurrence: occurrence, z-index: z-index)
    }
    assert(occurrence == none, message: "deixis: occurrence requires of on a phantom mark.")
    if id == none {
      return
    }

    _deixis-validate-target(target)

    _deixis-declaration(id, {
      _deixis-with-target-scopes(target, scopes => {
        deixis-system.update(sys => {
          let sys = _deixis-palette-next(sys)
          _deixis-register-mark(sys, id, _deixis-resolve-target(sys, target, scopes: scopes), series, (
            numbering: _deixis-resolve-typed-param(sys, numbering, "numbering", "phantom-mark", family: family),
            data: data, marker: marker, mark-type: "phantom",
            marker-style: _deixis-resolve-typed-param(sys, auto, "marker-style", "phantom-mark", component: "mark"),
            styles: (:), has-mark-body: false,
            z-index: z-index, mark-z-index: _deixis-resolve-z-index(sys, z-index, "phantom-mark", "mark"),
          ))
        })
      })
    })

    context _deixis-setup-guard()
    context {
      let sys = deixis-system.get()

      let reg = _deixis-resolve-note(deixis-system.final(), id)
      if reg == none { return none }

      let internal-id = str(reg.internal-id)

      let mark-lbl = _std-label("deixis-mark-" + internal-id)
      let body-lbl = _std-label("deixis-body-" + internal-id)

      let meta-payload = (
        internal-id: internal-id,
        accent: reg.at("accent", default: none),
        id: reg.id,
        data: reg.at("data", default: (:)),
        target-id: reg.target-id,
        inst-id: reg.inst-id,
        series: reg.series,
        count: reg.count,
        mark-lbl: mark-lbl,
        body-lbl: body-lbl,
        marker-str: none,
        marker-width: 0pt,
        text-size: text.size,
        styles: (:),
      )

      [#_deixis-metadata(meta-payload, <deixis-phantom-mark>)#metadata((internal-id: internal-id))<deixis-mark-destination>#metadata(none)#mark-lbl#_deixis-html-anchor(mark-lbl)]
    }
  }
  _deixis-replayable(none, [#_deixis-order-hints(z-index)#render-with-order-hints()], id: id, of: of, series: series)
}
