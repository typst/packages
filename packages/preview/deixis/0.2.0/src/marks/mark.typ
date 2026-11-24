#import "../core/internal.typ": *
#import "inline.typ": deixis-inline-mark, deixis-phantom-mark
#import "region.typ": deixis-region-mark
#import "repeat.typ": _deixis-repeat-mark

/// Creates a mark, or adds another occurrence of an annotation.
///
/// ```example
/// #deixis-mark(id: <idea>)[First passage]
/// #deixis-margin-note-body(of: <idea>)[One explanation.]
/// #deixis-mark(of: <idea>)[Another passage]
/// ```
///
/// Use `id:` to declare the original counter owner and `of:` to reuse it, even
/// before the original declaration. Without either, this is anonymous decoration.
/// The default is inline; supplied pins select region mode. Select another form
/// explicitly with `mark-type: "region"` or `"phantom"`. Reuse adds a backlink
/// origin and never inherits a drawn connector. Name an occurrence and use
/// `deixis-connect` when an additional connection is wanted.
///
/// - id (none, str, label): Declare an original annotation with this public ID.
/// - data (dictionary): Custom annotation fields, kept under note.data. Configure on creation or a standalone body; omit with of.
/// - of (none, str, label): Reuse an original annotation; mutually exclusive with id.
/// - mark-type (auto, str): Inline by default, region with pins, or explicit inline/region/phantom.
/// - occurrence (none, str, label): Name a reused occurrence within its annotation.
/// - numbering (auto, none, str, function, dictionary): Original numbering style; inherited on reuse.
/// - target (int, str, label): Original counter scope; inherited on reuse.
/// - series (str): Original counter series; inherited on reuse.
/// - marker (auto, none, content): Number automatically, replace the marker, or hide it.
/// - marker-style (auto, function, dictionary): Mark marker appearance.
/// - marker-position (auto, alignment, dictionary): Marker position.
/// - inline-mode (auto, str): Inline passage decoration.
/// - stroke (auto, stroke, none): Decoration stroke.
/// - fill (auto, color, none): Decoration fill.
/// - radius (auto, length, dictionary): Decoration radius.
/// - pins (array): Region bounds instead of a passage.
/// - padding (auto, length, str, dictionary): Region padding.
/// - region-shape (auto, function): Region shape renderer.
/// - layer (auto, str, dictionary): Region paint layer.
/// - inline (bool): Wrap a region passage in an inline box.
/// - ..args (arguments): At most one optional [passage]; identity arguments are named.
/// -> content
#let deixis-mark(
  /// At most one optional [passage]; identity arguments are named.
  /// -> arguments
  ..args,
  /// Declare an original annotation with this public ID.
  /// -> none | str | label
  id: none,
  /// Custom annotation fields. Owned by creation; omit with of.
  /// Kept under note.data in queries and body renderers, outside runtime fields.
  /// -> dictionary
  data: (:),
  /// Reuse an original annotation; mutually exclusive with id.
  /// -> none | str | label
  of: none,
  /// Inline by default, region with pins, or explicit inline/region/phantom.
  /// -> auto | str
  mark-type: auto,
  /// Name a reused occurrence within its annotation.
  /// -> none | str | label
  occurrence: none,
  /// Original numbering style; inherited on reuse.
  /// A record `(restart: "page", pattern: "1")` restarts displayed markers per original page; assigned counters stay unchanged.
  /// `none` disables automatic markers and counter allocation.
  /// -> auto | none | str | function | dictionary
  numbering: auto,
  /// Original counter scope; inherited on reuse.
  /// -> int | str | label
  target: 0,
  /// Original counter series; inherited on reuse.
  /// -> str
  series: "default",
  /// Number automatically, replace the marker, or hide it.
  /// -> auto | none | content
  marker: auto,
  /// Mark marker appearance.
  /// -> auto | function | dictionary
  marker-style: auto,
  /// Marker position.
  /// -> auto | alignment | dictionary
  marker-position: auto,
  /// Inline passage decoration.
  /// -> auto | str
  inline-mode: auto,
  /// Decoration stroke.
  /// -> auto | stroke | none
  stroke: auto,
  /// Decoration fill.
  /// -> auto | color | none
  fill: auto,
  /// Decoration radius.
  /// -> auto | length | dictionary
  radius: auto,
  /// Overlay paint priority; higher integers paint later within a layer.
  /// Native flow retains its order. Component dictionaries are supported.
  /// -> auto | int | dictionary
  z-index: auto,
  /// Region bounds instead of a passage.
  /// -> array
  pins: (),
  /// Region padding.
  /// -> auto | length | str | dictionary
  padding: auto,
  /// Region shape renderer.
  /// -> auto | function
  region-shape: auto,
  /// Region paint layer.
  /// -> auto | str | dictionary
  layer: auto,
  /// Wrap a region passage in an inline box.
  /// -> bool
  inline: false,
) = {
  let render-with-order-hints() = {
    _deixis-check-identities(id, of)
    _deixis-check-note-data(data, of: of)
    assert(args.named().len() == 0,
      message: "deixis: Unknown mark option(s) " + repr(args.named().keys()) + ". Use named id to declare or of to reuse.")
    let positional = args.pos()
    assert(positional.len() <= 1 and (positional.len() == 0 or type(positional.first()) != label),
      message: "deixis: A mark accepts at most one [passage]; use named id or of for its identity.")
    let body = positional.at(0, default: none)
    assert(type(pins) == array, message: "deixis: Region pins must be an array.")
    let kind = _deixis-resolve-mark-type(mark-type, pins: pins)
    if of != none {
      assert(numbering == auto and target == 0 and series == "default",
        message: "deixis: Reused marks inherit numbering, scope target, and series. Configure those on the original declaration.")
      return _deixis-repeat-mark(of: of, mark-type: kind, occurrence: occurrence,
        marker: marker, marker-style: marker-style, marker-position: marker-position,
        inline-mode: inline-mode, stroke: stroke, fill: fill, radius: radius, z-index: z-index,
        pins: pins, padding: padding, region-shape: region-shape, layer: layer,
        inline: inline, body)
    }
    assert(occurrence == none, message: "deixis: occurrence requires of on a mark.")
    if kind == "region" {
      assert(inline-mode == auto, message: "deixis: inline-mode applies only to inline marks.")
      deixis-region-mark(id: id, data: data, numbering: numbering, target: target, series: series,
        marker: marker, marker-style: marker-style, marker-position: marker-position,
        stroke: stroke, fill: fill, radius: radius, z-index: z-index, pins: pins, padding: padding,
        region-shape: region-shape, layer: layer, inline: inline, body)
    } else {
      assert(pins.len() == 0 and padding == auto and region-shape == auto and layer == auto and inline == false,
        message: "deixis: Region options require a region mark (mark-type: \"region\" or pins).")
      if kind == "phantom" {
        assert(body == none and (marker-style, marker-position, inline-mode, stroke, fill, radius).all(v => v == auto),
          message: "deixis: Phantom marks accept no passage or appearance overrides; they are invisible semantic anchors.")
        deixis-phantom-mark(id: id, data: data, numbering: numbering, target: target, series: series, marker: marker, z-index: z-index)
      } else {
        deixis-inline-mark(id: id, data: data, numbering: numbering, target: target, series: series,
          marker: marker, marker-style: marker-style, marker-position: marker-position,
          inline-mode: inline-mode, stroke: stroke, fill: fill, radius: radius, z-index: z-index, body)
      }
    }
  }
  _deixis-replayable(args.pos().at(0, default: none), [#_deixis-order-hints(z-index)#render-with-order-hints()])
}
