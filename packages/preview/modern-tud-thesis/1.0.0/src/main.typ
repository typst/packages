

#import "/src/utils.typ": i18n

#import "/src/fonts.typ": fonts
#import "/src/geometry.typ": geometry
#import "/src/opinionated.typ": opinionated

#import "/src/elements/logo.typ": logo
#import "/src/elements/titlepage.typ": titlepage
#import "/src/elements/colors.typ": colors, set-colors
#import "/src/elements/sections.typ": frontmatter, maincontent
#import "/src/elements/bibliography.typ": bibliography
#import "/src/elements/outlines.typ": conditional_outline

#let merge-default-settings(settings, default) = {
  let result = default
  for key in settings.keys() {
    if key in default and type(settings.at(key)) == "dict" and type(default.at(key)) == "dict" {
      result.insert(key, merge-default-settings(settings.at(key), default.at(key)))
    } else {
      result.insert(key, settings.at(key))
    }
  }
  result
}

#let modern-tud-thesis(
  doc,
  target: "digital",

  title: none,
  thesis-type: none,

  faculty: none,
  chair: none,
  
  authors: (),
  supervisors: (),
  submissionplace: none,
  submissiondate: datetime.today(),

  abstract: [],
  number-of-attachments: none,

  appearance: (:)
) = {
  appearance = merge-default-settings(
    appearance,
    (
      primary-color: colors.brilliantblue,
      secondary-color: colors.blue-1,
      tertiary-color: colors.blue-2,
      bibliography: auto,
      outlines: auto,
      titlepage: "simple",
      black-headlines: false
    )
  )

  if not (target in ("digital", "print", "print-alternating")) {
    target = "print"
  }

  set-colors(
    primary: appearance.primary-color,
    secondary: appearance.secondary-color,
    tertiary: appearance.tertiary-color
  )

  show: fonts.with(black-headlines: appearance.black-headlines)
  show: geometry.with(target: target)
  show: opinionated.with(target: target)

  [
    #metadata(submissionplace) <vstl:submissionplace>
    #metadata(submissiondate) <vstl:submissiondate>
  ]
  
  // Document properties
  set document(
    title: title,
    author: authors.map(author => author.name)
  )

  show: frontmatter.with(internal: true)

  titlepage(
    target: target,

    title: title,
    thesis-type: thesis-type,
    faculty: faculty,
    chair: chair,
    authors: authors,
    supervisors: supervisors,
    submissionplace: submissionplace,

    titlepage: appearance.titlepage,
  )

  bibliography(
    title: title,
    authors: authors,
    faculty: faculty,
    thesis-type: thesis-type,
    chair: chair,
    abstract: abstract,
    showbibliography: appearance.bibliography,
    number-of-attachments: number-of-attachments
  )

  if appearance.outlines != false {
    if appearance.outlines == auto or appearance.outlines.contains("references") {
      outline()
      pagebreak()
    }
    
    if appearance.outlines == auto or appearance.outlines.contains("table") {
      conditional_outline(figure.where(kind: table), i18n("outline-table"))
    }
    
    if appearance.outlines == auto or appearance.outlines.contains("image") {
      conditional_outline(figure.where(kind: image), i18n("outline-image"))
    }
  }

  [#metadata(none) <maincontent-start>]
  show: maincontent

  doc
}