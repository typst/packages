#let pin-number-text(settings, s) = align(center + horizon, text(settings.pin-number-size)[#s])
#let pin-label-text(settings, s) = text(settings.pin-label-size)[#s]

#let pin-num-left(settings, s) = align(center, rotate(90deg, reflow: true)[#pin-number-text(settings, s)])
#let pin-num-right(settings, s) = align(center, rotate(-90deg, reflow: true)[#pin-number-text(settings, s)])

#let order(settings, lst) = if settings.side == left { lst } else { lst.rev() }

#let for-numbering(settings, v) = if settings.include-number { (v,) } else { () }

#let render-number(settings, index) = align(horizon, if settings.side == left {pin-num-left(settings, index + 1)} else {pin-num-right(settings, index + 1)})

#let pin-number-size(settings) = if settings.include-number { settings.pin-number-size + settings.pin-number-margin } else { 0in }

#let pin(settings, index, label) = box(
  width: settings.width, height: settings.height,
)[
  #grid(
      inset: if settings.include-number { 0in } else { settings.pin-number-margin },
      columns: order(settings, (for-numbering(settings, pin-number-size(settings)) + (settings.width - pin-number-size(settings),))),
      rows: (settings.height),
      ..order(settings, (for-numbering(settings, render-number(settings, index)) +
      (align(horizon + settings.side, pin-label-text(settings, label)),)))
    )
]

#let default-settings(settings, side, width) = (
  width: width/2,
  height: settings.at("pin-spacing", default: 0.1in),
  side: side,
  include-number: settings.at("include-number", default: true),
  pin-number-margin: settings.at("pin-number-margin", default: 0.5pt),
  pin-number-size: settings.at("pin-number-size", default: 2pt),
  pin-label-size: settings.at("pin-label-size", default: 3pt))

#let dip-chip-label(count, width, labeling, chip-label, settings: ("": 0)) = rect(inset: 0in, stroke: 0.2pt,
  box(width: width, height: settings.at("vertical-margin", default: 0.04in) + count / 2 * settings.at("pin-spacing", default: 0.1in))[
    #align(horizon,
    grid(
      gutter: 0in,
      // stroke: 0.2pt + rgb(red),
      columns: (width/2, 0in, width/2),
      rows: (auto),
      grid(
        gutter: 0in,
        rows: (settings.at("pin-spacing", default: 0.1in),),
        ..range(int(count/2)).map(v => pin(default-settings(settings, left, width), v, labeling.at(v, default: "")))
      ),
      align(horizon, rotate(-90deg, align(center, text(settings.at("chip-label-size", default: 3pt))[#chip-label]))),
      grid(
        gutter: 0in,
        rows: (settings.at("pin-spacing", default: 0.1in),),
        ..range(int(count/2), count).map(v => pin(default-settings(settings, right, width), v, labeling.at(v, default: ""))).rev()
      )
    ))
  ]
)
