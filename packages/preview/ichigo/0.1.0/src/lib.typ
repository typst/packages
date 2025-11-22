#import "@preview/linguify:0.4.1": load_ftl_data, linguify
#import "@preview/numbly:0.1.0": numbly
#import "@preview/valkyrie:0.2.1" as z

#import "model.typ" as model
#import "title.typ": title-content

#let languages = (
  "zh",
  "en",
)
#let lgf_db = eval(load_ftl_data("./L10n", languages))
#let linguify = linguify.with(from: lgf_db)

/// Main document processing function
///
/// - doc (content): the whole document
/// - course-name (str): the name of the course, must be provided
/// - serial-str (str): the serial number of the document, must be provided
/// - author-info (content): the author information, default to `[]`
/// - author-names (array | str): the array of author names, default to `""`
///
/// - title-style (str | none): expected to be `"whole-page"`, `none` or `"simple"`, default to `"whole-page"`
/// -> doc
#let config(
  doc,
  course-name: none,
  serial-str: none,
  author-info: [],
  author-names: "",
  heading-numberings: (none, none, "(1)", "a."),
  title-style: "whole-page",
  theme-name: "simple",
  ..opt,
) = {
  let meta = (
    course-name: course-name,
    serial-str: serial-str,
    author-info: author-info,
    author-names: author-names,
    ..opt.named(),
  )
  title-style = z.parse(title-style, model.title-style)
  meta = z.parse(meta, model.meta-schema)
  z.parse(theme-name, model.theme-name)

  let theme = model.get-theme(theme-name)
  theme = z.parse(theme(meta), model.theme-schema, scope: (theme-name,))

  return {
    // Document metadata
    set document(
      title: meta.course-name + "-" + meta.serial-str,
      author: meta.author-names,
    )

    // heading numbering
    set heading(numbering: (..n) => {
      let (..n) = n.pos()
      let numb = heading-numberings.at(
        n.len() - 1,
        default: heading-numberings.last(),
      )
      numb = if numb != none {
        numbering(numb, n.last())
      } else {
        none
      }
      return numb
    })

    // Page header & footer
    set page(
      header: (theme.page-setting.header)(),
      footer: (theme.page-setting.footer)(),
    )

    // Fonts
    set text(font: theme.fonts.text)
    show heading: set text(font: theme.fonts.heading)
    show math.equation: set text(font: theme.fonts.equation)

    // Title
    title-content(meta, theme, title-style)

    if title-style == "whole-page" {
      counter(page).update(x => x - 1)
    }

    doc
  }
}

#let top-prob-counter = state("ichigo.top-prob-counter", 0)

#let prob(
  question,
  solution,
  title: auto,
) = {
  if title == auto {
    title = context [#linguify("problem") #top-prob-counter.get().]
  }
  return [
    #top-prob-counter.update(x => x + 1)
    = #title
    #set heading(offset: 2)
    #question
    #set heading(offset: 1)
    = #linguify("solution")
    #set heading(offset: 2)
    #solution
  ]
}
