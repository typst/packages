/*
  edgeframe by neuralpain

  For quick paper setups.

  Github Repository: https://github.com/neuralpain/edgeframe
  Typst Universe: https://typst.app/universe/package/edgeframe
*/

#import "defaults.typ": ef-defaults, margin
#import "hfdisplay.typ": hfdisplay
#import "util.typ": xlinebreak, xpagebreak

/// Headers and footers have a maximum of 3 positions
#let ef-document(
  // -------------------------------------------------------------- PAPER CONFIG
  paper: "us-letter",
  margin: margin.normal,
  hf-flex: true,
  hf-text-size: none,
  // -------------------------------------------------------------------- HEADER
  header: (
    content: (none, none, none), // explicit config notation
    first-page: none,
    last-page: none,
    alignment: center,
    alignment-first-page: center,
    alignment-last-page: center,
    even-page: none,
    odd-page: none,
  ),
  // -------------------------------------------------------------------- FOOTER
  footer: (
    content: (none, none, none), // explicit config notation
    first-page: none,
    last-page: none,
    alignment: center,
    alignment-first-page: center,
    alignment-last-page: center,
    even-page: none,
    odd-page: none,
  ),
  // ---------------------------------------------------------------- PAGE COUNT
  page-count: false,
  page-count-first-page: true,
  page-count-position: center,
  // ------------------------------------------------------------------- OVERLAY
  overlay: none,
  overlay-size: 12pt,
  overlay-color: luma(0),
  overlay-rotation: 0deg,
  overlay-scale: 100%,
  // ----------------------------------------------------------------- WATERMARK
  watermark: "",
  watermark-size: 15em,
  watermark-color: luma(0, 20%),
  watermark-rotation: -45deg,
  watermark-scale: 100%,
  // -------------------------------------------------------------- RESTRICTIONS
  draft: false,
  confidential: false,
  // -------------------------------------------------------------- PARAGRAPHING
  paragraph: (
    first-line-indent: 0em,
    hanging-indent: 0pt,
    justify: false,
    leading: 0.75em,
    spacing: 1em,
  ),
  // --------------------------------------------------------------------- LISTS
  bullet-list: (
    body-indent: 0.5em,
    indent: 0pt,
    marker: ([•], [‣], [–]),
    spacing: auto,
    tight: true,
  ),
  number-list: (
    body-indent: 0.5em,
    full: false,
    indent: 0pt,
    number-align: end + top,
    numbering: "1.",
    reversed: false,
    spacing: auto,
    start: auto,
    tight: true,
  ),
  doc,
) = {
  let pg = (
    even: 0,
    odd: 1,
    first: 1,
    last: none, // last page number is unavailable outside page context and
                // will be set within the respective header-footer contexts
  )

  /*
    Fill in the missing defaults since editing the dictionaries will replace the
    entire value, thereby deleting the keys along with it.
  */

  header = (
    content: if "content" in header { header.content } else if type(header) == str {
      header // no other values necessary; just display the header
    } else { none }, // content key is missing; do not display
    first-page: if "first-page" in header { header.first-page } else { none },
    last-page: if "last-page" in header { header.last-page } else { none },
    alignment: if "alignment" in header { header.alignment } else { center },
    alignment-first-page: if "alignment-first-page" in header { header.alignment-first-page } else { center },
    alignment-last-page: if "alignment-last-page" in header { header.alignment-last-page } else { center },
    even-page: if "even-page" in header { header.even-page } else { none },
    odd-page: if "odd-page" in header { header.odd-page } else { none },
  )

  footer = (
    content: if "content" in footer { footer.content } else if type(footer) == str {
      footer // no other values necessary; just display the footer
    } else { none }, // content key is missing; do not display
    first-page: if "first-page" in footer { footer.first-page } else { none },
    last-page: if "last-page" in footer { footer.last-page } else { none },
    alignment: if "alignment" in footer { footer.alignment } else { center },
    alignment-first-page: if "alignment-first-page" in footer { footer.alignment-first-page } else { center },
    alignment-last-page: if "alignment-last-page" in footer { footer.alignment-last-page } else { center },
    even-page: if "even-page" in footer { footer.even-page } else { none },
    odd-page: if "odd-page" in footer { footer.odd-page } else { none },
  )

  paragraph = (
    first-line-indent: if "first-line-indent" in paragraph { paragraph.first-line-indent } else { 0em },
    hanging-indent: if "hanging-indent" in paragraph { paragraph.hanging-indent } else { 0pt },
    justify: if "justify" in paragraph { paragraph.justify } else { false },
    leading: if "leading" in paragraph { paragraph.leading } else { 0.75em },
    spacing: if "spacing" in paragraph { paragraph.spacing } else { 1em },
  )

  bullet-list = (
    body-indent: if "body-indent" in bullet-list { bullet-list.body-indent } else { 0.5em },
    indent: if "indent" in bullet-list { bullet-list.indent } else { 0pt },
    marker: if "marker" in bullet-list { bullet-list.marker } else { ([•], [‣], [–]) },
    spacing: if "spacing" in bullet-list { bullet-list.spacing } else { auto },
    tight: if "tight" in bullet-list { bullet-list.tight } else { true },
  )

  number-list = (
    body-indent: if "body-indent" in number-list { number-list.body-indent } else { 0.5em },
    full: if "full" in number-list { number-list.full } else { false },
    indent: if "indent" in number-list { number-list.indent } else { 0pt },
    number-align: if "number-align" in number-list { number-list.number-align } else { end + top },
    numbering: if "numbering" in number-list { number-list.numbering } else { "1." },
    reversed: if "reversed" in number-list { number-list.reversed } else { false },
    spacing: if "spacing" in number-list { number-list.spacing } else { auto },
    start: if "start" in number-list { number-list.start } else { auto },
    tight: if "tight" in number-list { number-list.tight } else { true },
  )

  // ---------------------------------------------------------- PROCESS DOCUMENT

  set list(
    body-indent: bullet-list.body-indent,
    indent: bullet-list.indent,
    marker: bullet-list.marker,
    spacing: bullet-list.spacing,
    tight: bullet-list.tight,
  )

  set enum(
    body-indent: number-list.body-indent,
    full: number-list.full,
    indent: number-list.indent,
    number-align: number-list.number-align,
    numbering: number-list.numbering,
    reversed: number-list.reversed,
    spacing: number-list.spacing,
    start: number-list.start,
    tight: number-list.tight,
  )

  set par(
    first-line-indent: paragraph.first-line-indent,
    hanging-indent: paragraph.hanging-indent,
    justify: paragraph.justify,
    leading: paragraph.leading,
    spacing: paragraph.spacing,
  )

  page(
    paper: paper,
    margin: margin,
    foreground: scale(
      {
        rotate(
          overlay-rotation,
          {
            let overlay = overlay
            if type(overlay) == str {
              text(overlay, size: overlay-size, fill: overlay-color)
            } else { overlay }
          },
        )
      },
      overlay-scale,
    ),
    background: scale(
      {
        rotate(
          watermark-rotation,
          {
            let watermark = watermark
            if draft == true { watermark = "DRAFT" }
            if confidential == true {
              watermark = "CONFIDENTIAL"
              watermark-size = 84pt
            }
            if type(watermark) == str {
              text(watermark, size: watermark-size, fill: watermark-color)
            } else { watermark }
          },
        )
      },
      watermark-scale,
    ),
    header: context {
      if hf-text-size != none {
        set text(hf-text-size)
      }

      let pg = pg // copy from outside the current context
      pg.last = counter(page).final().at(0)

      hfdisplay(header, pg, hf-flex)
    },
    footer: context {
      if hf-text-size != none {
        set text(hf-text-size)
      }

      let pg = pg
      pg.last = counter(page).final().at(0)

      let footer = footer // copy from outside the current context

      // -------------------------------------------------- DISPLAY PAGE NUMBERS
      if page-count and counter(page).get().at(0) == pg.first and not page-count-first-page {
        none // return nothing on the first page and default to displaying
             // the footer text instead
      } else if page-count {
        if type(footer.content) == array {
          if page-count-position == right {
            footer.content.at(2) = counter(page).display()
          } else if page-count-position == left {
            footer.content.at(0) = counter(page).display()
          } else {
            footer.content.at(1) = counter(page).display()
          }
        } else {
          footer.content = counter(page).display()
        }
      }

      hfdisplay(footer, pg, hf-flex)
    },
    doc,
  )
}
