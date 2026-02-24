#import "../components/sidebar.typ" as sidebar
#import "../components/sweeps.typ" as sweeps

// TODO: Fix two first level headings after one another breaking the sweeps

#let multi-page-layout(
  odd-even: true,
  sidebar-width: 80pt,
  page-margins: 15pt,
  page-binding: alignment.right,
  title: none,
  body,
) = {
  let margin-ext = 20pt
  let h1-pad = 20pt

  context {
    let first-page = here().page()
    let theme = state("theme-state").get()

    let heading-positions-state = state("heading-positions-state", ())

    show heading: it => {
      if it.level != 1 {
        return it
      }

      let current-heading-y = here().position().y
      let page-number = here().page()

      set text(size: 15pt)
      let new-it = pad(left: h1-pad, it)
      context {
        let current-heading-x = measure(new-it).width
        heading-positions-state.update(prev => (
          ..prev,
          (page: page-number, y-pos: current-heading-y, x-pos: current-heading-x),
        ))
      }
      new-it
    }

    let sel-page-margins
    let rigth-or-inside-margins
    let left-or-outside-margins
    if type(page-margins) == length and odd-even {
      sel-page-margins = (top: page-margins, inside: page-margins, bottom: page-margins, outside: page-margins)
    } else if type(page-margins) == length and not odd-even {
      sel-page-margins = (top: page-margins, right: page-margins, bottom: page-margins, left: page-margins)
    } else {
      sel-page-margins = page-margins
    }

    if odd-even {
      sel-page-margins = (
        top: sel-page-margins.top + 10pt,
        inside: sel-page-margins.inside,
        bottom: sel-page-margins.bottom,
        outside: sel-page-margins.outside + sidebar-width + margin-ext,
      )
      rigth-or-inside-margins = sel-page-margins.inside
      left-or-outside-margins = sel-page-margins.outside
    } else {
      sel-page-margins = (
        top: sel-page-margins.top + 10pt,
        right: sel-page-margins.right,
        bottom: sel-page-margins.bottom,
        left: sel-page-margins.left + sidebar-width + margin-ext,
      )
      rigth-or-inside-margins = sel-page-margins.right
      left-or-outside-margins = sel-page-margins.left
    }

    let title-height = if title != none { 65pt } else { 0pt }

    set page(
      margin: sel-page-margins,
      binding: page-binding,
      background: context {
        place(top + left)[
          #layout(page-size => {
            box(height: page-size.height, width: page-size.width)[
              #let page-number = here().page()

              #let heading-positions-of-page = heading-positions-state.final().filter(h => h.page == page-number)

              #let right-sidebar() = {
                [
                  #let sidebar-elements = ()
                  #sidebar-elements.push(sidebar.sidebar-button(5pt, sidebar-width, elem-text: ""))
                  #sidebar-elements.push(v(5pt))
                  #let current-y-position = 10pt

                  #if title != none and page-number == first-page {
                    sidebar-elements.push([
                      #sweeps.top-right-sweep(60pt, sidebar-width, theme.red, sweep-width: margin-ext + h1-pad - 5pt)

                      #place(top + right, dy: 40pt, dx: -(sidebar-width + margin-ext + h1-pad))[
                        #stack(dir: rtl, spacing: 5pt)[
                          #box(radius: (right: 10pt), height: 20pt, width: 20pt, fill: theme.heading)
                        ][
                          #set text(size: 23pt, fill: theme.heading)
                          #title
                        ][
                          #box(radius: (left: 10pt), height: 20pt, width: 20pt, fill: theme.heading)
                        ][
                          #context {
                            let xpos = here().position().x
                            sidebar.sidebar-button(
                              20pt,
                              xpos - rigth-or-inside-margins,
                            )
                          }
                        ]
                      ]

                    ])

                    sidebar-elements.push(v(5pt))
                  }

                  #for h in heading-positions-of-page {
                    let y-pos = h.y-pos - sel-page-margins.top + 10pt
                    y-pos -= if title != none and page-number == first-page { title-height } else { 0pt }
                    let remaining-spacing = y-pos - current-y-position


                    while remaining-spacing > 45pt {
                      sidebar-elements.push(sidebar.sidebar-button(40pt, sidebar-width))

                      sidebar-elements.push(v(5pt))

                      remaining-spacing -= 45pt
                    }

                    if remaining-spacing >= 10pt {
                      sidebar-elements.push(sidebar.sidebar-button(
                        remaining-spacing - 5pt,
                        sidebar-width,
                        elem-text: if remaining-spacing > 25pt { none } else { "" },
                      ))

                      remaining-spacing -= remaining-spacing - 5pt
                    }

                    sidebar-elements.push(v(remaining-spacing))

                    sidebar-elements.push(sweeps.bottom-right-sweep(
                      40pt,
                      sidebar-width,
                      theme.heading,
                      sweep-width: page-size.width - left-or-outside-margins - 5pt - h.x-pos,
                    ))

                    sidebar-elements.push(v(5pt))

                    current-y-position = y-pos + 45pt
                  }

                  #let remaining-spacing = (
                    page-size.height
                      - sel-page-margins.top
                      - sel-page-margins.bottom
                      - current-y-position
                      - if title != none and page-number == first-page { title-height } else { 0pt }
                  )

                  #{
                    while remaining-spacing > 45pt {
                      sidebar-elements.push(sidebar.sidebar-button(40pt, sidebar-width))

                      sidebar-elements.push(v(5pt))

                      remaining-spacing -= 45pt
                    }

                    if remaining-spacing >= 10pt {
                      sidebar-elements.push(sidebar.sidebar-button(
                        remaining-spacing - 5pt,
                        sidebar-width,
                        elem-text: if remaining-spacing > 25pt { none } else { "" },
                      ))

                      remaining-spacing -= remaining-spacing - 5pt
                    }

                    sidebar-elements.push(v(remaining-spacing))
                  }

                  #stack(dir: ttb, ..sidebar-elements)
                ]
              }

              #let left-sidebar() = {
                [
                  #let sidebar-elements = ()
                  #sidebar-elements.push(sidebar.sidebar-button(5pt, sidebar-width, elem-text: ""))
                  #sidebar-elements.push(v(5pt))
                  #let current-y-position = 10pt

                  #if title != none and page-number == first-page {
                    sidebar-elements.push([
                      #sweeps.top-left-sweep(60pt, sidebar-width, theme.red, sweep-width: margin-ext + h1-pad - 5pt)

                      #place(top + left, dy: 40pt, dx: sidebar-width + margin-ext + h1-pad)[
                        #stack(dir: ltr, spacing: 5pt)[
                          #box(radius: (left: 10pt), height: 20pt, width: 20pt, fill: theme.heading)
                        ][
                          #set text(size: 23pt, fill: theme.heading)
                          #title
                        ][
                          #box(radius: (right: 10pt), height: 20pt, width: 20pt, fill: theme.heading)
                        ][
                          #context sidebar.sidebar-button(
                            20pt,
                            page-size.width - here().position().x - rigth-or-inside-margins,
                          )
                        ]
                      ]

                    ])

                    sidebar-elements.push(v(5pt))
                  }

                  #for h in heading-positions-of-page {
                    let y-pos = h.y-pos - sel-page-margins.top + 10pt
                    y-pos -= if title != none and page-number == first-page { title-height } else { 0pt }
                    let remaining-spacing = y-pos - current-y-position


                    while remaining-spacing > 45pt {
                      sidebar-elements.push(sidebar.sidebar-button(40pt, sidebar-width))

                      sidebar-elements.push(v(5pt))

                      remaining-spacing -= 45pt
                    }

                    if remaining-spacing >= 10pt {
                      sidebar-elements.push(sidebar.sidebar-button(
                        remaining-spacing - 5pt,
                        sidebar-width,
                        elem-text: if remaining-spacing > 25pt { none } else { "" },
                      ))

                      remaining-spacing -= remaining-spacing - 5pt
                    }

                    sidebar-elements.push(v(remaining-spacing))

                    sidebar-elements.push(sweeps.bottom-left-sweep(
                      40pt,
                      sidebar-width,
                      theme.heading,
                      sweep-width: margin-ext + h1-pad - 5pt,
                    ))

                    sidebar-elements.push(v(5pt))

                    current-y-position = y-pos + 45pt
                  }

                  #let remaining-spacing = (
                    page-size.height
                      - sel-page-margins.top
                      - sel-page-margins.bottom
                      - current-y-position
                      - if title != none and page-number == first-page { title-height } else { 0pt }
                  )

                  #{
                    while remaining-spacing > 45pt {
                      sidebar-elements.push(sidebar.sidebar-button(40pt, sidebar-width))

                      sidebar-elements.push(v(5pt))

                      remaining-spacing -= 45pt
                    }

                    if remaining-spacing >= 10pt {
                      sidebar-elements.push(sidebar.sidebar-button(
                        remaining-spacing - 5pt,
                        sidebar-width,
                        elem-text: if remaining-spacing > 25pt { none } else { "" },
                      ))

                      remaining-spacing -= remaining-spacing - 5pt
                    }

                    sidebar-elements.push(v(remaining-spacing))
                  }

                  #stack(dir: ttb, ..sidebar-elements)
                ]
              }

              #if odd-even {
                let is-even-page = calc.rem(page-number, 2) == 0
                let is-content-right = is-even-page != (page-binding != alignment.left)
                let sidebar-alignment = if is-content-right { left } else { right }

                place(
                  top + sidebar-alignment,
                  dy: sel-page-margins.top - 10pt,
                  dx: (sel-page-margins.outside - sidebar-width - margin-ext)
                    * if sidebar-alignment == left { 1 } else { -1 },
                )[
                  #if sidebar-alignment == left {
                    left-sidebar()
                  } else {
                    right-sidebar()
                  }
                ]
              } else {
                place(
                  top + left,
                  dy: sel-page-margins.top - 10pt,
                  dx: sel-page-margins.left - sidebar-width - margin-ext,
                )[
                  #left-sidebar()
                ]
              }
            ]
          })
        ]
      },
    )

    pagebreak(weak: true)

    if title != none {
      v(title-height)
    }

    body
  }
}
