#import "translations.typ": *
#import "utils.typ": *

#let formatted-header(
  draft: bool,
  lang: str,
  print: bool,
) = {
  text(context {
    let headings = query(heading.where(level: 1))
    let current-page = here().page()

    let current-heading = none
    for h in headings {
      if h.location().page() == current-page {
        current-heading = h
        break
      } else if h.location().page() > current-page {
        break
      }
    }

    if current-heading == none {
      for h in headings {
        if h.location().page() < current-page {
          current-heading = h
        } else {
          break
        }
      }
    }

    if current-heading != none {
      let p = here().page()
      let header-draft = {
        if draft {
          [
            #text(hm-color)[#translations.draft -- #translations.as-of: #custom-date-format(datetime.today(), lang: lang, pattern: "dd.MM.y")]
          ]
        }
      }

      let heading-left = {
        current-heading.body
        h(1fr)
        header-draft
      }

      if (print) {
        if (calc.even(p)) {
          heading-left
        } else {
          header-draft
          h(1fr)
          current-heading.body
        }
      } else { heading-left }
    }
  })
  v(-0.5em)
  line(length: 100%, stroke: 0.05em)
}

#let formatted-footer(
  print: bool,
  numbering: str
) = {
  context {
    let p = here().page()

    let page-number = counter(page).display(numbering)

    if (print) {
      if calc.even(p) {
        align(left, page-number)
      } else {
        align(right, page-number)
      }
    } else {
      align(right, page-number)
    }
  }
}
