// use tailwind colors: text 700, fill 100, stroke 300
#let tw-colors = (
  red: (oklch(50.5%, 0.213, 27.518deg), oklch(93.6%, 0.032, 17.717deg), oklch(80.8%, 0.114, 19.571deg)),
  orange: (oklch(55.3%, 0.195, 38.402deg), oklch(95.4%, 0.038, 75.164deg), oklch(83.7%, 0.128, 66.29deg)),
  yellow: (oklch(55.4%, 0.135, 66.442deg), oklch(97.3%, 0.071, 103.193deg), oklch(90.5%, 0.182, 98.111deg)),
  green: (oklch(52.7%, 0.154, 150.069deg), oklch(96.2%, 0.044, 156.743deg), oklch(87.1%, 0.15, 154.449deg)),
  teal: (oklch(51.1%, 0.096, 186.391deg), oklch(95.3%, 0.051, 180.801deg), oklch(85.5%, 0.138, 181.071deg)),
  sky: (oklch(50%, 0.134, 242.749deg), oklch(95.1%, 0.026, 236.824deg), oklch(82.8%, 0.111, 230.318deg)),
  blue: (oklch(48.8%, 0.243, 264.376deg), oklch(93.2%, 0.032, 255.585deg), oklch(80.9%, 0.105, 251.813deg)),
  purple: (oklch(49.6%, 0.265, 301.924deg), oklch(94.6%, 0.033, 307.174deg), oklch(82.7%, 0.119, 306.383deg)),
  gray: (oklch(37.3%, 0.034, 259.733deg), oklch(96.7%, 0.003, 264.542deg), oklch(87.2%, 0.01, 258.338deg)),
)

#let fonts = (
  sans: "Noto Sans",
  mono: "Noto Sans Mono",
  serif: "Noto Sans Serif",
  math: ""
)

#let empty-block((fontcolor, bgcolor, bordercolor), width: 100%, height: auto, content) = {
  set text(fill: fontcolor)
  block(width: width, height: height, inset: (x: 0.75em, y: 0.5em), radius: 0.5em, breakable: false,
    fill: bgcolor, stroke: (paint: bordercolor, thickness: 1pt), content)
}

#let callout(icon, title, content, colors) = {
  empty-block(colors,
  [
    #heading(outlined: false, numbering: none, depth: 3, {
      box(text(font: "Material Symbols Outlined", icon), baseline: 1pt)
      h(2pt)
      title
    })

    #content
  ])
}

#let inactive-text-color = rgb("#98A1AE")

#let get-current-header(lvl) = {
  query(heading.where(level: lvl).after(here())
    .or(heading.where(level: lvl).before(here())))
    .sorted(
      key: h => h.location().page(),
      by: (l, r) => {
        let diffL = here().page() - l;
        if diffL < 0 {
          // if it's negative, the header comes after here().
          // we give that a lower priority than headers before here()
          // this breaks after 1 000 000 pages, but that should be fine
          diffL = calc.abs(diffL) + 1000000
        }
        let diffR = here().page() - r;
        if diffR < 0 {
          diffR = 100 * calc.abs(diffR)
        }
        diffL <= diffR
      })
    .at(0, default: (body: []))
}

// callout definitions

#let add-title(title) = if title != [] {
  ": "
  title
} else []


#let note(content) = callout("comment", [Note], content, tw-colors.gray)

#let summary(content) = callout("summarize", [Summary], content, tw-colors.teal)

#let fact(content) = callout("info", "Fact", content, tw-colors.sky)

// todo

// hint

#let solution(content, title: []) = callout("check", if title == [] {"Solution"} else {title}, content, tw-colors.green)

#let idea(content, title: []) = callout("lightbulb", [Idea#add-title(title)], content, tw-colors.yellow)

#let question(content, title: []) = callout("question_mark", [Question#add-title(title)], content, tw-colors.orange)

#let warning(content) = callout("warning", "Warning", content, tw-colors.orange)

#let problem(content, title: []) = callout("dangerous", [Problem#add-title(title)], content, tw-colors.red)

#let example(content, title: []) = callout("edit", [Example#add-title(title)], content, tw-colors.purple)


// useful to show code including math content
#let code(title, body, params: none) = {
  set text(font: "JetBrains Mono")
  callout("code", title, [
  #if params != none [
    *Input:* #params.input \
    *Output:* #params.output

    #line(length: 100%, stroke: (paint: oklch(55.1%, 0.027, 264.364deg), dash: "dashed"))
  ]

  #body
  ],
  tw-colors.gray)
}

// compare two things side by side
#let compare(..args) = {
  // assumes even number of arguments
  let half-args = calc.div-euclid(args.len(), 2)
  grid(columns: half-args, gutter: 1em,
    ..for i in range(args.len()) {
      if i >= half-args {
        continue
      }
      (empty-block((black, none, tw-colors.gray.at(2)), [
        #{
          set align(center)
          heading(args.at(i), outlined: false, numbering: none, depth: 3)
        }
        #args.at(i + half-args)
      ]),)
    }
  )
}

#let good-bad(good, bad) = {
  grid(columns: 2, gutter: 1em,
    callout("check", [Pro], good, tw-colors.green),
    callout("close", [Con], bad, tw-colors.red)
  )
}

#let questions(body) = {
  set text(fill: inactive-text-color)
  [
    *Questions*
    #body
  ]
}

#let notes(title, content) = {
  // meta information
  set document(title: title)

  // page layout and style
  set page(numbering: "1", header: context {
    // get the current header on level 1
    let h = get-current-header(1)


    set text(fill: inactive-text-color)
    set align(center)
    emph([
      #document.title
      #if h.body != [] [/]
      #h.body
    ])
  })

  set text(font: fonts.sans)

  set heading(numbering: "1.1")
  show heading: set text(weight: "extrabold")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    it
  }

  show figure.caption: set text(rgb("#98A1AE"))

  show ref: it => {
    set text(fill: inactive-text-color)
    [_(see #it)_]
  }
  show terms.item: it => {
    callout("book_2", it.term, it.description,
      tw-colors.sky)
  }

  set quote(block: true)
  show quote.where(block: true): it => {
    let title = if it.attribution == none [
      Quote
    ] else {
      it.attribution
    }

    callout("format_quote", title, it.body, tw-colors.gray)
  }

  set table(stroke: rgb("#E4E6EB") + 0.5pt, fill: (_, y) => if calc.odd(y){ rgb("#F9F9FB") })
  show table.cell.where(y: 0): set text(weight: "bold")
  show table: set align(start)

  show raw: set text(font: fonts.mono)
  show raw.where(block: true): it => {
    empty-block(tw-colors.gray, {
      place(top+right, text(font: fonts.sans, fill: inactive-text-color, it.lang))

      show raw.line: line => {
        if line.number < 10 {
          text(fill: gray)[$"  "$#line.number]
        } else {
          text(fill: gray)[#line.number]
        }
        h(1em)
        line.body
      }
      it
    })
  }

  show image: i => {
      block(clip: true, radius: 0.5em, stroke: tw-colors.gray.at(2), i)
  }

  show link: url => {
      set text(stretch: 90%)
      underline(url)
      /*
      " "
      emoji.globe.meridian
      */
  }


  if fonts.math != "" {
    show math.equation: set text(font: fonts.math)
  }

  content
}

