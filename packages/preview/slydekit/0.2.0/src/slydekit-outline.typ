#import "slydekit-defaults.typ": *
#import "slydekit-utils.typ": *

#let adaptive-columns(
  gutter: 4%,
  max-count: 3,
  start: none,
  end: none,
  body,
) = layout(size => {
  let n = calc.min(
    calc.ceil(
      measure(body).height
        / (size.height - measure(start).height - measure(end).height),
    ),
    max-count,
  )
  if n < 1 {
    n = 1
  }
  start
  if n == 1 {
    body
  } else {
    columns(n, body)
  }
  end
})

#let toc = {
  set outline.entry(fill: none)
  show outline.entry: it => context {
    show linebreak: none
    let number = it.prefix()
    let section = it.element.body
    block(above: 1.5em, below: 0em)
    [#text([#number], fill: sk-states.colors.get().primary) #section]
  }

  set align(horizon)
  adaptive-columns(text(size: 1.2em, strong(outline(title:none, indent: 1em, depth: 1))))
}

// Display a progress bar at the bottom of the slide, showing the current section progress
// fill: color of the progress bar (default: primary color of the theme)
// alpha: transparency applied to inactive sections (default: 50%)
// display-subsection: whether to display bullets for each slide under the sections (default: true)
// linebreaks: whether to place the bullets on a new line under the section title (default: true)
// display-appendix: whether to display appendix sections (default: "auto", which shows main sections during the main presentation and switches to appendix during the appendix)
// - "auto" : Displays main sections during the main presentation and switches to appendix during the appendix.
// - true   : Always displays everything (main + appendix).
// - false  : Never displays appendix sections.
#let mini-slides(
  fill: none,
  alpha: 50%,
  display-subsection: true,
  linebreaks: true,
  display-appendix: "auto",
) = {
  // Inside mini-slides: show short title, hide long title
  // Override locally: render the short title inside mini-slides
  show metadata.where(label: <sk-title>): it => it.value.short

  context {
    // Retrieving the main color
    let theme-colors = sk-states.colors.get()
    let main-fill = if fill != none {
      fill
    } else {
      theme-colors.at("header", default: black)
    }

    let faded-fill = if type(main-fill) == color { main-fill.lighten(alpha) } else { main-fill }

    // Detection of the current slide number and the total number of slides
    let current-is-appendix = sk-states.appendix.get()

    let is-visible(h) = {
      let is-heading-appendix = sk-states.appendix.at(h.location())

      if display-appendix == "auto" or display-appendix == auto {
        is-heading-appendix == current-is-appendix
      } else if display-appendix == true {
        true
      } else {
        not is-heading-appendix
      }
    }

    // Sections : always real level 1 headings
    let sections = query(heading.where(level: 1)).filter(is-visible)
    if sections.len() == 0 {
      return []
    }

    // Slides : the marker placed by slide(), independent of == or #slide(...)
    let all-slides = query(<sk-slide>).filter(is-visible)

    let current-page = here().page()

    // Index of the current section
    let current-sec-idx = sections.filter(s => s.location().page() <= current-page).len() - 1

    let cols = ()

    for (sec-idx, section) in sections.enumerate() {
      let next-section = if sec-idx + 1 < sections.len() {
        sections.at(sec-idx + 1)
      } else {
        none
      }

      let sec-page = section.location().page()
      let next-sec-page = if next-section != none {
        next-section.location().page()
      } else {
        calc.inf
      }

      let is-current-sec = (sec-idx == current-sec-idx)
      let sec-color = if is-current-sec { main-fill } else { faded-fill }

      // Slides attached to this section, via the <sk-slide> marker
      let slides = all-slides.filter(h => (
        h.location().page() >= sec-page
        and h.location().page() < next-sec-page
      ))

      let col-content = {
        set text(fill: sec-color)

        // Remove linebreaks when displaying subsections, to avoid double linebreaks
        {
          show linebreak: none
          link(section.location(), section.body)
        }

        if display-subsection and slides.len() > 0 {
          if linebreaks {
            linebreak()
          } else {
            h(0.4em)
          }

          for (slide-idx, slide-h) in slides.enumerate() {
            let next-slide-page = if slide-idx + 1 < slides.len() {
              slides.at(slide-idx + 1).location().page()
            } else {
              next-sec-page
            }

            let slide-page = slide-h.location().page()
            let is-active-slide = (current-page >= slide-page and current-page < next-slide-page)

            let dot = if is-active-slide {
              sym.circle.filled
            } else {
              sym.circle.small
            }

            link(slide-h.location(), dot)

            if not linebreaks and slide-idx + 1 < slides.len() {
              h(0.25em)
            }
          }
        }
      }

      cols.push(align(center + top, col-content))
    }

    set text(size: 0.7em)
    grid(
      columns: cols.map(_ => auto).intersperse(1fr),
      ..cols.intersperse([])
    )
  }
}

#let progressive-outline(
  it,
  active-color,
  inactive-color,
  entry-size: 0.8575em,
  gutter: 4%,
  section-numbering: "1.1.",
  appendix-numbering: "A.1.",
) = context {
  set text(size: entry-size)
  show linebreak: none

  let it-hides-toc = it.has("label") and it.label == <hide-toc>

  let sections = if it-hides-toc {
    (it,)
  } else {
    query(heading.where(level: 1, outlined: true))
      .filter(s => not (s.has("label") and s.label == <hide-toc>))
  }

  let current-idx = sections.position(s => s.location() == it.location())

  let entries = sections.enumerate().map(((idx, s)) => {
    let s-is-appendix = sk-states.appendix.at(s.location())
    let format = if s-is-appendix { appendix-numbering } else { section-numbering }

    let count = counter(heading).at(s.location())
    let num = numbering(format, ..count)
    let is-current = idx == current-idx
    let color = if is-current { active-color } else { inactive-color }

    let entry = [
      #text(fill: color, weight: "bold")[#num] #s.body
    ]

    block(below: 1.5em)[
      #if is-current {
        entry
      } else {
        text(fill: inactive-color)[#entry]
      }
    ]
  })

  adaptive-columns(gutter: gutter, entries.join())
}