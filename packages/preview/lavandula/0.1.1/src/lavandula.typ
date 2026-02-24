#import "@preview/fontawesome:0.6.0": *

#let base-colors = state("lavandula base colors", (
  primary: rgb("#414cc8"),
  secondary: rgb("#f7f4fc"),
  light: rgb("#fefcfc"),
  dark: rgb("#202020"),
))

#let colors = state("lavandula colors", (:))

#let get-color(color-name) = {
  if color-name in base-colors.get() {
    base-colors.get().at(color-name)
  } else if color-name in colors.get() {
    colors.get().at(color-name)
  } else {
    panic("Unknown color")
  }
}

#let sizes = (
  text-b4: 20pt,
  text-b3: 17pt,
  text-b2: 14pt,
  text-b1: 12pt,
  text-default: 9.5pt,
  text-s1: 9pt,
  text-s2: 8pt,
  text-s3: 7pt,
)

#let cv(sidebar-position: "left", sidebar-width: 36%, sidebar: "", main-content: "") = context {
  assert(
    ("left", "right").contains(sidebar-position),
    message: "sidebar-position must be left or right",
  )

  let columns = (sidebar-width, 1fr)
  let blocks = (sidebar, main-content)
  let fills = (get-color("sidebar"), get-color("bg"))

  if sidebar-position == "right" {
    columns = columns.rev()
    blocks = blocks.rev()
    fills = fills.rev()
  }
  
  grid(
    columns: columns,
    rows: (auto, 1fr),
    gutter: 0pt,
    inset: (x: 0% + 17pt, y: 0% + 25pt),
    fill: fills,
    ..blocks,
  )
}

#let sidebar-section(title: "", body) = context {
  block(inset: (y: 0.8em))[
    #grid(
      columns: (auto, 1fr),
      rows: (auto),
      gutter: 1em,
      align: horizon,
      [=== #title],
      line(
        length: 100%,
        stroke: 0.7pt + gradient.linear(
          get-color("sidebar-section-line"),
          get-color("sidebar-section-line").transparentize(20%),
        ),
      ),
    )
    #v(0.5em)
    #body
  ]
}

#let icon-list(elements, icon-color-name: "text") = context {
  block(
    inset: (x: 3pt),
    grid(
      columns: (auto, auto),
      rows: auto,
      gutter: 0.8em,
      align: (top + center, horizon),
      ..elements.map(element => {(
        {
          set text(top-edge: "ascender")
          fa-icon(
            fill: get-color(icon-color-name),
            solid: element.at("icon-solid", default: false),
            element.icon,
          )
        },
        element.text,
      )}).flatten()
    ),
  )
}

#let contact-list(contacts) = {
  set text(size: sizes.text-s1)
  block(
    inset: (x: 1pt, top: 4pt, bottom: 8pt),
    icon-list(contacts),
  )
}

#let skill-group(name: "", icon: "", icon-solid: false, skills: ()) = context {
  block(below: 10pt)[
    #icon-list(
      ((icon: icon, icon-solid: icon-solid, text: text(weight: "semibold", name)),),
      icon-color-name: "skill-group-icon",
    )
  ]
  set par(leading: 4.2pt)
  for skill in skills {
    box(
      fill: get-color("skill-box"),
      stroke: 1pt + get-color("skill-box").darken(8%),
      inset: 5.4pt,
      radius: 4pt,
      skill,
    )
    h(3.5pt)
  }
  v(4pt)
}

#let skill-levels(skills) = context {
  block(
    inset: (x: 1pt),
    grid(
      columns: (auto, 1fr, auto),
      rows: auto,
      gutter: 0.5em,
      align: (horizon + center, horizon, horizon),
      ..skills.map(skill => {(
        {
          set image(width: 12pt)
          skill.icon
        },
        skill.text,
        box(
          fill: get-color("progress-bar").transparentize(80%),
          width: 50pt,
          height: 6pt,
        )[
          #rect(
            width: skill.level,
            height: 100%,
            fill: get-color("progress-bar"),
          )
          #place(
            top + left,
            rect(
              width: 100%,
              height: 100%,
              fill: gradient.linear(
                get-color("light").transparentize(100%),
                get-color("light").transparentize(70%),
              ),
            ),
          )
        ],
      )}).flatten()
    )
  )
}

#let section(title: "", body) = {
  block(width: 100%, below: 3.5em)[
    == #title
    #block(inset: (x: 0.5pt), width: 100%, body)
  ]
}

#let section-element(title: "", info: "", body) = {
  block(
    inset: (top: 3pt),
    width: 100%,
    below: 1.7em,
    grid(
      columns: (auto, 1fr),
      rows: auto,
      gutter: 9pt,
      align: (horizon + left, horizon + right),
      text(weight: "semibold", title),
      text(size: sizes.text-s3, info),
      grid.cell(colspan: 2)[
        #set par(justify: true, spacing: 1em)
        #body
      ],
    ),
  )
}

#let section-element-advanced(title: "", info-top-right: "", info-top-left: "", icon: "", body) = {
  block(
    inset: (top: 3pt),
    width: 100%,
    below: 1.7em,
    grid(
      columns: (15pt, auto, 1fr),
      rows: auto,
      row-gutter: 9pt,
      column-gutter: 12pt,
      align: (col, row) => {
        if col == 0 and row == 0 { horizon + center }
        else if col == 0 and row == 1 { top + center }
        else if col == 1 and row == 1 { top + left }
        else if col == 1 and row == 0 { horizon + left }
        else if col == 2 { horizon + right }
      },
      text(size: sizes.text-s3, info-top-left),
      text(weight: "semibold", title),
      text(size: sizes.text-s3, info-top-right),
      {
        set image(width: 80%)
        icon
      },
      grid.cell(colspan: 2)[
        #set par(justify: true, spacing: 1em)
        #body
      ],
    ),
  )
}

#let lavandula-theme(custom-colors: (:), body) = context {
  let new-base-colors = (:)

  for (k, v) in base-colors.get() {
    new-base-colors.insert(k, v)
  }

  // Override with user-provided colors
  for (k, v) in custom-colors {
    new-base-colors.insert(k, v) 
  }

  base-colors.update(new-base-colors)
  colors.update((
    // Backgrounds
    bg: new-base-colors.light,
    sidebar: new-base-colors.secondary,
    // Texts
    text: new-base-colors.dark,
    highlight: new-base-colors.primary.darken(40%),
    // Titles
    main-title: new-base-colors.primary.darken(40%),
    section-title: new-base-colors.primary,
    sidebar-section-title: new-base-colors.primary.darken(30%),
    subtitle: new-base-colors.dark.lighten(10%),
    // Misc
    sidebar-section-line: new-base-colors.primary.darken(30%),
    progress-bar: new-base-colors.primary,
    skill-group-icon: new-base-colors.primary.darken(40%),
    skill-box: new-base-colors.secondary.lighten(50%),
  ))

  context {
    set page(
      paper: "a4",
      fill: get-color("bg"),
      margin: 0%,
    )
  
    set text(
      font: "Fira Sans",
      fill: get-color("text"),
      size: sizes.text-default,
    )
  
    show heading.where(level: 1): it => {
      set text(
        fill: gradient.linear(
          get-color("main-title").lighten(10%),
          get-color("main-title"),
          angle: 90deg,
        ),
        size: sizes.text-b4,
        weight: "semibold",
      )
      block(below: 0.8em, it)
    }
  
    show heading.where(level: 2): it => {
      set text(
        fill: get-color("section-title"),
        size: sizes.text-b3,
        weight: "semibold"
      )
      block(below: 1em, it)
    }
  
    show heading.where(level: 3): it => {
      set text(
        fill: get-color("sidebar-section-title"),
        size: sizes.text-b2,
        weight: "regular",
      )
      block(below: 1em, it)
    }
  
    show heading.where(level: 4): it => {
      set text(
        fill: get-color("subtitle"),
        size: sizes.text-b1,
        weight: "regular",
      )
      block(below: 1.5em, it)
    }

    show highlight: it => context text(fill: get-color("highlight"), it.body)
  
    body
  }
}
