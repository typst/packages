#import "@preview/subpar:0.2.2"
#import "states.typ": *
#import "utils.typ": *
#import "main.typ":  change-locale, hide-page-number, set-header-title, set-equations, set-figures, set-terminology, set-locale, start-at-odd-page, split-locale, localise, convert-text-arg

#let extended-abstract(
  authors: auto,
  title: auto,
  supervisors: auto,
  multiple-supervisors: auto,
  counsellors: auto,
  multiple-counsellors: auto,
  language: auto,
  region: auto,
  keywords: auto,
  terminology: (math-equation: (supplement: none)),
  flyleaf: auto,
  font: auto,
  font-size: 10pt,
  math-font: auto,
  math-font-size: auto,
  equation-numbering: "(1)",
  equation-left-margin: auto,
  title-text: auto,
  author-text: auto,
  figure-kinds: (:),
  figure-numbering: (table: "I"),
  figure-fill: none,
  figure-inset: auto,
  figure-text: auto,
  caption-position: auto,
  caption-align: auto,
  caption-text-align: left,
  caption-separator: auto,
  caption-text: auto, // (table: smallcaps),
  caption-prefix-text: none,
  subfigure-caption-position: auto,
  subfigure-caption-align: auto,
  subfigure-caption-text-align: auto,
  subfigure-caption-sep: auto,
  subfigure-numbering: auto,
  subfigure-ref-numbering: auto,
  subfigure-caption-text: auto,
  subfigure-caption-prefix-text: auto,
  figure-ref-text: none,
  label: none,
  body,
) = context {
  let locale = split-locale(language, region: region)

  //   let the-store = "ea-" + locale.locale  // store name dependent on context gives convergence problems

  let the-store = "ea-" + if type(language)==str {language} else {repr(language)} + "-" + if type(region)==str {region} else {repr(region)} + "-" + if type(label)==std.label {str(label)} else {str(repr(body).len())}

  let the-localise = localise.with(locale: locale.locale)

  let the-terminology = the-localise(terminology-defaults.get())

  let the-figure-kinds = (:)

  for (key, value) in figure-kinds {
    the-figure-kinds.insert("figure-" + key, value)
  }

  the-terminology = merge-dictionaries(the-terminology, merge-dictionaries(
    the-localise(terminology),
    the-localise(the-figure-kinds),
  ))

  let the-figure-settings = (:)

  let m-figure-settings = figure-settings.get().at(store.get(), default: none) // error without default: none (why?)


  let auto-settings(dict) = {
    let new-dict = (:)
    for (key, value) in dict {
      new-dict.insert(key, if value == auto { m-figure-settings.at(key) } else {
        value
      })
    }
    new-dict
  }

  let the-figure-kinds-names = figure-kinds.keys()

  if m-figure-settings != none {
    // can probably be avoided by initialising figure-settings with values for "m" in states.typ

    the-figure-kinds-names += m-figure-settings.figure-kinds //the-figure-kinds-names: new and existing user-defined figure kinds

    the-figure-settings += auto-settings((
      figure-fill: figure-fill,
      figure-inset: figure-inset,
      figure-numbering: figure-numbering,
      caption-position: caption-position,
      caption-align: caption-align,
      caption-text-align: caption-text-align,
      caption-separator: caption-separator,
      subfigure-caption-position: subfigure-caption-position,
      subfigure-caption-align: subfigure-caption-align,
      subfigure-caption-text-align: subfigure-caption-text-align,
      subfigure-numbering: subfigure-numbering,
      subfigure-ref-numbering: subfigure-ref-numbering,
      subfigure-caption-sep: subfigure-caption-sep,
    ))

    if subfigure-ref-numbering == auto and subfigure-numbering != auto {
      the-figure-settings.insert("subfigure-ref-numbering", auto)
    }

    the-figure-settings += (
      figure-text: figure-text,
      caption-text: caption-text,
      caption-prefix-text: caption-prefix-text,
      subfigure-caption-text: subfigure-caption-text,
      subfigure-caption-prefix-text: subfigure-caption-prefix-text,
      figure-ref-text: figure-ref-text,
    )
  }

  let the-authors = the-localise(if authors == auto {
    thesis-authors.get()
  } else { authors })
  let the-title = the-localise(if title == auto { thesis-title.get() } else {
    title
  })

  let the-supervisors = the-localise(if supervisors == auto {
    thesis-supervisors.get()
  } else { supervisors })
  let the-multiple-supervisors = if (
    multiple-supervisors == auto or type(multiple-supervisors) != bool
  ) {
    thesis-multiple-supervisors.get()
  } else { multiple-supervisors }

  let the-counsellors = the-localise(if counsellors == auto {
    thesis-counsellors.get()
  } else { counsellors })
  let the-multiple-counsellors = if (
    multiple-counsellors == auto or type(multiple-counsellors) != bool
  ) {
    thesis-multiple-counsellors.get()
  } else { multiple-counsellors }

  let base-font = if (font == auto) { text.font } else { font }
  let base-font-size = if (font-size == auto) { text.size } else { font-size }

  set text(font: base-font, size: base-font-size)

  let the-flyleaf = if flyleaf == auto { show-heading.get() } else { flyleaf }

  if the-flyleaf {
    set heading(outlined: false, bookmarked: false) // ToC & bookmarks refer to the first page of the abstract directly
    [= #the-terminology.extended-abstract]
    hide-page-number
//     set-header-title(the-terminology.extended-abstract)
  }
  set-header-title(the-terminology.extended-abstract)
  start-at-odd-page()
  header-on-page.update(true)
  set page(columns: 2)

  store.update(the-store)

  {
    show: set-locale(locale, store: the-store)

    show: set-figures(
      base-font: base-font,
      base-font-size: base-font-size,
      figure-kinds: the-figure-kinds-names,
      ..the-figure-settings,
      store: the-store,
    )

    show: set-terminology(
      the-terminology,
      figure-kinds: the-figure-kinds-names,
      store: the-store,
    )

    show: set-equations(
      math-font: math-font,
      math-font-size: math-font-size,
      base-font-size: base-font-size,
      equation-numbering: equation-numbering,
      store: the-store,
    )

    //     show: alexandria(prefix: bib-prefix, read: read)

    if keywords != auto { thesis-keywords.update(keywords) }

    set bibliography(title: the-terminology.references)

    set figure(outlined: false)

    place(top + center, float: true, scope: "parent", {
//       if not the-flyleaf {
        show heading: it => {} // just create an entry for the toc
        [= #the-terminology.extended-abstract]
//       }
      par({
        set text(size: 2.4 * base-font-size, hyphenate: false) // default title text size
//         set text(..title-text) if type(title-text) == dictionary
//         if type(title-text) == function { title-text(the-title) } else {
//           the-title
//         }
        [ #convert-text-arg(title-text)(the-title) #label]
      })
      set text(size: 1.2 * base-font-size) // default author text size
      set text(..author-text) if type(author-text) == dictionary
      let the-authors-text = if type(the-authors) == array {
        the-authors.join(", ", last: get-prefix-last(
          the-terminology,
          the-supervisors.len(),
        ))
      } else { the-authors }
      par(if type(author-text) == function {
        author-text(the-authors-text)
      } else { the-authors-text })
      let the-supervisors-text = {
        if the-multiple-supervisors [#the-terminology.supervisor.at(1): ] else [#the-terminology.supervisor.at(0): ]
        if type(the-supervisors) == array {
          the-supervisors.join(", ", last: get-prefix-last(
            the-terminology,
            the-supervisors.len(),
          ))
        } else { the-supervisors }
        if the-counsellors != none {
          linebreak()
          if the-multiple-counsellors [#the-terminology.counsellor.at(1): ] else [#the-terminology.counsellor.at(0): ]
          if type(the-counsellors) == array {
            the-counsellors.join(", ", last: get-prefix-last(
              the-terminology,
              the-supervisors.len(),
            ))
          } else { the-counsellors }
        }
      }
      par(if type(author-text) == function {
        show text: author-text
        the-supervisors-text
      } else { the-supervisors-text })
      v(1em)
    })

    let heading-numbering = ("I.", "A.", "a.", "i.", "1.")
    set heading(outlined: false, bookmarked: false, numbering: (
      ..num,
    ) => numbering(heading-numbering.at(num.pos().len() - 1), num.pos().last()))

    counter(heading).update(0)
    show heading: set text(
      size: 1 * base-font-size,
      weight: "regular",
      style: "italic",
    )

    show heading: it => {
      it
      set-header-title(the-terminology.extended-abstract) // in show rule of heading header-title is set to auto, thus overrule this again
    }

    show heading.where(level: 1): it => {
      set text(style: "normal")
      align(center, smallcaps(
        if it.numbering != none {
          numbering(it.numbering, ..counter(heading).get()) + h(0.35em)
        }
          + it.body,
      ))
    }

    body
  }

  store.update(store.get()) // previous store
  start-at-odd-page()
  set page(columns: 1)
  set-header-title(auto)
  // reset counters  (only needed if content without per-chapter-numbering follows)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  for kind in the-figure-kinds-names {
    counter(figure.where(kind: kind)).update(0)
  }
}


#let abstract-keywords(
  keywords: auto,
  language: auto,
  region: auto,
  show-abstract: auto,
  body,
) = context {
  let the-store = store.get()
  let in-extended-abstract = the-store.match(regex("^ea-")) != none

  let the-show-abstract = if show-abstract == auto {
    in-extended-abstract
  } else { show-abstract }
  //   let locale=get-locale(language, region, default: if in-extended-abstract {the-store.slice(3)} else {auto} )
  // om een of andere reden kan bij een ea the current-locale nog niet gevonden worden, hoewel die wel ingesteld is. store is wel aangepast (store.get() werkt), maar locales.get().at(the-store) gaat niet (toch niet in eerste instantie) -> er zat een fout in set-locale

  let locale = split-locale(language, region: region)

  let the-body = context {
    let the-terminology = terminologies.get().at(store.get())
    if body not in (none, []) {
      block({
        set par(spacing: 0.65em, first-line-indent: 1.5em)
        if the-show-abstract {
          text(weight: "semibold", style: "italic", the-terminology.abstract)
        }
        body
      })
    }
    let the-keywords = localise(locale: locale.locale, if keywords == auto {
      thesis-keywords.get()
    } else { keywords })
    if the-keywords != none {
      block({
        text(weight: "semibold", style: "italic", the-terminology.keywords)
        if type(the-keywords) == array { the-keywords.join(", ") } else {
          the-keywords
        }
      })
    }
  }
  if in-extended-abstract {
    set text(
      size: 0.9em,
      weight: "semibold",
      lang: locale.language,
      region: locale.region,
    )
    the-body
    // still in same context as at the start => the previous store
    store.update(the-store)
  } else {
    change-locale(language: language, region: region, the-body)
  }
}

