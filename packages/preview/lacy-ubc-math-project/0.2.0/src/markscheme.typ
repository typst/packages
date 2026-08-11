#import "spec.typ": spec, spell, component-type
#import "util.typ": config-state

// unique solution count, used for markscheme
#let solution-counter = counter(spec.solution.kind)

/// Produce a marker object. It is to be processed to produce markings.
///
/// - display (str, content): The displayed marker.
/// - point (int, decimal, float): The point the marker grants.
/// - remark (arguments): The remark for the marker.
///   [WARN] Only the first sink argument is taken as remark, the rest are discarded.
/// -> dictionary
#let marker(display, point, ..remark) = spell(
  spec.marker.name,
  display: display,
  point: point,
  remark: remark.pos().at(0, default: none),
)

/// Visualize a group of markers, as a marking.
///
/// - markers (array): The markers to be visualized as in a group.
/// - width (length, auto): The width of box to fit the marking.
/// - sum (bool): Whether to visualize to the markers' sum.
/// -> content
#let markers-visualizer(markers, width: auto, sum: false, config: (:)) = {
  set text(
    font: config.global.font-minor,
    fill: config.global.color-minor,
    size: 0.8em,
    style: "italic",
    weight: "bold",
  )
  set par(
    first-line-indent: 0pt,
    hanging-indent: 0pt,
    leading: .2em,
  )

  let cont = box.with(width: width, height: auto, inset: 0pt, outset: 0pt)

  if sum {
    let total = markers.map(m => m.point).sum(default: 0)
    if total in (0, 1) {
      cont[[#total point]]
    } else {
      cont[[#total points]]
    }
  } else {
    cont(
      markers.map(m => [(#m.display#m.point)]).join(sym.zws)
        + linebreak()
        + markers.map(m => m.remark).filter(rm => rm != none).map(rm => [(#rm)]).join(sym.zws),
    )
  }
}

/// Embed metadata of a pin, containing arbitrary data entries.
///
/// - args (arguments): Named data entries to put in the pin.
/// -> metadata
#let embed-pin(..args) = metadata(
  spell(
    spec.pin.name,
    ..args.named(),
  ),
)

/// Check if `data` is a pin, or a `metadata` of a pin.
///
/// - data (dictionary, metadata, any): The data to be tested.
/// - preds (arguments): Key-value pairs that would be checked against `data`: whether it contains the exact pair or not.
/// -> bool
#let is-pin(data, ..preds) = {
  if data.func() == metadata {
    data = data.value
  }
  return (
    component-type(data) == spec.pin.name
      and preds.named().pairs().map(((pk, pv)) => data.keys().contains(pk) and data.at(pk) == pv).all(p => p == true)
  )
}

/// Embed metadata of a mark, containing the target solution's UID and some markers.
///
/// - id (int): The ID of the mark, to pair it with a solution by the solution's UID.
/// - markers (array): The markers the mark should carry.
/// -> metadata
#let embed-mark(id, markers) = metadata(
  spell(
    spec.mark.name,
    id: id,
    markers: markers,
  ),
)

/// Check if `data` is a mark, or a `metadata` of a mark.
///
/// - data (dictionary, metadata, any): The data to be tested.
/// -> bool
#let is-mark(data) = {
  if data.func() == metadata {
    data = data.value
  }
  return component-type(data) == spec.mark.name
}

/// Mark some content.
/// Example:
/// ```typ
/// #import markscheme as m: markit
/// ...
/// #markit(m.r(2), m.c(1))[This, that...thus the answer is 42.]
/// ```
///
/// - args (arguments): Content to be marked, and markers to mark it:
///   - call of certain helper functions from module `markscheme`, e.g. `m()`, `c()` a/o `a()` → they produce specific `dictionary`s so the package recognize them as markers;
///   - otherwise, the content to be marked.
/// -> content
#let markit(..args) = layout(size => {
  // above, use `layout` so the `body` and mark are together in one.
  // maybe a `box` is better but idk
  let args = args.pos()
  let markers = args.filter(a => component-type(a) == spec.marker.name)
  let body = args.filter(a => component-type(a) != spec.marker.name).join()

  embed-mark(
    solution-counter.get().first(),
    markers,
  )
  body
})

/// Take up a cell, embed relevant information for displaying markings.
///
/// - uid (int): The UID of the solution that this marking is targeting.
/// - width (length): Width of available marking space.
/// -> content
#let marking(uid, width) = context {
  // above, a context, so the pin is placed in *this* context--the marking cell, not the entire context of the solution block

  embed-pin(id: uid, usage: spec.marker.name, pos: top + left, width: width)
}

/// The magical content that actually displays marking.
/// [WARN] Put it into `page.foreground`, for instance:
/// ```typ
/// #import markscheme as m: markit
/// ...
/// #set page(foreground: m.foreground-marking)
/// ```
#let foreground-marking = context {
  let conf = config-state.get()

  let this-page = here().page()
  let meta = query(metadata)

  let marks = meta.filter(m => m.location().page() == this-page and is-mark(m))
  // leave if no mark
  if marks == () { return none }
  let pins = meta.filter(m => is-pin(m, usage: spec.marker.name))
  // leave if no pin
  if pins == () { return none }

  // group into (dx, marks with the same pin id)
  let mark-groups = pins
    .filter(p => p.value.pos == top + left)
    .map(pin => (
      pin,
      marks.filter(m => m.value.id == pin.value.id),
    ))
    .filter(gp => gp.at(1) != ())

  for (pin, marks) in mark-groups {
    for (i, mark) in marks.enumerate() {
      place(
        dx: pin.location().position().x,
        dy: mark.location().position().y,
        markers-visualizer(mark.value.markers, width: pin.value.width, config: conf),
      )
    }
  }

  //TODO figure out why it cannot handle pagebreak
  // for bpin in pins.filter(p => p.location().page() == this-page and p.value.pos == bottom + left) {
  //   let group = mark-groups.find(gp => gp.first().value.id == bpin.value.id)
  //   if group == none { continue }
  //
  //   let sum = markers-visualizer(
  //     group.at(1).map(m => m.value.markers).flatten(),
  //     width: group.at(0).value.width,
  //     sum: true,
  //   )
  //
  //   place(
  //     dx: group.at(0).location().position().x,
  //     dy: bpin.location().position().y - measure(sum).height,
  //     sum,
  //   )
  // }
}

/// Marks awarded for [Method].
#let method = marker.with("M")
/// Marks awarded for [Method].
#let m = method

/// Marks awarded for an [Answer] or for [Accuracy].
#let accuracy = marker.with("A")
/// Marks awarded for an [Answer] or for [Accuracy].
#let a = accuracy

/// Marks awarded for [Correct] answers (irrespective of working shown).
#let correct = marker.with("C")
/// Marks awarded for [Correct] answers (irrespective of working shown).
#let c = correct

/// Marks awarded for clear [Reasoning].
#let reasoning = marker.with("R")
/// Marks awarded for clear [Reasoning].
#let r = reasoning

/// Shows that marks are awarded as [follow through] from previous results in the question.
#let follow-through = marker.with("ft", none)
/// Shows that marks are awarded as [follow through] from previous results in the question.
#let ft = follow-through

/// Shows that 0 mark is awarded for lack of attempt, "[no attempt]".
#let no-attempt = marker.with("na", 0)
/// Shows that 0 mark is awarded for lack of attempt, "[no attempt]".
#let na = no-attempt

