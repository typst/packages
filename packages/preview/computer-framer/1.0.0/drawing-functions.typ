#import "./utils.typ": *

// Retro
#let retro-theme(
  inset: .2em,
  background-color: rgb(212, 208, 200),
  header-color: gradient.linear(dir: ltr, (rgb(0, 0, 124), 0%), (rgb(17, 141, 227), 100%)),
  button-colors: (rgb(212, 208, 200), rgb(212, 208, 200), rgb(212, 208, 200)),
  font: "Microsoft Sans Serif",
  font-size: 1em,
  text-color: white,
  bevel-light: white + 0.1em,
  bevel-dark: black + 0.1em,
  content-inset: 0em,
  header-height: 1.4em,
  button-scale: 100%,
) = {
  (
    background-color: background-color,
    stroke: bevel-dark,
    buttons: box(stack(
      dir: ltr,
      spacing: 0.15em + (1.15em * (button-scale - 100%)),
      scale(button-scale, box(
        height: 1em,
        width: 1em,
        align(center + horizon, move(dy: 0.2em, line(length: 0.4em, stroke: 0.15em))),
        fill: button-colors.at(0),
        stroke: (top: bevel-light, left: bevel-light, bottom: bevel-dark, right: bevel-dark),
      )),
      scale(button-scale, box(
        height: 1em,
        width: 1em,
        align(center + horizon, move(dy: 0.025em, box(width: 0.6em, height: 0.6em, stroke: (
          top: 0.15em,
          left: 0.07em,
          bottom: 0.07em,
          right: 0.07em,
        )))),
        fill: button-colors.at(1),
        stroke: (top: bevel-light, left: bevel-light, bottom: bevel-dark, right: bevel-dark),
      )),
      scale(button-scale, box(
        height: 1em,
        width: 1em,
        align(center + horizon, move(dy: 0.1em, text(1.75em, bottom-edge: "bounds", top-edge: "bounds", text(
          font: "Libertinus Serif",
          sym.times,
        )))),
        fill: button-colors.at(2),
        stroke: (top: bevel-light, left: bevel-light, bottom: bevel-dark, right: bevel-dark),
      )),
    )),
    windows-frame: block.with(fill: background-color, inset: inset, stroke: (
      top: bevel-light,
      left: bevel-light,
      bottom: bevel-dark,
      right: bevel-dark,
    )),
    content-frame: it => {
      set text(font: font, size: font-size)
      block(
        fill: background-color,
        inset: (top: inset + content-inset, x: 0.05em + content-inset, bottom: 0.05em + content-inset),
        block(
          fill: white,
          stroke: (
            top: bevel-dark,
            left: bevel-dark,
            bottom: bevel-light,
            right: bevel-light,
          ),
          it,
        ),
      )
    },
    content-color: white,
    header-bar: (content, i: 0, total-bars: 1) => {
      grid.cell(
        fill: if i == 0 { header-color } else { background-color },
        inset: if i == 0 { (x: 0.25em, y: header-height / 2) } else { 0pt },
        content,
      )
    },
    title-wrapper: it => {
      set text(fill: text-color, font: font, size: font-size, weight: "bold")
      box(inset: (x: 0.25em), it)
    },
    title-align: left,
    buttons-align: right,
  )
}

#let rounded-corner-radius(radius-amount, rounded-bottom) = {
  let corner-radius = radius-amount
  if (not rounded-bottom) {
    corner-radius = (top-left: radius-amount, top-right: radius-amount)
  }
  corner-radius
}

#let rounded-window-buttons(
  button-colors,
  button-contents,
  button-size: 1em,
  button-radius: 100%,
  button-spacing: 0.1em,
  button-stroke: none,
) = {
  box(stack(
    dir: ltr,
    spacing: button-spacing,
    box(
      height: button-size,
      width: button-size,
      radius: button-radius,
      fill: button-colors.at(0),
      stroke: button-stroke,
      button-contents.at(0),
    ),
    box(
      height: button-size,
      width: button-size,
      radius: button-radius,
      fill: button-colors.at(1),
      stroke: button-stroke,
      button-contents.at(1),
    ),
    box(
      height: button-size,
      width: button-size,
      radius: button-radius,
      fill: button-colors.at(2),
      stroke: button-stroke,
      button-contents.at(2),
    ),
  ))
}

#let rounded-window-theme(
  radius-amount: 0.5em,
  rounded-bottom: true,
  header-color: luma(95%),
  header-stroke: (bottom: 2pt),
  button-colors: (white, white, red),
  button-contents: (
    align(center + horizon, text(baseline: 0.25em, top-edge: "bounds", bottom-edge: "bounds", sym.minus)),
    align(center + horizon, text(top-edge: "bounds", bottom-edge: "bounds", sym.square)),
    align(center + horizon, text(baseline: 0.05em, top-edge: "bounds", bottom-edge: "bounds", sym.times)),
  ),
  font: "Roboto",
  font-size: 1em,
  text-color: black,
  window-fill: none,
  window-stroke: 2pt,
  content-fill: white,
  content-stroke: none,
  content-inset: 0pt,
  content-radius: 0%,
  header-inset: (x: 0.25em, y: 0.7em),
  title-inset: (x: 0.25em),
  title-weight: 400,
  content-font-size: none,
  title-align: center,
  buttons-align: right,
  button-size: 1em,
  button-radius: 20%,
  button-spacing: 0.2em,
  button-stroke: 1pt,
) = {
  (
    background-color: window-fill,
    stroke: window-stroke,
    buttons: rounded-window-buttons(
      button-colors,
      button-contents,
      button-size: button-size,
      button-radius: button-radius,
      button-spacing: button-spacing,
      button-stroke: button-stroke,
    ),
    windows-frame: block.with(
      width: auto,
      clip: true,
      radius: rounded-corner-radius(radius-amount, rounded-bottom),
      fill: window-fill,
      stroke: window-stroke,
    ),
    content-frame: it => {
      block(fill: window-fill, inset: content-inset, block(
        fill: content-fill,
        stroke: content-stroke,
        radius: content-radius,
        [
          #set text(fill: text-color, font: font)
          #it],
      ))
    },
    content-color: content-fill,
    header-bar: (content, i: 0, total-bars: 1) => grid.cell(
      inset: if i == 0 { header-inset } else { 0pt },
      fill: header-color,
      stroke: if i == (total-bars - 1) { header-stroke } else { none },
      content,
    ),
    title-wrapper: it => {
      set text(fill: text-color, font: font, size: font-size, weight: title-weight)
      box(inset: title-inset, it)
    },
    title-align: title-align,
    buttons-align: buttons-align,
  )
}

// Purple
#let purple-theme(
  radius-amount: 0.75em,
  rounded-bottom: true,
  header-color: luma(50%),
  button-scale: 100%,
  button-colors: (rgb("#9a9a9a"), rgb("#9a9a9a"), rgb("#e56d2c")),
  font: "Noto Sans",
  font-size: 0.75em,
  text-color: white,
  header-height: 1.4em,
) = {
  rounded-window-theme(
    header-stroke: none,
    window-stroke: none,
    radius-amount: radius-amount,
    rounded-bottom: rounded-bottom,
    window-fill: header-color,
    header-color: header-color,
    button-colors: button-colors,
    button-stroke: none,
    button-radius: 100%,
    button-contents: (
      align(center + horizon, scale(button-scale, text(
        baseline: 0.25em,
        top-edge: "bounds",
        bottom-edge: "bounds",
        text(
          font: "Libertinus Serif",
          sym.minus,
        ),
      ))),
      align(center + horizon, scale(button-scale, text(top-edge: "bounds", bottom-edge: "bounds", text(
        font: "Libertinus Serif",
        sym.square,
      )))),
      align(center + horizon, scale(button-scale, text(
        baseline: 0.05em,
        top-edge: "bounds",
        bottom-edge: "bounds",
        text(
          font: "Libertinus Serif",
          sym.times,
        ),
      ))),
    ),
    font: font,
    font-size: font-size,
    text-color: text-color,
    content-fill: rgb(48, 10, 36),
    content-font-size: font-size,
    header-inset: (x: 0.25em, y: header-height / 2),
    button-size: 1em * button-scale,
  )
}

// Minimalistic
#let minimalistic-theme(
  radius-amount: 0.65em,
  rounded-bottom: true,
  header-color: luma(95%),
  button-colors: (rgb("#FF5F58"), rgb("#FFBE2F"), rgb("#2AC940")),
  button-scale: 100%,
  font: "SF Pro",
  font-size: 0.75em,
  text-color: luma(15.3%),
  content-color: luma(98%),
  header-height: 1.2em,
) = {
  rounded-window-theme(
    radius-amount: radius-amount,
    rounded-bottom: rounded-bottom,
    header-color: header-color,
    header-stroke: none,
    button-colors: button-colors,
    button-contents: ("", "", ""),
    font: font,
    font-size: font-size,
    text-color: text-color,
    window-fill: header-color,
    window-stroke: none,
    content-fill: content-color,
    header-inset: (x: 0.3em, y: header-height / 2),
    buttons-align: left,
    button-size: 0.6em * button-scale,
    button-spacing: 0.3em,
    button-radius: 100%,
    button-stroke: none,
  )
}

// Neutral
#let neutral-theme(
  header-color: none,
  stroke-color: none,
  text-color: none,
  content-fill: none,
  button-color: none,
  radius-amount: 0.15em,
  rounded-bottom: false,
  light-theme: true,
  font: "Noto Sans",
  font-size: 0.75em,
  header-height: 1.4em,
  button-scale: 100%,
) = {
  let header-color = if header-color == none { if (light-theme) { rgb("eef0f2") } else { rgb("31363b") } } else {
    header-color
  }
  let stroke-color = if stroke-color == none { if (light-theme) { rgb("#b9b9b9") } else { rgb("#595b5d") } } else {
    stroke-color
  }
  let text-color = if text-color == none { if (light-theme) { rgb("272727") } else { rgb("d1d5d8") } } else {
    text-color
  }
  let content-fill = if content-fill == none { if (light-theme) { rgb("f5f5f5") } else { rgb("2a2e32") } } else {
    content-fill
  }
  let button-color = if button-color == none { if (light-theme) { rgb("#bebebe") } else { rgb("#909396") } } else {
    button-color
  }
  rounded-window-theme(
    radius-amount: radius-amount,
    rounded-bottom: rounded-bottom,
    header-color: header-color,
    button-colors: (
      header-color.transparentize(100%),
      header-color.transparentize(100%),
      header-color.transparentize(100%),
    ),
    header-stroke: (bottom: 0.1em + stroke-color),
    button-contents: (
      align(center + horizon, scale(button-scale, move(dy: -0.15em, rotate(-45deg, box(
        width: 0.4em,
        height: 0.4em,
        stroke: (bottom: 0.1em + button-color, left: 0.1em + button-color),
      ))))),
      align(center + horizon, scale(button-scale, move(dy: 0.15em, rotate(45deg, box(
        width: 0.4em,
        height: 0.4em,
        stroke: (top: 0.1em + button-color, left: 0.1em + button-color),
      ))))),
      align(center + horizon, scale(button-scale, text(
        baseline: 0.03em,
        top-edge: "bounds",
        bottom-edge: "bounds",
        text(
          font: "Libertinus Serif",
          fill: button-color,
          weight: 900,
          scale(140%, sym.times),
        ),
      ))),
    ),
    font: font,
    font-size: font-size,
    text-color: text-color,
    window-fill: header-color,
    window-stroke: 0.05em + stroke-color,
    content-fill: content-fill,
    header-inset: (x: 0.3em, y: header-height / 2),
    buttons-align: right,
    button-size: .6em * button-scale,
    button-spacing: 0.5em,
    button-radius: 100%,
    button-stroke: none,
  )
}

// Modern
#let modern-theme(
  radius-amount: 0.2em,
  rounded-bottom: true,
  header-color: rgb("#F3F3F3"),
  button-scale: 100%,
  button-colors: (rgb("#F3F3F3"), rgb("#F3F3F3"), rgb("#F3F3F3")),
  stroke-color: rgb("#EBEBEB"),
  font: "Segoe UI",
  font-size: 0.6em,
  text-color: black,
  header-height: 1em,
) = {
  rounded-window-theme(
    radius-amount: radius-amount,
    rounded-bottom: rounded-bottom,
    header-color: header-color,
    button-colors: button-colors,
    button-contents: (
      box(baseline: horizon, fill: button-colors.at(0), height: 1.74em, width: 2em, outset: (bottom: -0.42em), align(
        center + horizon,
        scale(button-scale, text(baseline: 0.12em, top-edge: "bounds", bottom-edge: "bounds", text(
          font: "Libertinus Serif",
          sym.minus,
        ))),
      )),
      box(baseline: horizon, fill: button-colors.at(1), height: 1.74em, width: 2em, outset: (bottom: -0.42em), place(
        center + horizon,
        scale(button-scale, box(
          width: 0.35em,
          height: 0.35em,
          radius: 15%,
          stroke: 0.05em,
        )),
      )),
      box(baseline: horizon, fill: button-colors.at(2), height: 1.74em, width: 2em, outset: (bottom: -0.42em), place(
        center + horizon,
        scale(button-scale, text(
          baseline: 0.05em,
          top-edge: "bounds",
          bottom-edge: "bounds",
          text(
            font: "Libertinus Serif",
            scale(120%, sym.times),
          ),
        )),
      )),
    ),
    font: font,
    font-size: font-size,
    text-color: text-color,
    window-fill: header-color,
    window-stroke: 0.05em + stroke-color,
    content-fill: white,
    content-stroke: none,
    header-inset: (left: 0.25em, y: header-height / 2),
    header-stroke: (bottom: 0.1em + stroke-color),
    title-align: left,
    buttons-align: right,
    button-size: 0.0em,
    button-spacing: 2em * button-scale,
    button-radius: 100%,
    button-stroke: none,
  )
}

#let minimalistic-tabs-bar(
  tabs,
  active-tab: 0,
  tab-width: 5em,
  tab-height: 1.0em,
  tab-radius: 0.25em,
  inactive-tab-fill: white.transparentize(100%),
  text-size: 0.75em,
  text-alignment: center + horizon,
  active-tab-fill: luma(80%),
  tab-stroke: none,
  active-tab-stroke: none,
  active-tab-text-color: black,
  inactive-tab-text-color: black,
  tab-box-params: (:),
  active-tab-box-params: (:),
  inactive-tab-box-params: (:),
  include-separators: false,
  separator-length: 60%,
  separator-stroke: 0.02em + gray,
  include-close-button: false,
  close-button: text(
    baseline: -0.1em,
    font: "Libertinus Serif",
    scale(120%, sym.times),
  ),
  include-new-tab-button: false,
  new-tab-button: text(
    baseline: -0.25em,
    font: "Libertinus Serif",
    scale(120%, "+"),
  ),
) = {
  let tab-boxes = ()
  for (i, tab) in tabs.enumerate() {
    tab-boxes.push(box(
      width: tab-width,
      height: tab-height,
      radius: (top-left: tab-radius, top-right: tab-radius),
      fill: if i == active-tab { active-tab-fill } else { inactive-tab-fill },
      stroke: if i == active-tab { (top: active-tab-stroke, left: active-tab-stroke, right: active-tab-stroke) } else {
        (top: tab-stroke, left: tab-stroke, right: tab-stroke)
      },
      ..tab-box-params,
      ..(if i == active-tab { active-tab-box-params } else { inactive-tab-box-params }),
      [
        #set text(fill: if (i == active-tab) { active-tab-text-color } else { inactive-tab-text-color })
        #align(text-alignment, text(top-edge: "bounds", bottom-edge: "bounds", text(text-size, tab)))
        #if ((include-close-button in (true, "active") and i == active-tab) or include-close-button == "always") {
          place(right + horizon, move(dx: -0.2em, close-button))
        }],
    ))
    if (include-separators and i != active-tab and (i + 1) != active-tab and i < tabs.len() - 1) {
      tab-boxes.push(box(height: tab-height, align(center + horizon, line(
        angle: 90deg,
        length: separator-length,
        stroke: separator-stroke,
      ))))
    }
  }
  box([#stack(
      dir: ltr,
      ..tab-boxes,
    )

  ])
  if (include-new-tab-button) {
    if (include-separators) {
      box(height: tab-height, align(center + horizon, line(
        angle: 90deg,
        length: separator-length,
        stroke: separator-stroke,
      )))
    }
    h(0.3em)
    set text(fill: inactive-tab-text-color)
    box(
      radius: (top-left: tab-radius, top-right: tab-radius),
      stroke: tab-stroke,
      new-tab-button,
    )
  }
}

#let input(
  width: 10em,
  height: 1.5em,
  radius: 100%,
  fill: luma(90%),
  stroke: none,
  text-color: luma(30%),
  icon: "search",
  icon-color: luma(50%),
  content: "Search...",
) = {
  box(width: width, height: height, radius: radius, fill: fill, stroke: stroke)[
    #let icon-path = none
    #if icon == "search" {
      icon-path = "./icons/magnifying-glass.svg"
    }
    #set align(left)
    #h(height * 0.1)
    #box(
      clip: true,
      baseline: height * 0.15,
      width: height * 0.7 * if (icon-path != none) { 1 } else { 0 },
      height: 100%,
      align(
        horizon,
        // Search icon
        box(width: height * 0.7, height: height * 0.7, align(center + horizon, [
          #image(width: 70%, load-icon("./icons/magnifying-glass.svg", stroke-color: icon-color))
        ])),
      ),
    )
    #text(fill: text-color, content)
  ]
}

#let browser-bar(
  height: 1.5em,
  button-stroke-color: luma(50%),
  button-fill: none,
  arrow-buttons-background-color: none,
  buttons-separation: 0.25em,
  buttons-scaling: 80%,
  input-params: (fill: white, text-color: luma(30%)),
  input-width:1fr,
) = {
  box(height: height)[
    #box(fill: arrow-buttons-background-color, radius: 100%, height: height, width: height, align(
      center + horizon,
      scale(buttons-scaling, image(load-icon(
        "./icons/arrow.svg",
        stroke-color: button-stroke-color,
        fill-color: button-fill,
      ))),
    ))
    #h(buttons-separation)
    #box(fill: arrow-buttons-background-color, radius: 100%, height: height, width: height, align(
      center + horizon,
      scale(buttons-scaling, rotate(180deg, image(load-icon(
        "./icons/arrow.svg",
        stroke-color: button-stroke-color,
        fill-color: button-fill,
      )))),
    ))
    #h(buttons-separation)
    #box(height: 100%, align(horizon, scale(buttons-scaling, image(load-icon(
      "./icons/reload.svg",
      stroke-color: button-stroke-color,
    )))))
    #h(1em)
    #box(height: 100%, width:input-width, baseline: -0.4em, align(horizon, input(width: input-width, ..input-params)))
  ]
}

#let desktop-window-frame(contents, title, theme, additional-bars: (), show-buttons: true, width: auto, height: auto) = {
  (theme.windows-frame)[
    #let cells = (
      (theme.header-bar)(i: 0, total-bars: 1 + additional-bars.len())[
        #place(theme.title-align + horizon, (theme.title-wrapper)(title))
        #if (show-buttons) {
          place(theme.buttons-align + horizon, box(height: 100%, theme.buttons))
        }

      ],
    )
    #for (i, additional-bar) in additional-bars.enumerate() {
      cells.push((theme.header-bar)(
        i: i + 1,
        total-bars: 1 + additional-bars.len(),
        [
          #additional-bar
        ],
      ))
    }
    #block(width: width, height: height, grid(
      columns: 1,
      ..cells,
      (theme.content-frame)(contents),
    ))
  ]
}

#let signal-icon(
  bars: 4,
  filled: 3,
  bar-width: 21%,
  bar-spacing: 5%,
  bar-empty-color: luma(30%),
  bar-filled-color: luma(80%),
) = {
  let bars-list = ()
  for i in range(bars) {
    bars-list.push(box(width: bar-width, height: 100%, align(bottom, box(
      width: 100%,
      height: (i + 1) * 25%,
      fill: if i < filled { bar-filled-color } else { bar-empty-color },
    ))))
  }
  stack(dir: ltr, spacing: bar-spacing, ..bars-list)
}

#let battery-icon-classic(
  battery-level: 80%,
  level: 100%,
  height: 80%,
  width: 100%,
  external-width: 0.06em,
  external-color: black,
  internal-color: black,
  inset: 0.06em,
  tip-width: 0.07em,
  tip-height: 0.2em,
) = {
  box(width: width, height: height, stroke: external-color + external-width, inset: inset, align(right + horizon, box(
    width: battery-level,
    height: 100%,
    fill: internal-color,
  )))
  place(left + horizon, dx: -tip-width, box(width: tip-width, height: tip-height, fill: external-color))
}

#let battery-icon-modern(
  battery-level: 95%,
  text-size: 0.15em,
  text-font: "DejaVu Sans Mono",
  text-color: luma(30%),
  height: 60%,
  width: 120%,
  empty-color: luma(70%),
  filled-color: luma(90%),
  fill-align: left,
) = {
  box(width: width, height: height, fill: empty-color, radius: 100%, clip: true, align(right + horizon, [
    #align(
      fill-align,
      box(
        width: battery-level,
        height: 100%,
        fill: filled-color,
      ),
    )
    #place(center + horizon, text(text-size, fill: text-color, font: text-font, [#repr(battery-level)]))
  ]))
}

#let phone-frame(
  width: 7em,
  height: 14em,
  contents,
  phone-color: luma(20%),
  phone-radius: 1em,
  phone-thickness: 0.25em,
  screen-color: white,
  include-selfie-camera: true,
  selfie-camera-separation: 0.2em,
  selfie-camera-size: 0.3em,
  include-levels-icons: true,
  levels-icons-size: 0.4em,
  levels-icons-separation: (x: 0.4em, y: 0.2em),
  levels-icons-spacing: 0.2em,
  include-buttons-region: true,
  buttons-region-color: luma(10%).transparentize(50%),
  buttons-region-height: 1em,
  buttons-size: 0.4em,
  buttons: (
    box(
      width: 100%,
      height: 100%,
      stack(
        dir: ltr,
        spacing: 33%,
        ..(
          range(3).map(it => line(angle: 90deg, length: 100%, stroke: 0.05em + white))
        ),
      ),
    ),
    box(
      width: 100%,
      height: 100%,
      box(width: 90%, height: 90%, stroke: 0.05em + white, radius: 30%),
    ),
    box(
      width: 100%,
      height: 100%,
      rotate(-45deg, box(width: 80%, height: 80%, stroke: (left: 0.05em + white, top: 0.05em + white))),
    ),
  ),
) = {
  block(width: width, height: height, radius: phone-radius, fill: phone-color, clip: true, inset: phone-thickness, [
    #align(center + horizon, block(
      width: 100%,
      height: 100%,
      radius: phone-radius - phone-thickness,
      fill: screen-color,
      clip: true,
    )[
      #contents
      #if include-buttons-region {
        place(center + bottom, block(height: buttons-region-height, width: 100%, fill: buttons-region-color)[
          #align(center + horizon, stack(dir: ltr, spacing: 25%, ..buttons.map(it => box(
            width: buttons-size,
            height: buttons-size,
            it,
          ))))
        ])
      }
      #if include-selfie-camera {
        place(center + top, move(dy: selfie-camera-separation, box(
          width: selfie-camera-size,
          height: selfie-camera-size,
          radius: 100%,
          fill: black,
        )))
      }
      #if include-levels-icons {
        place(right + top, move(dx: -levels-icons-separation.x, dy: levels-icons-separation.y, stack(
          dir: ltr,
          spacing: levels-icons-spacing,
          align(horizon, box(
            height: levels-icons-size * 0.7,
            width: levels-icons-size,
            signal-icon(filled: 3),
          )),
          box(
            height: levels-icons-size,
            width: levels-icons-size,
            align(center + horizon, battery-icon-modern(battery-level: 80%)),
          ),
        )))
      }
    ])

  ])
}
