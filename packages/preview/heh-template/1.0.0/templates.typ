#import "/pages/cover-page.typ": heh-cover-page
#import "/pages/presentation-cover-page.typ": presentation-cover-page
#import "/pages/tfe-cover-page.typ": tfe-cover-page
#import "/pages/outline.typ": heh-outline-page
#import "/pages/blank-page.typ": heh-blank-page
#import "/pages/thanks.typ": thanks-page

#import "/data/config.typ"
#import "/data/campus.typ"

#import "/utils/states.typ": heh-config
#import "/utils/presentations.typ": slidegroup

#import "/components/headers/headers.typ"
#import "/components/footers/footers.typ"
#import "/components/boxes.typ": hint, important, info, silly
#import "/components/double-table.typ": double-table

#import "/style/defaults.typ" as style-defaults

#import "@preview/polylux:0.4.0": enable-handout-mode, slide

#let heh-common-template(doc) = context {
  let config = heh-config.get()

  set text(font: (config.print.font, "Open Sans"), lang: config.print.lang)
  set document(title: config.document.description)
  show: style-defaults.heh-images-defaults
  show: style-defaults.heh-style-defaults

  doc
}

#let heh-document(
  document-config-fn: config.default-document-config,
  print-config-fn: config.default-print-config,
  campus-config-fn: campus.dst-config,

  header-style: headers.logo-year-title,
  footer-style: footers.page-numbers,

  doc,
) = context {
  let document-config = document-config-fn()
  let print-config = print-config-fn()
  let campus-config-fn = campus-config-fn

  if print-config.monochrome {
    campus-config-fn = campus-config-fn.with(
      style: campus.default-style-config.with(
        primary-color: black,
        onprimary-color: white,
        decorations-color: black,
      ),
    )
  }

  let campus-config = campus-config-fn()

  let conf = (
    document: document-config,
    print: print-config,
    campus: campus-config,
  )
  heh-config.update(conf)

  show: heh-common-template

  set page("a4")
  set heading(numbering: "1.")

  heh-cover-page()
  pagebreak()

  set page(
    header: context header-style(),
    margin: (top: 125pt),
  )

  heh-outline-page()
  heh-blank-page()

  set page(footer: context footer-style())

  counter(page).update(1)
  doc
}

#let heh-presentation(
  document-config-fn: config.default-document-config,
  print-config-fn: config.default-print-config,
  campus-config-fn: campus.dst-config,

  handout-mode: false,
  doc,
) = context {
  let document-config = document-config-fn()
  let print-config = print-config-fn()
  let campus-config-fn = campus-config-fn

  if print-config.monochrome {
    campus-config-fn = campus-config-fn.with(
      style: campus.default-style-config.with(
        primary-color: black,
        onprimary-color: white,
        decorations-color: black,
      ),
    )
  }

  let campus-config = campus-config-fn()

  let conf = (
    document: document-config,
    print: print-config,
    campus: campus-config,
  )
  heh-config.update(conf)
  enable-handout-mode(handout-mode)

  set text(size: 20pt)
  show: heh-common-template
  set page(
    "presentation-16-9",

    header: context { headers.presentation-header() },
    footer: context { footers.presentation-footer() },
    margin: (top: 100pt, x: 30pt),
  )

  slide[#presentation-cover-page()]

  show heading.where(level: 2): none

  doc
}

#let heh-tfe(
  document-config-fn: config.default-document-config,
  print-config-fn: config.default-print-config,

  campus-config-fn: campus.dst-config,

  header-style: headers.logo-year-title,
  footer-style: footers.page-numbers,

  doc,
) = {
  let document-config = document-config-fn()
  let print-config = print-config-fn()
  let campus-config-fn = campus-config-fn

  if print-config.monochrome {
    campus-config-fn = campus-config-fn.with(
      style: campus.default-style-config.with(
        primary-color: black,
        onprimary-color: white,
        decorations-color: black,
      ),
    )
  }

  let campus-config = campus-config-fn()

  let conf = (
    document: document-config,
    print: print-config,
    campus: campus-config,
  )
  heh-config.update(conf)

  show: heh-common-template
  set page("a4")
  set heading(numbering: "1.")

  show: style-defaults.heh-images-defaults.with()
  show: style-defaults.heh-style-defaults.with()

  tfe-cover-page()
  pagebreak()
  tfe-cover-page(show-year: true)

  thanks-page()

  set page(
    header: context header-style(),
    margin: (top: 125pt),
  )

  heh-outline-page()

  heh-blank-page()

  set page(
    footer: context footer-style(),
  )

  counter(page).update(1)

  doc
}
