#import "tokens.typ": tokens
#import "../utils.typ": show_if_heading_within_distance, v-after-numbered-chapter-heading

#let text-styles(doc) = {
  set par(
    spacing: 1.4em,
    leading: 0.7em,
    justify: true,
    linebreaks: "optimized",
  )

  set text(
    font: tokens.font-families.body,
    size: tokens.font-sizes.body,
  )

  show heading.where(level: 4): set heading(numbering: none)
  set heading(numbering: (first, ..nums) => numbering("1.1", first, ..nums))

  show heading: it => {
    set text(font: tokens.font-families.headers, fill: tokens.colour.main, weight: "bold")
    let level_based_spacing = if it.level == 2 { 0.4 } else { 1.4 / it.level }

    // Reduce spacing between 2 consecutive headings
    show_if_heading_within_distance(
      it: it,
      distance: 2 * tokens.spacing + 1cm,
      look: "before",
      to-show: v(-2 * level_based_spacing * tokens.spacing),
    )

    v(tokens.spacing * level_based_spacing)
    it
    v(tokens.spacing * level_based_spacing - 0.05cm)
  }

  show heading.where(level: 1): it => {
    set text(font: tokens.font-families.headers)
    if it.numbering == none {
      pagebreak()
      text(fill: tokens.colour.main, size: tokens.font-sizes.h1, it)
      v(tokens.spacing)
    } else {
      set par(justify: false)
      let heading_number = counter(heading.where(level: 1)).display()

      context {
        // Only add pagebreak if this is not the first numbered chapter
        let chapter_num = counter(heading.where(level: 1)).at(here()).first()
        // If chapter > 1, always pagebreak
        // If chapter = 1, only pagebreak if there's body content before (abstract, acknowledgements)
        if chapter_num > 1 {
          pagebreak()
        } else {
          let before_pars = query(selector(par).before(here()))
          if before_pars.len() > 0 {
            pagebreak()
          }
        }
      }

      grid(
        columns: (3cm, 1fr),
        rows: auto,
        gutter: -0.8cm,
        align: top + start,
        block(width: 100%, pad(left: -0.5em, text(fill: tokens.colour.main, size: 96pt, heading_number))),
        text(fill: tokens.colour.main, size: tokens.font-sizes.h1, it.body),
      )
      v-after-numbered-chapter-heading(it)
    }
  }

  show heading.where(level: 3): set text(size: tokens.font-sizes.h3)

  show heading.where(level: 4): it => {
    set text(
      font: tokens.font-families.headers,
      fill: tokens.colour.main,
      weight: "regular",
      size: tokens.font-sizes.h4,
    )
    it
  }

  set quote(block: true)

  show quote: it => {
    if it.block {
      pad(left: 0.21em, block(
        stroke: (
          left: (
            thickness: 2pt,
            paint: tokens.colour.main,
            cap: "round",
          ),
        ),
        inset: (left: 1em),
        {
          it.body

          if it.attribution != none {
            parbreak()
            // h(1fr)
            text(fill: tokens.colour.main)[— #it.attribution]
          }
        },
      ))
    } else {
      it
    }
  }

  doc
}
