#import "@preview/touying:0.5.3": *

#import "colour.typ": colour
#import "progress.typ": lineal-progress-bar

#let current-heading(level: auto, outlined: true) = {
  let here = here()
  query(heading.where(outlined: outlined).before(inclusive: false, here))
    .at(-1, default: none)
}

#let headings-context(target: heading.where(outlined: true)) = {
  let current-heading = current-heading()
  
  let headings = query(target)
  let path = ()
  let level = 0
  let current-heading-idx = none

  let result = ()

  for hd in headings {
    let diff = hd.level - level
    if diff > 0 {
      for _ in range(diff) {
        path.push(1)
      }
    } else {
      for _ in range(-diff) {
        let _ = path.pop()
      }
      path.at(-1) = path.at(-1) + 1
    }

    result.push((
      path: path,
      heading: hd
    ))

    if current-heading != none and hd.location() == current-heading.location() { // matching on location, otherwise this will be `true` for an identical heading at another location
      current-heading-idx = result.len() - 1
    }
    
    level = hd.level
  }

  return (
    current-heading: current-heading,
    current-heading-idx: current-heading-idx,
    headings: result
  )
}



#let lineal-outline(
  filter: hd => true,
  transform: (_, it) => it,
  target: heading.where(outlined: true),
  ..args
) = context {
  let cx = headings-context(target: target)
  let idx = cx.at("current-heading-idx", default: none)
  let scope-path = if idx != none {
    cx.headings.at(idx).path
  }

  let headings = cx.headings.map(hd => {
    let level = hd.path.len()

    let relation = if scope-path != none {
      let path-len = calc.min(level, scope-path.len())
      let common-path = hd.path.slice(0, path-len) == scope-path.slice(0, path-len)

      let same = hd.path == scope-path
      let parent = not same and common-path and level < scope-path.len()
      let child = not same and common-path and level > scope-path.len()
      let sibling = not same and level == scope-path.len() and hd.path.slice(0, path-len - 1) == scope-path.slice(0, path-len - 1)

      (
        same: same,
        parent: parent,
        child: child,
        sibling: sibling,
        unrelated: not same and not parent and not child and not sibling,
      )
    }
    
    (
      here-path: scope-path,
      here-level: if scope-path != none { scope-path.len() },
      level: level,
      path: hd.path,
      relation: relation,
      loc: hd.heading.location(),
      heading: hd.heading
    )
  }).filter(filter)

  if headings == () {
    let nonsense-target = selector(<P>).and(<NP>)
    outline(target: nonsense-target, ..args)
    return
  }

  let find-heading(location) = {
    for x in headings { // forgive me :(
      if x.loc == location {
        return x
      }
    }
  }

  place(
    top,
    move(
      dy: -15%,
      block(width: 100%)[
        #grid(
          align: top,
          columns: (30%, 70%),
          column-gutter: 2em,
          {
            // Left column: all section headings
            show outline.entry: it => {
              let hd = find-heading(it.element.location())
              if hd.relation != none and hd.relation.same {
                // Active section - mark its position
                box(width: 100%)[
                  #set align(right)
                  #h(1em)
                  #link(
                    it.element.location(),
                    transform(hd, it.body),
                  )
                ]
              } else {
                // Regular section
                box(width: 100%)[
                  #set align(right)
                  #h(1em)
                  #link(
                    it.element.location(),
                    transform(hd, it.body),
                  )
                ]
              }
            }
            
            let all_sections = headings.filter(hd => hd.level == 1)
            let section_selector = if all_sections != () {
              let sel = selector(all_sections.at(0).loc)
              for idx in range(1, all_sections.len()) {
                sel = sel.or(all_sections.at(idx).loc)
              }
              sel
            } else {
              selector(<P>).and(<NP>)
            }
            
            outline(target: section_selector, fill: none, indent: 0em, ..args)
          },
          {
            // Right column: current section and its subsections
            show outline.entry: it => {
              let hd = find-heading(it.element.location())
              if hd.level == 1 {
                // Section heading
                box(width: 100%)[
                  #link(
                    it.element.location(),
                    transform(hd, it.body),
                  )
                  #v(-0.25em)
                  #box(width: 100%)[
                    #let section-ratio = (hd.path.at(0) - 1) / (headings.filter(h => h.level == 1).len() - 1)
                    #lineal-progress-bar(variant: "broad")
                  ]
                  #v(0.5em)
                ]
              } else {
                // Subsection heading with hyphen
                box(width: 100%)[
                  #set list(marker: text(fill: colour.neutral-dark.transparentize(60%))[---])
                  - #link(
                    it.element.location(),
                    transform(hd, it.body),
                  )
                ]
              }
            }
            
            let current_section = if scope-path != none {
              // Find the root section for current heading
              let root_path = scope-path.slice(0, 1)
              headings.filter(hd => 
                hd.path.slice(0, 1) == root_path and 
                (hd.level == 1 or hd.relation.child or hd.relation.same)
              )
            } else {
              ()
            }
            
            let section_selector = if current_section != () {
              let sel = selector(current_section.at(0).loc)
              for idx in range(1, current_section.len()) {
                sel = sel.or(current_section.at(idx).loc)
              }
              sel
            } else {
              selector(<P>).and(<NP>)
            }
            
            outline(target: section_selector, fill: none, ..args)
          }
        )
      ]
    )
  )
}