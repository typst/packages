#import "../core/internal.typ": *
#import "inline-paint.typ": _deixis-render-inline-mark
#import "region-paint.typ": _deixis-region-content, _deixis-render-region-shape, _deixis-immediate-region, _deixis-html-region-marker
#import "../core/occurrences.typ": _deixis-occurrence-name, _deixis-occurrence-frame
#import "../core/native.typ": *

// Reuse the region painter without publishing another primary mark. Its private
// pins and return destination belong to this occurrence, not to the annotation.
#let _deixis-paint-region-occurrence(data, sys, target, name, owner, body, marker-str, options) = {
  let same-type = data.at("mark-type", default: none) == "region"
  let inherited = (:)
  for (key, value) in data.at("mark-styles", default: (:)) {
    if key in ("stroke", "fill", "radius") or same-type { inherited.insert(key, value) }
  }
  inherited.insert("marker-style", data.at("marker-style", default: auto))
  inherited.insert("z-index", data.at("mark-z-index", default: 0))
  if same-type {
    inherited.insert("region-shape", data.at("region-shape", default: auto))
    inherited.insert("layer", data.at("layer", default: auto))
  }
  sys.stack.push(inherited)
  let styles = _deixis-resolve-mark-styles(sys, "region-mark",
    marker-position: options.marker-position, stroke: options.stroke, fill: options.fill, radius: options.radius)
  let marker-style = _deixis-resolve-typed-param(sys, options.marker-style, "marker-style", "region-mark", component: "mark")
  let shape = _deixis-resolve-typed-param(sys, options.region-shape, "region-shape", "region-mark")
  let layer = _deixis-resolve-typed-param(sys, options.layer, "layer", "region-mark", component: "mark")
  let padding = if options.padding != auto { options.padding }
    else if same-type { data.at("padding", default: 0pt) }
    else if options.inline and body != none { "text" } else { 0pt }
  let prepared = _deixis-region-content(body, options.pins, padding, options.inline, owner)
  let record = (
    render-context: _deixis-render-context(),
    internal-id: str(data.internal-id), target-id: data.target-id, inst-id: data.inst-id,
    data: data.at("data", default: (:)), accent: data.at("accent", default: none),
    series: data.series, count: data.count, body: body,
    mark-lbl: none, body-lbl: _std-label("deixis-body-" + str(data.internal-id)),
    marker-str: marker-str, marker-style: marker-style,
    pins: prepared.pins, shape-func: shape, layer: layer,
    z-index: _deixis-resolve-z-index(sys, options.z-index, "region-mark", "mark"),
    styles: styles + (padding: prepared.padding),
    occurrence-target: str(target), occurrence-name: name, occurrence-owner: owner,
  )
  if _std-target() == "html" {
    return [#prepared.body#_deixis-html-region-marker(sys, record)#_deixis-metadata(record, <deixis-region-occurrence>)]
  }
  let drawing = if layer == "flow" {
    let content = context _deixis-render-region-shape(deixis-system.get(), record,
      _deixis-pin-index(), here().page(), base-pos: here().position())
    _deixis-immediate-region(content, options.inline)
  }
  let content = if options.inline { [#drawing#prepared.body] } else { [#prepared.body#drawing] }
  [#content#_deixis-metadata(record, <deixis-region-occurrence>)]
}

// Shared occurrence engine used by the unified and specialized mark functions.
#let _deixis-repeat-mark(
  ..args,
  of: none,
  mark-type: auto,
  occurrence: none,
  marker: auto,
  marker-style: auto,
  marker-position: auto,
  inline-mode: auto,
  stroke: auto,
  fill: auto,
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
  pins: (),
  padding: auto,
  region-shape: auto,
  layer: auto,
  inline: false,
) = {
  let render-with-order-hints() = {
    assert(args.named().len() == 0,
      message: "deixis: Unknown repeat option(s) " + repr(args.named().keys()) + ". Use of to select an existing annotation, not label.")
    let pos = args.pos()
    let target = of
    assert(type(target) in (str, label) and str(target).len() > 0,
      message: "deixis: A reused mark requires of: a nonempty string ID or label.")
    assert(pos.len() <= 1 and (pos.len() == 0 or type(pos.first()) != label),
      message: "deixis: A mark accepts at most one [passage]; use named id or of for its identity.")
    let body = pos.at(0, default: none)
    let name = _deixis-occurrence-name(occurrence)
    assert(type(pins) == array, message: "deixis: Repeated region pins must be an array.")
    let kind = _deixis-resolve-mark-type(mark-type, pins: pins)
    if kind == "region" {
      assert((body != none) != (pins.len() > 0),
        message: "deixis: A repeated region requires either pins or one [passage], not both.")
      assert(inline-mode == auto, message: "deixis: inline-mode applies only to inline repeats.")
    } else {
      assert(pins.len() == 0 and padding == auto and region-shape == auto and layer == auto and inline == false,
        message: "deixis: Region options require a region repeat (mark-type: \"region\" or pins).")
      if kind == "phantom" {
        assert(body == none and (marker, marker-style, marker-position, inline-mode, stroke, fill, radius).all(v => v == auto),
          message: "deixis: Phantom repeats accept no passage or appearance overrides; they are invisible semantic anchors.")
      }
    }
    let options = (marker-style: marker-style, marker-position: marker-position, stroke: stroke, fill: fill,
      radius: radius, z-index: z-index, pins: pins, padding: padding, region-shape: region-shape, layer: layer, inline: inline)
    let paint(owner) = context {
      _deixis-check-setup-state()
      // Original marks and their body labels already live in the final registry.
      // Repeating a mark needs no document-wide declaration/destination scan.
      let registry = _deixis-registry(deixis-system.final())
      let key = str(target)
      let uid = registry.id-index.at(key, default: none)
      let data = if uid == none { (:) } else { registry.notes.at(uid) }
      assert(data.at("count-id", default: none) != none,
        message: "deixis: Repeated mark target " + repr(target) + " must name an original mark, using its ID.")
      let sys = _deixis-accent-context(deixis-system.get(), data.at("accent", default: none))
      let _ = _deixis-resolve-z-index(sys, z-index, kind + "-mark", "mark")
      if kind == "phantom" { return none }
      let marker-str = if marker == auto { _deixis-evaluate-marker-str(data) } else { marker }
      // A hidden occurrence needs no inline box/glue or empty paragraph.
      let body = if body == none { none } else { deixis-utils._deixis-trim-content(body) }
      if kind == "region" {
        return _deixis-paint-region-occurrence(data, sys, target, name, owner, body, marker-str, options)
      }
      if body == none and marker-str == none { return none }
      // Captured original mark settings are the fallback beneath local component
      // overrides. A body-only override therefore cannot restyle this occurrence.
      // Resolve before merging so component records never mix with edge records.
      let inherited = data.at("mark-styles", default: (:)) + (
        inline-mode: data.at("inline-mode", default: auto),
        marker-position: data.at("marker-position", default: auto),
        marker-style: data.at("marker-style", default: auto),
      )
      sys.stack.push(inherited)
      let m-styles = _deixis-resolve-mark-styles(sys, "inline-mark", inline-mode: inline-mode,
        marker-position: marker-position, stroke: stroke, fill: fill, radius: radius)
      let marker-style = _deixis-resolve-typed-param(sys, marker-style, "marker-style", "inline-mark", component: "mark")
      let rendered = _deixis-render-inline-mark(body, marker-str: marker-str, marker-style: marker-style,
        body-lbl: _std-label("deixis-body-" + uid), origin: [], ..m-styles)
      if name == none { rendered } else { _deixis-occurrence-frame(rendered, target, name) }
    }
    // Publish the call's origin before deferred marker/style resolution, just as
    // references do. Hook dimensions must not wait for the marker's final state.
    let emit(owner) = [#_deixis-metadata((targets: (str(target),), name: name, kind: kind, owner: owner, passage: body), <deixis-mark-occurrence>)#paint(owner)]
    // A private native location distinguishes unnamed regions and their corner
    // pins too. Publish the early origin before deferred final-registry lookup.
    if kind == "region" { context { emit(here()) } } else { emit(none) }
  }
  _deixis-replayable(args.pos().at(0, default: none), [#_deixis-order-hints(z-index)#render-with-order-hints()], of: of)
}
