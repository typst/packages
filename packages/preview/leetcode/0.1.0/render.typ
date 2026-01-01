// render.typ - Problem and answer rendering
// Depends on: problems.typ, badges.typ

#import "problems.typ": format-id
#import "badges.typ": difficulty-badge, label-badge

// Render problem description by ID with difficulty badge and labels
#let problem(id, show-badge: true, show-labels: true) = {
  let id-str = format-id(id)
  let info = toml("problems/" + id-str + "/problem.toml")

  // First include the description
  {
    show heading.where(level: 1): it => {
      it
      if show-badge and "difficulty" in info {
        difficulty-badge(info.difficulty)
        h(0.3em)
      }
      if show-labels and "labels" in info {
        for label in info.labels {
          label-badge(label)
          h(0.3em)
        }
        linebreak()
      }
    }
    include ("problems/" + id-str + "/description.typ")
  }
}

// Display reference solution code (for learning)
#let answer(id) = {
  let id-str = format-id(id)
  let path = "problems/" + id-str + "/"

  // Read solution file and extract code
  let solution-content = read(path + "solution.typ")
    .replace("#import \"../../helpers.typ\": *\n", "")
    .trim()

  heading(level: 2, outlined: false, numbering: none)[
    #text(fill: green.darken(20%))[Reference Solution \##id]
  ]
  {
    show raw: it => block(stroke: 0.8pt + green.lighten(50%), inset: 0.6em, it)
    raw(solution-content, block: true, lang: "typst")
  }
}
