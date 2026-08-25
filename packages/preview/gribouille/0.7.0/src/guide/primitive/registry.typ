///! One dispatch point for every primitive.
///!
///! Adding a primitive means adding a module and one row here, rather than
///! editing a chain of `if` arms at each of the measure and draw sites. The
///! dispatch mirrors how geoms are dispatched by name in `render/panel-draw.typ`.

#import "../../utils/errors.typ": fail-enum, fail-type
#import "common.typ": PRIMITIVE
#import "../gizmo/bar.typ" as bar-mod
#import "content.typ" as content-mod
#import "keys.typ" as keys-mod
#import "labels.typ" as labels-mod
#import "line.typ" as line-mod
#import "spacer.typ" as spacer-mod
#import "ticks.typ" as ticks-mod
#import "title.typ" as title-mod

#let PRIMITIVES = (
  line: (measure: line-mod.measure, draw: line-mod.draw),
  ticks: (measure: ticks-mod.measure, draw: ticks-mod.draw),
  labels: (measure: labels-mod.measure, draw: labels-mod.draw),
  keys: (measure: keys-mod.measure, draw: keys-mod.draw),
  bar: (measure: bar-mod.measure, draw: bar-mod.draw),
  title: (measure: title-mod.measure, draw: title-mod.draw),
  content: (measure: content-mod.measure, draw: content-mod.draw),
  spacer: (measure: spacer-mod.measure, draw: spacer-mod.draw),
)

#let _entry-for(prim, scope) = {
  if type(prim) != dictionary or prim.at("kind", default: none) != PRIMITIVE {
    fail-type(scope, "primitive", prim, "a primitive dictionary")
  }
  let name = prim.at("name", default: none)
  if name not in PRIMITIVES {
    fail-enum(scope, "primitive", name, PRIMITIVES.keys())
  }
  PRIMITIVES.at(name)
}

// Room this primitive needs, as a `measured` record.
#let measure(prim, gctx, entries: auto) = {
  let fns = _entry-for(prim, "guide-primitive.measure")
  (fns.measure)(prim, gctx, entries: entries)
}

// Emit this primitive's ink. Returns nothing.
#let draw(prim, gctx, entries: auto) = {
  let fns = _entry-for(prim, "guide-primitive.draw")
  (fns.draw)(prim, gctx, entries: entries)
}
