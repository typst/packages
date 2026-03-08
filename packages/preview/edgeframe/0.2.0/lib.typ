/*
  edgeframe by neuralpain

  For quick paper setups.

  Github Repository: https://github.com/neuralpain/edgeframe
  Typst Universe: https://typst.app/universe/package/edgeframe
*/

// Standard page margins
#let margin = (
  normal: 2.54cm,
  narrow: 1.27cm,
  moderate: (x: 2.54cm, y: 1.91cm),
  wide: (x: 5.08cm, y: 2.54cm),
  a4: (x: 2.5cm, y: 2cm),
  a5: (x: 2cm, y: 2.5cm),
)

#let xlinebreak(size) = {
  linebreak() * size
}

#let xpagebreak(size) = {
  pagebreak() * size
}

/// I don't remember why this exists but it does...
/// to be lazy is both a blessing and a curse
#let font(body, face: str) = {
  text(body, font: face)
}

/// Headers and footers have a maximum of 3 positions
#let ef-document(
  header: (none, none, none),
  footer: (none, none, none),
  // set-font: "",
  // set-text-size: none,
  set-paper: "us-letter",
  set-margin: margin.normal,
  hf-flex-layout: true,
  hf-text-size: 11pt,
  header-alignment: center,
  footer-alignment: center,
  header-first-page: none,
  header-last-page: none,
  footer-first-page: none,
  footer-last-page: none,
  header-first-page-alignment: center,
  header-last-page-alignment: center,
  footer-first-page-alignment: center,
  footer-last-page-alignment: center,
  header-even-page: none,
  header-odd-page: none,
  footer-even-page: none,
  footer-odd-page: none,
  page-count: false,
  page-count-first-page: true,
  page-count-position: center,
  watermark: "",
  overlay: none,
  overlay-size: 100%,
  watermark-size: 15em,
  watermark-color: luma(0, 20%),
  watermark-rotation: -45deg,
  draft: false,
  confidential: false,
  set-par-justify: false,
  set-par-leading: 0.8em,
  set-par-spacing: 1em,
  set-par-first-line-indent: 0em,
  doc,
) = {
  // handle header-footer display
  let hfdata(hf, a) = {
    if hf-flex-layout {
      if type(hf) == array and hf.len() > 1 {
        if hf.len() == 2 {
          if a == right {
            [#h(1fr) #hf.at(0) #h(1fr) #hf.at(1)]
          } else if a == left {
            [#hf.at(0) #h(1fr) #hf.at(1) #h(1fr)]
          } else {
            [#hf.at(0) #h(1fr) #hf.at(1)]
          }
        } else if hf.len() > 2 {
          [#hf.at(0) #h(1fr) #hf.at(1) #h(1fr) #hf.at(2)]
        } else {
          align(a)[#hf]
        }
      } else {
        align(a)[#hf]
      }
    } else {
      if type(hf) == array and hf.len() > 1 {
        set grid(columns: 3, column-gutter: 1fr)
        if hf.len() == 2 {
          if a == right {
            grid([], [#hf.at(0)], [#hf.at(1)])
          } else if a == left {
            grid([#hf.at(0)], [#hf.at(1)], [])
          } else {
            grid([#hf.at(0)], [], [#hf.at(1)])
          }
        } else if hf.len() > 2 {
          grid([#hf.at(0)], [#hf.at(1)], [#hf.at(2)])
        } else {
          align(a)[#hf]
        }
      } else {
        align(a)[#hf]
      }
    }
  }

  // FIXME - set document font styling
  // if type(set-text-size) == length {
  //   set text(size: set-text-size)
  // } else {
  //   set text(size: 11pt)
  // }

  // if type(set-font) == str and set-font != "" {
  //   set text(font: set-font)
  // }

  set par(
    justify: set-par-justify,
    leading: set-par-leading,
    spacing: set-par-spacing,
    first-line-indent: set-par-first-line-indent,
  )

  let pg = (
    even: 0,
    odd: 1,
    first: 1,
    last: context counter(page).final().at(0),
  )

  page(
    paper: set-paper,
    margin: set-margin,
    foreground: scale(overlay, overlay-size),
    background: rotate(
      watermark-rotation,
      {
        watermark = watermark
        if draft == true { watermark = "DRAFT" }
        if confidential == true {
          watermark = "CONFIDENTIAL"
          watermark-size = 84pt
        }
        if type(watermark) == str {
          text(watermark, size: watermark-size, fill: watermark-color)
        } else { watermark }
      },
    ),
    header: context {
      set text(hf-text-size)
      if counter(page).final().last() > 1 {
        // last page
        if header-last-page != none and counter(page).get().at(0) == pg.last {
          let header-last-page = header-last-page // grab context from outside
          // edit the header data
          if header-last-page.at(0) == "" or header-last-page.at(0) == none { header-last-page.at(0) = header.at(0) }
          if header-last-page.at(1) == "" or header-last-page.at(1) == none { header-last-page.at(1) = header.at(1) }
          if header-last-page.at(2) == "" or header-last-page.at(2) == none { header-last-page.at(2) = header.at(2) }
          // attach the header
          hfdata(header-last-page, header-last-page-alignment)
        } else if counter(page).get().at(0) == pg.last {
          if calc.rem(pg.last, 2) == pg.even and header-even-page != none {
            hfdata(header-even-page, header-alignment)
          } else if calc.rem(pg.last, 2) == pg.odd and header-odd-page != none {
            hfdata(header-odd-page, header-alignment)
          } else {
            hfdata(header, header-alignment)
          }
        }

        // first page
        if counter(page).get().at(0) == pg.first {
          if header-first-page != none {
            let header-first-page = header-first-page // grab context from outside
            // edit the header data
            if type(header-first-page) == array {
              if header-first-page.at(0) == "" or header-first-page.at(0) == none {
                header-first-page.at(0) = header.at(0)
              }
              if header-first-page.at(1) == "" or header-first-page.at(1) == none {
                header-first-page.at(1) = header.at(1)
              }
              if header-first-page.at(2) == "" or header-first-page.at(2) == none {
                header-first-page.at(2) = header.at(2)
              }
            }
            // attach the header
            hfdata(header-first-page, header-first-page-alignment)
          } else {
            if header-odd-page != none {
              hfdata(header-odd-page, header-alignment)
            } else {
              hfdata(header, header-alignment)
            }
          }
        }

        // middle pages
        if counter(page).get().at(0) != pg.first and counter(page).get().at(0) != pg.last {
          if calc.rem(counter(page).get().at(0), 2) == pg.even and header-even-page != none {
            hfdata(header-even-page, header-alignment)
          } else if calc.rem(counter(page).get().at(0), 2) == pg.odd and header-odd-page != none {
            hfdata(header-odd-page, header-alignment)
          } else {
            hfdata(header, header-alignment)
          }
        }
      } else {
        // single page
        hfdata(header, header-alignment)
      }
    },
    footer: context {
      let footer = footer // grab footer context from outside
      set text(hf-text-size)
      // replace a specific position in the footer with a page counter
      if page-count {
        if type(footer) == array {
          if page-count-position == right {
            footer.at(2) = counter(page).display()
          } else if page-count-position == left {
            footer.at(0) = counter(page).display()
          } else {
            footer.at(1) = counter(page).display()
          }
        } else {
          footer = counter(page).display()
        }
      }

      if counter(page).final().last() > 1 {
        // last page
        if footer-last-page != none and counter(page).get().at(0) == counter(page).final().at(0) {
          let footer-last-page = footer-last-page // grab context from outside
          if footer-last-page.at(0) == "" or footer-last-page.at(0) == none { footer-last-page.at(0) = footer.at(0) }
          if footer-last-page.at(1) == "" or footer-last-page.at(1) == none { footer-last-page.at(1) = footer.at(1) }
          if footer-last-page.at(2) == "" or footer-last-page.at(2) == none { footer-last-page.at(2) = footer.at(2) }
          hfdata(footer-last-page, footer-last-page-alignment)
        } else if counter(page).get().at(0) == counter(page).final().at(0) {
          hfdata(footer, footer-alignment)
        }

        // first page
        if counter(page).get().at(0) == pg.first {
          if footer-first-page != none {
            let footer-first-page = footer-first-page // grab context from outside
            // edit the footer data
            if type(footer-first-page) == array {
              if footer-first-page.at(0) == "" or footer-first-page.at(0) == none {
                footer-first-page.at(0) = footer.at(0)
              }
              if footer-first-page.at(1) == "" or footer-first-page.at(1) == none {
                footer-first-page.at(1) = footer.at(1)
              }
              if footer-first-page.at(2) == "" or footer-first-page.at(2) == none {
                footer-first-page.at(2) = footer.at(2)
              }
            }
            // attach the footer
            hfdata(footer-first-page, footer-first-page-alignment)
          } else {
            if footer-odd-page != none {
              hfdata(footer-odd-page, footer-alignment)
            } else {
              hfdata(footer, footer-alignment)
            }
          }
        }

        // middle pages
        if counter(page).get().at(0) != 1 and counter(page).get().at(0) != counter(page).final().at(0) {
          hfdata(footer, footer-alignment)
        }
      } else {
        // single page
        hfdata(footer, footer-alignment)
      }
    },
    doc,
  )
}
