#import "core/visibility.typ": _deixis-metadata
#import "core/declarations.typ": _deixis-replayable
#import "core/state.typ": deixis-system
#import "core/targets.typ": _deixis-setup-guard
#import "core/config.typ": _deixis-resolve-typed-param
#import "core/connectors.typ": _deixis-connector-options
#import "core/endpoints.typ": _deixis-endpoint-selector
#import "core/order.typ": _deixis-order-hints
#import "render/body.typ": _deixis-render-context
#import "routing/document-policy.typ": _deixis-routing-policy, _deixis-capture-routing

/// Draws an independent connection between attached nodes/pins, or from an original/named mark
/// or pin to a margin/inset body, framed inline body, live body's point, or pin.
/// Declarations may precede either endpoint or a collected body's printer.
/// It adds no body, counter increment, placement anchor, or PDF return origin.
///
/// ```example
/// #deixis-inset-note(id: <shared>, connector: none,
///   layer: "foreground", width: 90pt, dx: 100pt, dy: 40pt)[First][One body.]
/// #deixis-mark(of: <shared>, occurrence: <again>)[Again]
/// #deixis-connect(from: (mark: <shared>, occurrence: <again>), to: <shared>)
/// ```
///
/// Inside deixis-routing, declarations capture the innermost scope's policy.
/// manual uses native paths, avoid searches obstacles independently, and
/// separate repairs a page/layer group. The scoped default route is sharp
/// orthogonal. Outside, the default is straight.
/// Attached nodes use `(node: id)`, optionally scope/page; no note is created.
/// continuation accepts auto/none, dot/portal, a shape/size/stroke/fill/link
/// record, or a callback. Native portals trim only the painted shaft and can
/// link to the real peer or accepted counterpart; they are not endpoint heads.
///
/// - from (str, label, dictionary): Original ID, `(mark: id, occurrence: name)`, `(node: id, scope: ..., page: ...)`, or `(pin: target)`. Pin targets accept a name or the shared name/scope/select/page record and must select one occurrence.
/// - to (str, label, dictionary): Body frame ID, `(body: id)`, `(body: id, point: "start" | "end")`, an attached node, or `(pin: target)`. Collected bodies must actually be printed.
/// - connector (auto, none, dictionary): Route/ports/via/heads/cuts/crossings/gap-marks/style/render/layer settings. Route accepts a string or `(kind: "curve", tension: 2)`; catmull-rom also selects centripetal/uniform parameterization. Hobby uses global tension (minimum 0.75) and free-end curl (default 1). B-spline records use controls for coordinate/framed/pin influences, distinct from exact via points. A custom port `(pin: target, side: left, gap: 2pt)` keeps node bounds; a waypoint `(pin: target, offset: (2pt, 0pt))` visits a point exactly. The default route is straight; none disables the declaration. Optional cuts hide original-route arc-length intervals without changing curve geometry. Optional crossings: "gap" cuts lower-priority native shafts where participating routes cross in one overlay. Optional gap-marks (slash/bar) decorate surviving internal gaps; page-continuation dots remain separate. Optional scene accepts a prepared routing scene or a read-only page-fragment callback, applying sharp avoidance or native cut/cross events before head preparation; see docs/guides/routing-scenes.md.
/// -> content
#let deixis-connect(
  /// Original mark ID, named occurrence record, attached node selector, or pin target. Forward declarations are allowed.
  /// -> str | label | dictionary
  from: none,
  /// Body ID/frame, live body start/end point, attached node, or pin target. Collected bodies must be printed.
  /// -> str | label | dictionary
  to: none,
  /// Route, ports, via, heads, cuts, crossing/gap marks, continuation, scene, style, layer and painter options. A route name is shorthand for `(route: name)`. Auto enables defaults; none disables.
  /// -> auto | none | str | dictionary
  connector: auto,
) = {
  let render-with-order-hints() = {
    let source = _deixis-endpoint-selector(from, "mark")
    let target = _deixis-endpoint-selector(to, "body")
    context {
      _deixis-setup-guard()
      let sys = deixis-system.get()
      let routing = _deixis-routing-policy()
      let line-style = _deixis-resolve-typed-param(sys, auto, "stroke", "connection", component: "connector", with-origin: true)
      let options = _deixis-connector-options(sys, "connection", connector,
        route: if routing == none { "straight-line" } else { "right-angle" },
        stroke: line-style.value, factory-stroke: line-style.origin in ("factory", "fallback"),
        radius: if routing == none { _deixis-resolve-typed-param(sys, auto, "radius", "connection", component: "connector") } else { 0pt })
      [#_deixis-metadata((source: source, target: target, options: options,
        render-context: _deixis-render-context()) + _deixis-capture-routing(options, routing: routing), <deixis-connection>)]
    }
  }
  _deixis-replayable(none, [#_deixis-order-hints(auto, connector: connector)#render-with-order-hints()])
}
