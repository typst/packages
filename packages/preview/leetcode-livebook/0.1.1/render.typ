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
      let linked-body = link(
        "https://leetcode.com/problems/" + info.slug + "/",
      )[#it.body]
      pagebreak(weak: true)

      // Build badges inline
      let badges = {
        if show-badge and "difficulty" in info {
          h(0.5em)
          difficulty-badge(info.difficulty)
        }
        if show-labels and "labels" in info {
          h(0.5em)
          for label in info.labels {
            label-badge(label)
            h(0.3em)
          }
        }
      }
      block[#linked-body #badges]
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
