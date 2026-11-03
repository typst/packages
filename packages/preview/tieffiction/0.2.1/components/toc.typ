#import "@preview/tieflang:0.1.0": tr

#let get-page-num = location => {
  let page-nums = query(<page-num>).filter(l => {
    l.location().page() == location.page()
  })

  if page-nums.len() == 0 {
    return
  }

  let page-num = page-nums.last()

  if location.page-numbering() == none {
    return
  }

  numbering(location.page-numbering(), counter(page).at(page-num.location()).last())
}

#let table-of-content = (style: "num-first", show-chapter-nums: false) => {
  context {
    text(size: 1.4em)[#tr().table-of-content]

    let headings = query(heading.where(outlined: true))

    let style-name = if type(style) == str { style } else { style.at("name", default: "num-first") }
    let style-feel = if type(style) == str { "normal" } else {
      let feel = style.at("feel", default: "normal")
      if not feel in ("compact", "normal", "open") {
        assert(false, message: "Feel must be in (\"compact\", \"normal\", \"open\").")
      }
      feel
    }

    let style-col-gutter = if style-feel == "compact" {
      6pt
    } else if style-feel == "normal" {
      10pt
    } else {
      12pt
    }

    let style-row-gutter = if style-feel == "compact" {
      4pt
    } else if style-feel == "normal" {
      10pt
    } else {
      14pt
    }

    if style-name == "underlined" or style-name == "dotted" {
      let spacer-stroke = if style-name == "dotted" {
        (paint: luma(40%), cap: "round", thickness: 0.75pt, dash: "loosely-dotted")
      } else {
        (paint: luma(40%), thickness: 0.75pt)
      }

      let heading-pairs = headings.map(h => {
        let location = h.location()
        if show-chapter-nums {
          (
            if heading.numbering != none { numbering(heading.numbering, counter(heading).at(location).last()) },
            link(h.location())[#h.body],
            line(length: 100%, stroke: spacer-stroke),
            get-page-num(location),
          )
        } else {
          (
            link(h.location())[#h.body],
            line(length: 100%, stroke: spacer-stroke),
            get-page-num(location),
          )
        }
      })

      grid(
        columns: 1,
        row-gutter: style-row-gutter,
        ..heading-pairs.map(p => grid(
          align: if show-chapter-nums {
            (right, left, center + bottom, right)
          } else {
            (left, center + bottom, right)
          },
          columns: if show-chapter-nums {
            (auto, auto, 1fr, auto)
          } else {
            (auto, 1fr, auto)
          },
          column-gutter: style-col-gutter,
          ..p
        ))
      )
    } else if style-name == "num-first" {
      let heading-pairs = headings.map(h => {
        let location = h.location()
        if show-chapter-nums {
          (
            get-page-num(location),
            if heading.numbering != none { numbering(heading.numbering, counter(heading).at(location).last()) },
            link(h.location())[#h.body],
          )
        } else {
          (
            get-page-num(location),
            link(h.location())[#h.body],
          )
        }
      })
      grid(
        align: if show-chapter-nums { (right, right, left) } else { (right, left) },
        columns: if show-chapter-nums { 3 } else { 2 },
        column-gutter: (style-col-gutter, .4em),
        row-gutter: style-row-gutter,
        ..heading-pairs.flatten()
      )
    } else {
      assert(false, "Style must be in (\"num-first\", \"underlined\", \"dotted\").")
    }
  }

  pagebreak(weak: true)
}
