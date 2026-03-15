#import "defaults.typ": *

/// Deal with what was supplied through `authors` and `group` to the template
///
/// See also : https://typst.app/docs/reference/foundations/arguments/#argument-sinks
#let authors-helper(group, authors) = {
  let _type = type(authors)

  let _prefix
  let _authors
  let _group = if (group != none and _type != type(none)) [ -- #group]

  if (_type == array) {
    // If there are many authors, we want something like `Auteurs : Auteur-1, Auteur-2 et Auteur-3`
    let _len = authors.len()
    _prefix = if (_len > 1) [Auteurs : ] else [Auteur : ]
    _authors = authors.join(", ", last: " et ")
  } else if (_type == content) {
    // If a content block is provided, display with minimal tampering
    _prefix = []
    _authors = authors
  } else if (_type != type(none)) {
    panic(
      prefix-errors + "Please provide either an `array`, `content` block or `none` (leave empty) for field `authors`.",
    )
  }

  return text(weight: "bold", _prefix) + _authors + _group
}

/// Deal with what was supplied through `headline` to the template
#let headline-helper(headline) = {
  let _type = type(headline)
  let output

  if _type == dictionary {
    let _keys = headline.keys()
    assert(
      "lead" in _keys and "title" in _keys,
      message: prefix-errors
        + "If you provide `headline` as a `dictionary`, it should possess keys `\"lead\"` and `\"title\"`. You may also pass `content?` to `headline`.",
    )
    output = [
      // Lead
      #v(-2pt)
      #text(
        size: fsize-headline.at(0),
        headline.at("lead"),
      )
      #v(weak: true, 8pt)
      // Title
      #text(
        headline.at("title"),
      )
    ]
  } else { output = text(headline) }

  return {
    set text(weight: "bold", fill: color-headline, size: fsize-headline.at(1))
    output
  }
}

/// Handle the display of appendices headings
#let appendix-heading-helper(title: none, lbl: none, supplement: none) = {
  // These should not display in the document's main outline
  set heading(supplement: supplement)

  show heading.where(level: 1): it => block(width: 100%)[
    #text(
      size: fsize-heading.at(0),
      weight: "bold",
    )[
      #it.supplement
      #context counter(heading).display()
      #h(indent-heading)
      #it.body
      #{ v(vspacing-appendices-heading) }
    ]
  ]

  [#heading(level: 1, title) #lbl]
}

#let appendix(
  title: none,
  lbl: none,
  body,
) = {
  if lbl != none {
    assert.eq(
      type(lbl),
      label,
      message: prefix-errors
        + "`lbl` should be a `label`. You can use it in your document to reference the appendix in question.",
    )
  }
  return (title: title, lbl: lbl, body: body)
}

#let appendices-section(
  appendices: none,
  outlined: true,
  pagebreak-after-outline: false,
  headline: "Annexes",
  supplement: "Annexe",
  outline-title: "Table des annexes",
) = {
  assert.eq(type(appendices), array, message: prefix-errors + "`appendices` should be an `array`.")

  pagebreak(weak: true)

  /* -------------------------------- Headline -------------------------------- */

  {
    show text: set align(center)
    set text(font: ffam-special)

    show heading.where(level: 1): it => text(
      size: fsize-headline.at(1),
      fill: black,
      weight: "bold",
      it.body,
    )

    rect(
      width: 100%,
      radius: 0%,
      inset: (top: 8pt, bottom: 9pt),
      stroke: 0.7pt,
    )[
      #heading(level: 1, headline)
    ]
  }

  /* --------------------------------- Outline -------------------------------- */

  if outlined {
    // Outline title style
    show heading.where(level: 1): it => {
      set align(left)
      text(
        size: fsize-appendices-outline-title.at(0),
        font: ffam-special,
        weight: "bold",
      )[
        #it.body
        #v(vspacing-appendices-outline)
      ]
    }

    show outline.entry: set text(font: ffam-base)

    show outline.entry: it => link(
      it.element.location(),
      it.indented(
        {
          set text(weight: 500)
          [#it.element.supplement ] + it.prefix() + if it.element.body != [] [ :] // Do not display `:` if the body is empty
        },
        it.inner(),
      ),
    )

    // Display the outline
    outline(
      title: outline-title,
      target: heading.where(level: 1).after(label(metadata-appendices-start)).before(label(metadata-appendices-end)),
    )
    v(0.5cm) // To set it apart from a potential heading

    if pagebreak-after-outline {
      pagebreak()
    }
  }

  /* --------------------------------- Display -------------------------------- */

  let _len = appendices.len()

  // Capture the context before displaying the appendices
  context {
    // This requires the `context`
    let _counter-snapshot = counter(heading).get()

    // Apply appendices-specific heading numbering
    set heading(numbering: style-numbering-appendices, bookmarked: false)

    // Forbid the use of level 1 headings, as it's already what appendices' titles are
    show heading: it => if it.level == 1 {
      panic(
        prefix-errors
          + "Headings of `level == 1` aren't supported in appendices ; but you may use headings of `level >= 2` instead.",
      )
    } else if it.level <= 4 {
      block(
        width: 100%,
      )[ #context counter(heading).display() #it.body ] // "reset" the style of other headings (see https://github.com/typst/typst/issues/420)
    } else { it }

    // Flag this point as the beginning of the appendix section
    [ #metadata("appendix-start") #label(metadata-appendices-start) ]
    counter(heading).update(0)

    // Craft and display the different appendices
    for i in range(_len) {
      assert.eq(
        type(appendices.at(i)),
        dictionary,
        message: prefix-errors
          + "Got incorrect values in `appendices`. Each element of the array should be created using the `appendix` function.",
      )
      let _keys = appendices.at(i).keys()
      assert(
        "title" in _keys and "lbl" in _keys and "body" in _keys,
        message: prefix-errors
          + "Got incorrect values in `appendices`. Each element of the array should be created using the `appendix` function.",
      )

      // Display the title
      appendix-heading-helper(
        title: appendices.at(i).at("title"),
        lbl: appendices.at(i).at("lbl"),
        supplement: supplement,
      )

      // Display the body
      appendices.at(i).at("body")

      // And remember to insert a page break ; except for the last one
      if i != _len - 1 { pagebreak() }
    }

    // Flag this point as the end of the appendix section
    [ #metadata("appendix-end") #label(metadata-appendices-end) ]
    // Restore the initial state of the counter
    counter(heading).update(_counter-snapshot)
  }
}
