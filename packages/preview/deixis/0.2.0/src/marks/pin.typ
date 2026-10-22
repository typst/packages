#import "../core/internal.typ": *
#import "../core/pins.typ": *
#import "../routing/attached.typ": _deixis-attached-corners

// Internal callers already have the declaration context. Metadata itself gets
// its native location without another deferred context per corner.
#let _deixis-pin(name, scope: none, padding: "text", extra-data: (:)) = {
  let actual-padding = if padding == "text" {
    text-padding
  } else {
    padding
  }

  let abs-pad = deixis-utils.resolve-padding(actual-padding)

  let record = _deixis-metadata(extra-data + (
    name: name,
    scope: scope,
    padding: abs-pad,
  ), <deixis-pin>)
  // HTML export has no geometry; the record still marks the source position.
  if _std-target() == "html" { record } else { box[#record] }
}

/// Manually drops an invisible, named geometric anchor (a `"pin"`) into the document flow.
///
/// Pins are the coordinate anchors that ```ref #deixis-region-mark``` uses to draw its highlights.
/// Initialize with `deixis-setup-notes` before producing document pins.
/// They can also be used as anchor coordinates for ```ref #deixis-inset-note-body``` and ```ref #deixis-margin-note-body```.
///
/// - name (str, label): A pin name, global unless scope is supplied; strings and labels with the same spelling are equivalent.
/// - scope (none, str, label, location): Optional namespace; native locations isolate reusable instances.
/// - padding (str, length, dictionary, none): Geometric expansion around the point; `"text"` is an em-based baseline approximation. Adds no layout space.
/// - extra-data (dictionary): Custom metadata; name, scope, padding, dx, dy, type, and hidden are reserved.
///
/// -> content
#let deixis-pin(
  /// A string/label name within scope (document-wide by default). Both spellings
  /// normalize to the same name. Repeated names contribute
  /// multiple occurrences; scoped targets select them with a name/scope record.
  /// -> str | label
  name,
  /// Optional namespace, independent of note/counter scopes. Use a native
  /// location such as here() to isolate each reusable component instance.
  /// -> none | str | label | location
  scope: none,
  /// The mathematical padding around the pin.
  /// - Accepts `length` or `dictionary`.
  /// ```example
  /// #place(center + horizon, deixis-pin("test-padding", padding: 5pt))
  /// #deixis-region-mark(pins: ("test-padding",))
  /// ```
  /// - `"text"` uses top 0.9em, bottom 0.2em, and horizontal 0.1em. This is a
  ///   baseline approximation, not a glyph bounding box. `none`/`auto` mean zero.
  /// - Signed lengths preserve their sign. Percentages have no pin-size basis.
  /// ```example
  /// The library was filled with the #deixis-pin("susurrus-l", padding: "text")susurrus#deixis-pin("susurrus-r", padding: "text") of turning pages.
  /// #deixis-region-mark(pins: ("susurrus-l", "susurrus-r"))
  /// ```
  ///
  /// -> str | length | dictionary | none | auto
  padding: "text",
  /// Custom metadata. `name`, `scope`, `padding`, `dx`, `dy`, `type`, and `hidden` are reserved.
  /// -> dictionary
  extra-data: (:),
) = {
  let name = _deixis-pin-name(name)
  let scope = _deixis-pin-scope(scope)
  let extra-data = _deixis-pin-extra(extra-data)
  // A replayed heading/caption must not register the same pin again.
  _deixis-replayable(none, context {
    _deixis-setup-guard()
    _deixis-pin(name, scope: scope, padding: padding, extra-data: extra-data)
  })
}

#let _deixis-attach(body, pins: (:), prefix: auto, postfix: auto, pattern: auto,
  padding: auto, pin-padding: (:), inline: false, scope: none, node: none) = {
  _deixis-setup-guard()

  let prefix = if prefix == auto { "deixispin" } else { prefix }
  let postfix = if postfix == auto { "" } else { postfix }

  let pin-pattern = _deixis-pin-pattern(prefix, postfix, pattern)
  assert(type(pin-padding) == dictionary, message: "deixis: pin-padding must be a dictionary of pin names to padding values.")
  for name in pin-padding.keys() { _deixis-validate-pin-name(name) }

  // An empty edge dictionary is uniform zero padding, never a per-name map.
  let padding = if type(padding) == dictionary and padding.len() == 0 { 0pt } else { padding }
  let dimension-dict-padding = (
    type(padding) == dictionary and padding.keys().any(k => k in ("left", "right", "top", "bottom", "x", "y", "rest"))
  )
  if dimension-dict-padding and not padding.keys().all(k => k in ("left", "right", "top", "bottom", "x", "y", "rest")) {
    panic("deixis: Ambiguous scanned padding dictionary. Use padding for edge values and pin-padding for per-name overrides.")
  }
  let legacy-map = type(padding) == dictionary and not dimension-dict-padding and padding.len() > 0
  assert(not legacy-map or pin-padding.len() == 0,
    message: "deixis: Do not combine a legacy per-name padding map with pin-padding; use one pin-padding dictionary.")

  let pin-replacer = it => {
    let m = it.text.match(pin-pattern)
    assert(m.text.len() > 0 and m.captures.len() == 1 and m.captures.first() != none,
      message: "deixis: Pin pattern must match text with exactly one capture containing a nonempty pin name.")
    let pin-name = m.captures.at(0)
    _deixis-validate-pin-name(pin-name)

    let active-padding = if pin-name in pin-padding {
      pin-padding.at(pin-name)
    } else if padding == auto {
      "text"
    } else if type(padding) == dictionary {
      if dimension-dict-padding {
        padding
      } else {
        if pin-name == "rest" {
          panic(
            "deixis: #deixis-attach reserves 'rest' as a special keyword for pin-scoped padding dictionary. Rename your pin.",
          )
        }
        padding.at(pin-name, default: padding.at("rest", default: 0pt))
      }
    } else {
      padding
    }
    context _deixis-pin(pin-name, scope: scope, padding: active-padding, extra-data: (type: "inline-regex"))
  }

  show: it => if pin-pattern == none { it } else {
    show pin-pattern: pin-replacer
    show raw: raw-body => {
      show pin-pattern: pin-replacer
      raw-body
    }
    it
  }

  if pins.len() > 0 or node != none {
    let pin-pairs = (if type(pins) == dictionary { pins.pairs() } else { pins }).map(pair => (
      pair.first(), _deixis-pin-spec(pair.last()),
    ))
    let container = if inline { box } else if node != none { block.with(breakable: false) } else { block }
    container(width: auto, height: auto, {
      if node != none {
        _deixis-metadata(node, <deixis-attached-node>)
        _deixis-attached-corners(node)
      }
      let bottom-offset(pin-args) = {
        let dy = pin-args.dy
        if dy == 100% { 0pt }
        else if type(dy) == relative and dy.ratio == 100% { dy.length }
        else { none }
      }
      let paint-pin(pin-name, pin-args, bottom-pin: false) = {
        let dx = pin-args.dx
        let dy = pin-args.dy
        let padding = pin-args.padding
        let extra-data = pin-args.extra-data
        if _std-target() == "html" {
          return _deixis-pin(pin-name, scope: scope, padding: padding,
            extra-data: (type: "overlay", dx: dx, dy: dy) + extra-data)
        }

        place((if bottom-pin { bottom } else { top }) + left,
          dx: dx, dy: if bottom-pin { bottom-offset(pin-args) } else { dy }, _deixis-pin(
            pin-name,
            scope: scope,
            padding: padding,
            extra-data: (type: "overlay", dx: dx, dy: dy) + extra-data,
          ))
      }
      // Bottom pins belong to the final fragment of a breakable block. Emitting
      // them before the body attached them to the first page instead.
      let at-bottom(pin-args) = bottom-offset(pin-args) != none
      for (pin-name, pin-args) in pin-pairs {
        if not at-bottom(pin-args) { paint-pin(pin-name, pin-args) }
      }
      body
      for (pin-name, pin-args) in pin-pairs {
        if at-bottom(pin-args) { paint-pin(pin-name, pin-args, bottom-pin: true) }
      }
    })
  } else {
    body
  }
}

/// Attaches geometric anchors and optional routing identity to live content.
///
/// This function does two things:
/// 1. It scans the `body` text for your pin prefix (e.g., `deixispinTop`) and converts them into physical inline pins.
/// 2. It can place absolute overlay pins relative to the bounding box of the `body` (e.g., placing a pin exactly at `dx: 100%, dy: 100%`).
/// Optional id/behavior also registers the content frame for deixis-routing.
/// Named frames offer top/bottom/left/right midpoint ports automatically; use
/// connector.ports for side/percentage/sliding selection or one of these pins
/// for an exact custom socket. pins accepts any number of named anchors.
///
/// - body (content): The content block to wrap and scan.
/// - pins (dictionary): A dictionary mapping pin names to overlay coordinates and padding. Example: `("my-pin": (dx: 100%, dy: 50%, padding: 2pt))`.
/// - scope (none, str, label, location): Optional namespace shared by this attachment's scanned and coordinate pins.
/// - prefix (auto, str, none): Literal opening delimiter; auto uses "deixispin". Set to none to disable delimiter scanning.
/// - pattern (auto, regex, none): An explicit scanning regex with exactly one capture for the pin name; overrides delimiters.
/// - padding (auto, str, length, dictionary): Padding for pins replaced with `prefix`. It has no effect on pins defined with `pins`.
/// - inline (bool): If `true`, the wrapper uses an inline `box` instead of a `block`.
///
/// -> content
#let deixis-attach(
  /// The content block to wrap and scan.
  /// -> content
  body,
  /// Optional routing-node identity. Strings and labels agree. A registered
  /// attachment is one nonbreaking native frame and can be selected with
  /// (node: id) by deixis-connect. Scope also namespaces this identity.
  /// Four side midpoints are automatic ports; no named pins are required.
  /// Independent of note IDs and pin names, including equal spellings. Wrapping
  /// an overlay note declaration captures its declaration, not its painted body.
  /// -> none | str | label
  id: none,
  /// Routing behavior: avoid, ignore, cut or cross. auto registers an avoid
  /// node when id is supplied; without an ID, auto preserves ordinary attach.
  /// An explicit behavior also registers an anonymous obstacle/decorative node.
  /// -> auto | str
  behavior: auto,
  /// A dictionary mapping pin names to overlay coordinates and padding. Example: `("my-pin": (dx: 100%, dy: 50%, padding: 2pt))`.
  ///
  /// ```example
  /// #deixis-attach(
  ///   pins: (
  ///     area-tl: (dx: 20%, dy: 20%, padding: 2pt),
  ///     area-br: (dx: 80%, dy: 80%, padding: 2pt),
  ///   ),
  /// )[
  ///   #rect(width: 160pt, height: 90pt, fill: luma(240))
  /// ]
  /// #deixis-region-mark(
  ///   pins: ("area-tl", "area-br"),
  ///   stroke: red + 2pt,
  /// )
  /// ```
  ///
  /// Missing coordinates default to zero. Bottom pins (`dy: 100%`, optionally
  /// plus an offset) follow the final fragment of a breakable block.
  /// An alternative `(anchor: top + right, offset: (2pt, 0pt))` uses native
  /// alignment and an optional coordinate pair. Do not combine it with dx/dy.
  /// Dictionary keys are strings. A pair array also accepts label-valued names,
  /// e.g. `((<corner>, (anchor: top + left)),)`.
  /// -> dictionary | array
  pins: (:),
  /// Namespace for both scanned and coordinate pins. It does not affect other
  /// pin declarations in the body or change note/counter scopes.
  /// -> none | str | label | location
  scope: none,
  /// Literal opening delimiter. If `auto`, uses `"deixispin"`; none/empty disables
  /// delimiter scanning. Use `pattern` for intentional regular expressions.
  ///
  /// ```info
  /// Pins attached with regex scan will have `padding: "text"` by default. Use `deixis-attach.padding` for customization.
  /// ```
  ///
  /// ````example
  /// Usage:
  /// #deixis-attach(prefix: "mypin")[
  ///   ```typst
  ///   mypincode1#deixis-attachmypincode2(postfix: "deixis")[
  ///     deixispinp1deixisThis line will be pinned.deixispinp2deixis
  ///   ]
  ///   // Now one can use pins "p1" and "p2"
  ///   ```
  /// ]
  /// #deixis-region-mark(pins: ("code1", "code2"), fill: red.transparentize(95%))
  /// ````
  ///
  /// ```tip
  /// Oftentimes, if `prefix` alone is not enough, you can also define a `postfix`.
  ///
  /// The name of the pin attached with regex scan should also not contain any special character, depending on the `raw` language.
  /// ```
  ///
  /// Set to `none` or an empty string to disable text scanning.
  /// -> auto | str | none
  prefix: auto,
  /// Literal closing delimiter. If `auto`, uses `""`; none/empty omits it.
  ///
  /// ````example
  /// Python hello world program:
  /// #deixis-attach(
  ///   prefix: "mypin",
  ///   postfix: "mypin")[
  ///   ```python
  ///   mypincode3mypinprintmypincode4mypin("Hello world!")
  ///   ```
  /// ]
  /// #deixis-region-mark(pins: ("code3", "code4"), fill: red.transparentize(95%))
  /// ````
  ///
  /// -> auto | str | none
  postfix: auto,
  /// Explicit scanning regex with exactly one capture for the pin name.
  /// `auto` builds a pattern from literal prefix/postfix; `none` disables scanning.
  /// -> auto | regex | none
  pattern: auto,
  /// Padding for pins replaced with `deixis-attach.prefix`. It has no effect on pins defined with `deixis-attach.pins`.
  ///
  /// ```example
  /// Pythagorean theorem:
  ///
  /// #align(center)[
  /// #deixis-attach(
  ///   prefix: "mypin",
  ///   pin-padding: (  // dict of pin names
  ///     eq1: (top: 1.2em, bottom: 0.5em, left: 1em),
  ///     eq2: (top: 1.2em, bottom: 0.5em, right: 1em),
  ///   ),
  /// )[
  ///   mypineq1$a^2 + b^2 = c^2$mypineq2
  /// ]
  /// ]
  /// #deixis-region-mark(pins: ("eq1", "eq2"), stroke: orange, fill: orange.transparentize(95%))
  /// ```
  ///
  /// -> auto | str | length | dictionary
  padding: auto,
  /// Per-name padding for scanned pins. Names such as left/rest are literal
  /// names here. Unlisted names use padding; explicit coordinate pins keep their
  /// own padding. Prefer this to legacy per-name maps passed through padding.
  /// -> dictionary
  pin-padding: (:),
  /// If `true`, the wrapper uses an inline `box` instead of a `block`.
  ///
  /// ```example
  /// #lorem(7)
  /// #deixis-attach(
  ///   pins: (tl1: (dx: 0%, dy: 0%), br1: (dx: 100%, dy: 100%)),
  ///   inline: false)[
  ///   Block-level attached content.
  /// ]
  /// #deixis-region-mark(pins: ("tl1", "br1"), stroke: teal)
  ///
  /// #lorem(7)
  /// #deixis-attach(
  ///   pins: (tl2: (dx: 0%, dy: 0%), br2: (dx: 100%, dy: 100%)),
  ///   inline: true)[
  ///   Inline attached content.
  /// ]
  /// #deixis-region-mark(pins: ("tl2", "br2"), stroke: green)
  /// ```
  ///
  /// -> bool
  inline: false,
) = {
  let scope = _deixis-pin-scope(scope)
  if id != none { id = _deixis-pin-name(id) }
  assert(behavior == auto or behavior in ("avoid", "ignore", "cut", "cross"),
    message: "deixis: Attached node behavior must be auto, avoid, ignore, cut or cross.")
  assert(type(pins) in (dictionary, array), message: "deixis: Attached pins must be a name/specification dictionary or pair array.")
  let pairs = if type(pins) == dictionary { pins.pairs() } else { pins }
  let pairs = pairs.map(pair => {
    assert(type(pair) == array and pair.len() == 2, message: "deixis: Each attached pin needs a name and specification.")
    (_deixis-pin-name(pair.first()), pair.last())
  })
  context {
    let node = if id == none and behavior == auto { none } else {
      (id: id, scope: scope, behavior: if behavior == auto { "avoid" } else { behavior }, instance: here())
    }
    _deixis-attach(body, pins: pairs, prefix: prefix, postfix: postfix, pattern: pattern,
      padding: padding, pin-padding: pin-padding, inline: inline, scope: scope, node: node)
  }
}
