#import "../logic/scale.typ" as lqscale
#import "../utility.typ": place-in-out, match, match-type, if-auto, if-none
#import "../algorithm/ticking.typ"
#import "../bounds.typ": *
#import "../assertations.typ"
#import "../model/label.typ": xlabel, ylabel, label as lq-label
#import "../process-styles.typ": update-stroke, merge-strokes
#import "../libs/elembic/lib.typ" as e

#import "tick.typ": tick as lq-tick, tick-label as lq-tick-label
#import "spine.typ": spine

#import "@preview/zero:0.3.3"
#import "@preview/tiptoe:0.3.0"



/// An axis for a diagram. Visually, an axis consists of a _spine_ along the axis 
/// direction, a collection of ticks/subticks and an axis label. 
/// 
/// By default, a @diagram features two axes: an `x` and a `y` axis which can be 
/// configured directly through @diagram.xaxis and @diagram.yaxis. However, it is 
/// also possible to add more axes, please refer to the 
/// #link("tutorials/axis")[axis tutorial] for more details. 
/// 
/// The built-in tick formatters use the Typst package
/// #link("https://typst.app/universe/package/zero")[Zero] for displaying
/// numbers. This makes it possible to define a consistent number format 
/// throughout the entire document, including tables, in-text quantities,
/// and figures. 
#let axis(

  /// Sets the scale of the axis. This may be a @scale object or the name of 
  /// one of the built-in scales `"linear"`, `"log"`, `"symlog"`.
  /// -> lq.scale | str 
  scale: "linear", 

  /// Data limits of the axis. This can be used to fix the minimum and/or maximum value
  /// displayed along this axis. This parameter expects `auto` or a tuple `(min, max)` 
  /// where `min` and `max` can also be `auto`. If a limit is `auto`, it will be 
  /// automatically computed from all plots associated with this axis and @diagram.margin 
  /// will be applied. If the minimum is larger than the maximum, the scale is inverted
  /// and if `min` and `max` coincide, the range will be automatically increased. 
  /// Also see @axis.inverted. 
  /// -> auto | array
  lim: auto,

  /// Whether to invert the limits (swap minimum and maximum). Inverting is 
  /// applied regardless of whether the limits are set manually or computed automatically. 
  /// -> bool
  inverted: false,

  /// Label for the axis. Use a @label object for more options. 
  /// -> content | lq.label
  label: none,

  /// The kind of the axis. 
  /// -> "x" | "y"
  kind: "x", 

  /// Where to place this axis. This can be 
  /// - one of the sides of the diagram (`top` or `bottom` for $x$-axes, 
  ///   `left` or `right` for $y$-axes), 
  /// - a `float` coordinate value on the other axis,
  /// - a `length` or `relative`,
  /// - or a combination of the first and third option through a dictionary 
  ///   with the keys `align` and `offset`. 
  /// 
  /// More on axis placement can be found in the 
  /// #link("tutorials/axis#placement-and-mirrors")[axis tutorial]. 
  /// -> auto | alignment | float | relative | dictionary
  position: auto, 

  /// How to stroke the spine of the axis. If not `auto`, this is forwarded to 
  /// @spine.stroke. 
  /// -> auto | stroke
  stroke: auto,

  /// Whether to mirror the axis, i.e., whether to show the axis ticks also on 
  /// the side opposite of the one specified with @axis.position. When set to 
  /// `auto`, mirroring is only activated when `position: auto`. More control
  /// is granted through a dictionary with the possible keys `ticks` and 
  /// `tick-labels` to individually activate or deactivate those. 
  /// 
  /// More on axis mirrors can be found in the 
  /// #link("tutorials/axis#placement-and-mirrors")[axis tutorial]. 
  /// -> auto | bool | dictionary
  mirror: auto,

  /// Specifies conversions between the data and the ticks. This can be used to
  /// configure a secondary axis to display the same data in a different unit, 
  /// e.g., the main axis displays the velocity of a particle while the 
  /// secondary axis displays the associated energy. In this case, one would 
  /// pick `functions: (x => m*x*x, y => calc.sqrt(y/m))` with some constant
  /// `m`. Note that the first function computes the "forward" direction while
  /// the second function computes the "backward" direction. The user needs to 
  /// ensure that the two functions are really inverses of each other. 
  /// By default, this parameter resolves to the identity. 
  /// -> auto | array
  functions: auto,

  /// The tick locator for the (major) ticks. 
  /// -> auto | function
  locate-ticks: auto,
  
  /// The formatter for the (major) ticks. 
  /// -> auto | function
  format-ticks: auto,
  
  /// The tick locator for the subticks. 
  /// -> auto | function
  locate-subticks: auto,
  
  /// The formatter for the subticks. 
  /// -> auto | none | function
  format-subticks: none,

  /// An array of extra ticks to display. The ticks can be positions given as `float` or `lq.tick` objects. 
  /// TODO: not implemented yet
  /// -> array
  extra-ticks: none, 

  /// The formatter for the extra ticks. 
  format-extra-ticks: none,

  /// Arguments to pass to the tick locator. 
  /// -> dictionary
  tick-args: (:),

  /// Arguments to pass to the subtick locator. 
  /// -> dictionary
  subtick-args: (:),

  /// Instead of using the tick locator, specifies the tick locations explicitly and optionally the tick labels. This can be an array with just the tick location or tuples of tick location and label, or a dictionary with the keys `ticks` and `labels`, containing arrays of equal length. When `ticks` is `none`, no ticks are displayed. If it is `auto`, the `tick-locator` is used. 
  /// -> auto | array | dictionary | none
  ticks: auto, 

  /// Instead of using the tick locator, specifies the tick positions explicitly and optionally the tick labels.
  /// -> auto | array | dictionary | none
  subticks: auto,

  /// Passes the parameter `tick-distance` to the tick locator. The linear tick locator respects this setting and sets the distance between consecutive ticks accordingly. If `tick-args` already contains an entry `tick-distance`, it takes precedence. 
  /// -> auto | float
  tick-distance: auto, 

  /// Offset for all ticks on this axis. The offset is subtracted from all ticks and shown at the end of the axis (if it is not 0). An offset can be used to avoid overly long tick labels and to focus on the relative distance between data points. 
  /// -> auto | float
  offset: auto,

  /// Exponent for all ticks on this axis. All ticks are divided by $10^\mathrm{exponent}$ and the $10^\mathrm{exponent}$ is shown at the end of the axis (if the exponent is not 0). This setting can be used to avoid overly long tick labels. 
  /// 
  /// In combination with logarithmic tick locators, `none` can be used to 
  /// force writing out all numbers. 
  /// -> auto | none | int | "inline"
  exponent: auto,

  /// Threshold for automatic exponents. 
  /// -> int
  auto-exponent-threshold: 3,

  /// If set to `true`, the entire axis is hidden. 
  /// -> bool
  hidden: false,

  /// Places an arrow tip on the axis spine. This expects a mark as specified by
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.tip. 
  /// -> auto | none | tiptoe.mark
  tip: auto,

  /// Places an arrow tail on the axis spine. This expects a mark as specified by 
  /// the #link("https://typst.app/universe/package/tiptoe")[tiptoe package]. 
  /// If not `auto`, this is forwarded to @spine.toe. 
  /// -> auto | none | tiptoe.mark
  toe: auto,

  filter: (value, distance) => true,

  /// Plot objects to associate with this axis. This only applies when this is a secondary axis. Automatic limits are then computed according to this axis and transformations of the data coordinates linked to the scaling of this axis. 
  /// -> any
  ..plots
  
) = {
  assertations.assert-no-named(plots)
  plots = plots.pos()
  if "tick-distance" not in tick-args {
    tick-args.tick-distance = tick-distance
  }
  if type(scale) == str {
    assert(scale in lqscale.scales, message: "Unknown scale " + scale)
    scale = lqscale.scales.at(scale)
  }
  assert(kind in ("x", "y"), message: "The `kind` of an axis can only be `x` or `y`")
  let translate = (0pt, 0pt)


  if position == auto {
    if kind == "x" { position = bottom }
    else if kind == "y" { position = left }
  } else if type(position) in (int, float, length, relative, ratio) {
    if kind == "x" { 
      translate = (0pt, position)
      position = bottom 
    }
    else if kind == "y" { 
      translate = (position, 0pt)
      position = left 
    }
    if mirror == auto { mirror = none }
  } else if type(position) == dictionary {
    assertations.assert-dict-keys(position, mandatory: ("align", "offset"))

    
    (position, translate) = (position.align, position.offset)
    if kind == "x" { translate = (0pt, translate) }
    else if kind == "y" { translate = (translate, 0pt) }
    if mirror == auto { mirror = none }
    
    if kind == "x" {
      assert(position in (top, bottom), message: "For x-axes, `position` can only be \"top\" or \"bottom\", got " + repr(position))
    }
    if kind == "y" {
      assert(position in (left, right), message: "For y-axes, `position` can only be \"left\" or \"right\", got " + repr(position))
    }
  } else if type(position) == alignment {
    if mirror == auto { mirror = none }
    
    if kind == "x" {
      assert(position in (top, bottom), message: "For x-axes, `position` can only be \"top\" or \"bottom\", got " + repr(position))
    }
    if kind == "y" {
      assert(position in (left, right), message: "For y-axes, `position` can only be \"left\" or \"right\", got " + repr(position))
    }
  } else {}

  if ticks != auto {
    if type(ticks) == dictionary {
      assert("ticks" in ticks, message: "When passing a dictionary for `ticks`, you need to provide the keys \"ticks\" and optionally \"labels\"")
      locate-ticks = ticking.locate-ticks-manual.with(..ticks)
      if "labels" in ticks {
        format-ticks = ticking.format-ticks-manual.with(labels: ticks.labels) 
      }
    } else if type(ticks) == array {
      if ticks.len() > 0 and type(ticks.first()) == array {
        let (ticks, labels) = array.zip(..ticks)
        locate-ticks = ticking.locate-ticks-manual.with(ticks: ticks)
        format-ticks = ticking.format-ticks-manual.with(labels: labels) 
      } else {
        locate-ticks = ticking.locate-ticks-manual.with(ticks: ticks)
      }
    } else if ticks == none {
      locate-ticks = none
      format-ticks = none
    } else { assert(false, message: "The parameter `ticks` may either be an array or a dictionary")}
  }
  
  if locate-ticks == auto {
    locate-ticks = if-none(scale.locate-ticks, ticking.locate-ticks-linear)
  }
  if format-ticks == auto {
    format-ticks = match(
      scale.name,
      "linear", () => ticking.format-ticks-linear,
      "log", () => ticking.format-ticks-log.with(base: scale.base),
      "symlog", () => ticking.format-ticks-linear,
      default: () => ticking.format-ticks-naive
    )
  }
  if subticks == none {
    locate-subticks = none
  } else if type(subticks) == int {
    locate-subticks = ticking.locate-subticks-linear.with(num: subticks)
  } else if subticks != auto {
    assert(false, message: "Unsupported argument type `" + str(type(subticks)) + "` for parameter `subticks`")
  }
  if locate-subticks == auto {
    locate-subticks = if-none(scale.locate-subticks, none)
  }
  let is-independant = plots.len() > 0
  if functions == auto { functions = (x => x, x => x) }
  else {
    assert(type(functions) == array and functions.map(type) == (function, function), message: "The parameter `functions` for `axis()` expects an array of two functions, a forward and an inverse function.")
    assert(plots.len() == 0, message: "An `axis` can either be created with `functions` or with `..plots` but not both. ")
    assert(lim == auto, message:  "A dependent `axis` with `functions` is not allowed to have manual axis limits. ")
  }

  if type(lim) == array {
    assert.eq(lim.len(), 2, message: "Limit arrays must contain exactly two items")
    
  } else if lim == auto { 
    lim = (auto, auto)
  } else {
    assert(false, message: "Unsupported limit specification")
  }

  if mirror == auto {
    mirror = (ticks: true)
  } else if type(mirror) == bool {
    if mirror { mirror = (ticks: true) }
    else { mirror = none }
  } else if type(mirror) == dictionary {
    for key in mirror.keys() {
      assert(key in ("ticks", "tick-labels"), message: "When passing a dictionary to `axis.mirror`, only the keys \"ticks\" and \"tick-labels\" are valid, got \"" + key + "\"")
    }
  }
  
  (
    type: "axis",
    scale: scale,
    lim: lim,
    functions: (forward: functions.at(0), inv: functions.at(1)),
    label: label,
    stroke: stroke,
    kind: kind,
    position: position,
    translate: translate,
    mirror: mirror,
      
    locate-ticks: locate-ticks,
    format-ticks: format-ticks,
    locate-subticks: locate-subticks,
    format-subticks: format-subticks,
    extra-ticks: extra-ticks,
    format-extra-ticks: format-extra-ticks,

    filter: filter,

    tick-args: tick-args,
    subtick-args: subtick-args,

    offset: offset,
    exponent: exponent,
    auto-exponent-threshold: auto-exponent-threshold,
    plots: plots,
    hidden: hidden,
    tip: tip,
    toe: toe,

    inverted: inverted
  )
}

#let xaxis = axis.with(kind: "x")
#let yaxis = axis.with(kind: "y")


/// Computes the axis limits of one axis (x or y). For each plot, `xlimits()` 
/// and `ylimits()` is called. Plots whose limit functions return `none`  
/// will be ignored. 
/// If there are no plots or all calls to `xlimits()` and 
/// `ylimits()` return `none`, the limits are set to `(0,0)`.
///
/// Regardless of this, a zero-width range is enlarged by calling 
/// `next(min, -1)` and `next(max, 1)`. 
/// Finally lower and upper margins are applied. 
///
#let _axis-compute-limits(
  axis, 
  lower-margin: 0%, upper-margin: 0%,
  default-lim: (0, 1),
  is-independant: auto
) = {
  if is-independant == auto {
    is-independant = axis.plots.len() > 0
  }
  let axis-type = match(axis.kind, "x", "x", "y", "y")
  let (x0, x1) = (none, none)
  let (tight0, tight1) = (true, true)
  

  if axis.lim.at(0) != auto { x0 = axis.lim.at(0); tight0 = true }
  if axis.lim.at(1) != auto { x1 = axis.lim.at(1); tight1 = true }
  
  if auto in axis.lim {
    if is-independant {
      let plot-limits = axis.plots.map(plot => plot.at(axis-type + "limits")())
        .filter(x => x != none)
      if plot-limits.len() == 0 {
        (x0, x1) = (0, 1)
        if axis.scale.identity != 0 {
          (x0, x1) = (axis.scale.identity,) * 2
        }
      } else {
        for (plot-x0, plot-x1) in plot-limits {
          let tight-bound = (false, false)
          if type(plot-x0) == fraction { plot-x0 /= 1fr; tight-bound.at(0) = true }
          if axis.lim.at(0) == auto and plot-x0 != none and (x0 == none or plot-x0 < x0) {
            x0 = plot-x0
            tight0 = tight-bound.at(0)
          }
          if type(plot-x1) == fraction { plot-x1 /= 1fr; tight-bound.at(1) = true }
          if axis.lim.at(1) == auto and plot-x0 != none and (x1 == none or plot-x1 > x1) {
            x1 = plot-x1
            tight1 = tight-bound.at(1)
          }
        }
      }
    } else {
      (x0, x1) = default-lim.map(axis.functions.forward)
    }
  }
  if x0 == x1 {
    x0 = (axis.scale.inverse)((axis.scale.transform)(x0) - 1)
    x1 = (axis.scale.inverse)((axis.scale.transform)(x1) + 1)
  }



  let k0 = (axis.scale.transform)(x0)
  let k1 = (axis.scale.transform)(x1)
  let D = k1 - k0

  if axis.inverted {
    (x0, x1) = (x1, x0)
  }

  if not tight0 {
    x0 = (axis.scale.inverse)(k0 - D * lower-margin/100%)
  }
  if not tight1 {
    x1 = (axis.scale.inverse)(k1 + D * upper-margin/100%)
  }

  return (x0, x1)
}


/// Generates all ticks and subticks as well as their labels for an axis. 
/// 
/// -> dictionary
#let _axis-generate-ticks(
  /// The axis object. 
  /// -> lq.axis
  axis, 
  
  /// The length with which the axis will be displayed. This is for example used to determine automatic tick distances. 
  /// -> length
  length: 3cm
) = {
  let ticks = ()
  let tick-labels
  let subticks = (ticks: ())
  let subtick-labels
  let (exp, offset) = (axis.exponent, axis.offset)

  let em = measure(line(length: 1em, angle: 0deg)).width
  axis.tick-args.num-ticks-suggestion = match(
    axis.kind,
    "x", length / (3.3 * em),
    "y", length / (2 * em)
  )
  let (x0, x1) = axis.lim

  if x0 != none {
    if axis.locate-ticks != none {
      let tick-info = (axis.locate-ticks)(x0, x1, ..axis.tick-args)
      ticks = tick-info.ticks
      (tick-labels, exp, offset) = match(
        axis.format-ticks,
        none, (none, 0, 0),
        default: () => (axis.format-ticks)(tick-info, exponent: axis.exponent, offset: axis.offset, auto-exponent-threshold: axis.auto-exponent-threshold),
      )
      

      if axis.locate-subticks != none {
        subticks = (axis.locate-subticks)(x0, x1, ..tick-info, ..axis.subtick-args)
        subtick-labels = match(
        axis.format-subticks,
        none, none,
        default: () => (axis.format-subticks)(ticks: subticks, exponent: axis.exponent, offset: axis.offset).at(0),
      )
      }
    } 
  }

  return (
    ticks: ticks,
    tick-labels: tick-labels,
    subticks: subticks.ticks,
    subtick-labels: subtick-labels,
    exp: exp,
    offset: offset
  )
}




#let draw-axis(
  axis,
  ticking,
  axis-style,
  e-get: none
) = {
  if axis.hidden { return (none, ()) }


  let (ticks, tick-labels, subticks, subtick-labels, exp, offset) = ticking
  
  let transform = axis.transform

  let place-tick 
  let place-exp-or-offset
  let exp-or-offset-alignment
  let exp-or-offset-offset
  
  if axis.kind == "x" {
    place-tick = (x, label, position, inset, outset, stroke: axis.stroke) => {
      if axis.stroke != none {
        place-in-out(position, 
          line(length: inset + outset, angle: 90deg, stroke: stroke), 
          dx: x, dy: outset,
        )
      }
      if label == none { return }
  
      place-in-out(position, 
        place(center + position.inv().y, label), 
        dx: x, dy: .5em + outset
      )
    }
    place-exp-or-offset = it => place(horizon + right, dx: .5em, dy: 0pt, place(left + horizon, it))
    exp-or-offset-alignment = (alignment: bottom + right, content-alignment: horizon + left)
    exp-or-offset-offset = (dx: .5em, dy: 0pt)
  } else if axis.kind == "y" {
    place-tick = (y, label, position, inset, outset, stroke: axis.stroke) => {
      place(position, 
        line(length: inset + outset, stroke: stroke), 
        dy: y, dx: -outset
      )
      if label == none { return }
      
      let size = measure(label)
      let dx = size.width * 0
      place-in-out(position, 
        place(position.inv() + horizon, label), 
        dx: -dx - .5em + outset, dy: y,
      )
    }
    place-exp-or-offset = it => place(top + center, dx: 0pt, dy: -.5em, place(bottom + center, it))
    exp-or-offset-alignment = (alignment: top + left, content-alignment: center + bottom)
    exp-or-offset-offset = (dx: 0pt, dy: -.5em)
  }



  let place-ticks(
    ticks, labels, 
    position, 
    display-tick-labels, 
    sub: false,
    kind: "x"
  ) = {
    if labels == none { labels = (none,) * ticks.len() }

    // let dim = if axis.kind == "x" { "height" } else { "width" }
    // let content = ticks.zip(labels).map(
    //   ((tick, label)) => {
    //     let loc = transform(tick)
    //     let max = transform(axis.lim.at(if kind == "x" {1} else {0}))
    //     if not (axis.filter)(tick, calc.min(loc, max - loc)) { return }
    //     place-tick(loc, if not display-tick-labels {none} else {label}, position, length-coeff*axis-style.inset, length-coeff*axis-style.outset)
    //   }
    // ).join()
    
    // let max-padding = axis-style.outset
    // if display-tick-labels {
    //   let label-space = calc.max(..labels.map(label => measure(label).at(dim)), 0pt)
    //   max-padding += label-space
    //   if label-space > 0pt {
    //     max-padding += .5em
    //   }
    // }
    
    let align = position.inv()
    let pad = e-get(lq-tick).pad
    let factor = if sub { e-get(lq-tick).shorten-sub } else { 1 }
    let outset = e-get(lq-tick).outset * factor
    let shorten-sub = e-get(lq-tick).shorten-sub
    let length = e-get(lq-tick).inset * factor + outset
    let angle = if align in (top, bottom) { 90deg } else { 0deg }
  
    let tick-stroke = merge-strokes(e-get(lq-tick).stroke, axis.stroke, (cap: "butt"), e-get(spine).stroke)
    if tick-stroke == none {
      // can happen when spine.stroke is none
      tick-stroke = 0.5pt
    }

    let tline = line(length: length, angle: angle, stroke: tick-stroke)
    let make-tick
    if align == right {
      make-tick = (label, loc) => place(dx: -outset, dy: loc, {tline + place(dx: -length - pad, right + horizon, label)})
    } else if align == left {
      make-tick = (label, loc) => place(dx: -length + outset, dy: loc, {tline + place(dx: length + pad, left + horizon, label)})
    } else if align == top {
      make-tick = (label, loc) => place(dy: -length + outset, dx: loc, {tline + place(dy: length + pad, top + center, label)});
    } else if align == bottom {
      make-tick = (label, loc) => place(dy: -outset, dx: loc, {tline + place(dy: -length - pad, bottom + center, label)})
    }

    let max = transform(axis.lim.at(if kind == "x" { 1 } else { 0 }))

    let content = ticks.zip(labels).map(
      ((tick, label)) => {
        let loc = transform(tick)
        if not (axis.filter)(tick, calc.min(loc, max - loc)) { return }
        let tick-label = if display-tick-labels { label }
        if tick-label != none {tick-label = lq-tick-label(tick-label)}
        make-tick(tick-label, loc)
      }
    ).join()

    let max-padding = outset
    if display-tick-labels {
      let dim = if axis.kind == "x" { "height" } else { "width" }
      let label-space = calc.max(..labels.map(label => measure(label).at(dim)), 0pt)
      max-padding += label-space
      if label-space > 0pt {
        max-padding += pad
      }
    }

    
    return (content, max-padding)
  }
  

  let the-axis(
    position: axis.position,
    translate: (0pt, 0pt),
    display-ticks: true, 
    display-tick-labels: true, 
    display-axis-label: true,
    kind: "x"
  ) = {
    let content = none
    let max-padding = 0pt
    let bounds = ()
    if axis.stroke != none {
      // later: use set rules here
      let args = (:)
      if axis.tip != auto { args.tip = axis.tip }
      if axis.toe != auto { args.toe = axis.toe }
      if axis.stroke != auto { args.stroke = axis.stroke }
      content += place(spine(kind: axis.kind, ..args))
    }

    if display-ticks {
      let (c, mp) = place-ticks(ticks, tick-labels, position, display-tick-labels, kind: kind)
      content += c
      max-padding = mp

      let (c, mp) = place-ticks(subticks, subtick-labels, position, display-tick-labels, sub: true, kind: kind)
      content += c

      if axis.extra-ticks != none {
        for tick in axis.extra-ticks {
          
          if type(tick) in (int, float) {
            tick = lq-tick(tick)
          } 
          content += place-tick(transform(tick.value), tick.label, position, tick.inside, tick.outside, stroke: if-auto(tick.stroke, axis.stroke))
        }
      }
    }
    if display-tick-labels {
      if type(exp) == int and exp != 0 {
        let (c, b) = place-with-bounds(
          {
            show "X": none
            zero.num("Xe" + str(exp))
          },
          ..exp-or-offset-offset, 
          ..exp-or-offset-alignment
        )
        content += c
        b = offset-bounds(b, translate)
        bounds.push(b)
      }
      if type(offset) in (int, float) and offset != 0 {
        let (c, b) = place-with-bounds(
          zero.num(positive-sign: true, offset), 
          ..exp-or-offset-offset, 
          // ..exp-or-offset-alignment
        )
        content += c
        b = offset-bounds(b, translate)
        bounds.push(b)
      }
    }
    
    if axis.label != none and display-axis-label {
      
      let get-settable-field(element, object, field) = {
        e.fields(object).at(field, default: e-get(element).at(field))
      }
      let label = axis.label
      if e.eid(label) != e.eid(lq-label) {
        let constructor = if kind == "x" {xlabel} else {ylabel}
        label = constructor(label)
      }
      let wrapper = if position in (top, bottom) {
        box.with(width: 100%)
      } else if position in (left, right) {
        box.with(height: 100%)
      }

      let dx = get-settable-field(lq-label, label, "dx")
      let dy = get-settable-field(lq-label, label, "dy")
      let pad = get-settable-field(lq-label, label, "pad")
      if pad == none { pad = 0pt }
      else { pad += max-padding }


      let body = wrapper(label)
      let size = measure(body)

      let (label, b) = place-with-bounds(body, alignment: position, dx: dx, dy: dy, pad: pad)
      
      content += label
      if kind == "x" {
        max-padding = size.height + pad
      } else {
        max-padding = size.width + pad
      }
    }
    // define box of axis spine
    content += block(
      ..if kind == "y"{ (height: 100%, width: 0%) }
        else{ (width:100%, height: 0pt) },
      inset: 0pt, outset: 0pt
    )
    
    let main-bounds = create-bounds()
    if axis.kind == "x" {
      main-bounds.right = 100%
      if position == top {
        main-bounds.top = -max-padding
        main-bounds.bottom = axis-style.inset
      } else if position == bottom {
        main-bounds.bottom = 100% + max-padding
        main-bounds.top = 100% - axis-style.inset
      }
    } else {
      main-bounds.bottom = 100%
      if position == left {
        main-bounds.left = -max-padding
        main-bounds.right = axis-style.inset
      } else if position == right {
        main-bounds.right = 100% + max-padding
        main-bounds.left = 100% - axis-style.inset
      }
    }
    main-bounds = offset-bounds(main-bounds, translate)
    bounds.push(main-bounds)
    return (content, bounds)
  }

  let (axis-content, bounds) = the-axis(kind: axis.kind, translate: axis.translate)
  let content = place(axis.position, axis-content, dx: axis.translate.at(0), dy: axis.translate.at(1))
  let em = measure(line(length: 1em, angle: 0deg)).width
  
  // let a = measure(lq-tick-label(box(width: 1em))).width
  // content += repr(a) + " " + repr(1em.to-absolute())
  if axis.mirror != none {
    let (mirror-axis-content, mirror-axis-bounds) = the-axis(
      kind: axis.kind,
      position: axis.position.inv(),
      translate: axis.translate,
      display-ticks: axis.mirror.at("ticks", default: false),
      display-tick-labels: axis.mirror.at("tick-labels", default: false),
      display-axis-label: axis.mirror.at("label", default: false),
    )
    content += place(axis.position.inv(), mirror-axis-content)
    bounds += mirror-axis-bounds
  }
  
  return (content, bounds)
}
