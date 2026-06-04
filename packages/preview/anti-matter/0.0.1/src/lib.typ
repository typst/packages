// avoid exporting util
#let (
  anti-front-end,
  anti-back-start,
  anti-outer-counter,
  anti-inner-counter,
  anti-active-counter-at,
  anti-page-at,
  anti-page,
  anti-header,
  anti-thesis,
  anti-matter,
) = {
  // TODO: I think the spec could be removed in favor of loc.page-numbering()

  // validate spec
  let assert-spec-valid(spec) = {
    if type(spec) != dictionary {
      panic("spec must be a dictionary, was " + type(spec))
    }

    if spec.len() != 3 {
      panic("spec must be exactly 3 elements long, was " + str(spec.len()))
    }

    if "front" not in spec { panic("missing front key") }
    if "inner" not in spec { panic("missing inner key") }
    if "back" not in spec { panic("missing back key") }
  }

  let label-front-end = <anti-matter:front:end>
  let label-back-start = <anti-matter:back:start>

  // get matter and correction at given loc
  let where-am-i(spec, loc) = {
    let front-matter = query(label-front-end, loc)
    let back-matter = query(label-back-start, loc)

    assert.eq(front-matter.len(), 1, message: "Must have exactly one front matter start marker")
    assert.eq(back-matter.len(), 1, message: "Must have exactly one back matter start marker")

    let front-matter = front-matter.first().location()
    let back-matter = back-matter.first().location()

    let front-matter-end = counter(page).at(front-matter).at(0)
    let back-matter-start = counter(page).at(back-matter).at(0)

    if loc.page() <= front-matter.page() {
      ("front", spec.front, 0)
    } else if front-matter.page() < loc.page() and loc.page() <= back-matter.page() {
      ("inner", spec.inner, front-matter-end)
    } else {
      ("back", spec.back, back-matter-start - front-matter-end)
    }
  }

  let mark(label) = [#metadata("anti-matter-marker")#label]

  /// Mark the end of the front matter of your document.
  let anti-front-end = mark(label-front-end)

  /// Mark the start of the back matter of your document.
  let anti-back-start = mark(label-back-start)

  /// The counter for the front and back matter of your document.
  let anti-outer-counter = counter("anti-matter:outer")

  /// The counter for the main content of your document.
  let anti-inner-counter = counter("anti-matter:inner")

  /// Returns the active counter at the given loction.
  ///
  /// - spec (dictionary): the spec of the document, see @@anti-matter
  /// - loc (location): the location to get the active counter for
  /// -> counter
  let anti-active-counter-at(spec, loc) = {
    let (matter, _, _) = where-am-i(spec, loc)

    if matter == "inner" {
      anti-inner-counter
    } else {
      anti-outer-counter
    }
  }

  /// Use the default spec with shared outer numbering and counter.
  ///
  /// The dictionary that is returned is simply the numbering for the `front`, `inner` and `back`
  /// keys.
  ///
  /// - outer (string, function): the numbering used for front and back matter
  /// - inner (string, function): the numbering used for the document's main content
  /// -> dictionary
  let anti-thesis(outer: "I", inner: "1") = (
    front: outer,
    inner: inner,
    back: outer,
  )

  /// Returns the page numbering at the given location with the required adjustments and numbering
  /// given by the spec.
  ///
  /// - spec (dictionary): the spec of the document, see @@anti-matter
  /// - loc (location): the location at which to evaluate the numbering
  /// -> content
  let anti-page-at(spec, loc) = {
    let (_, num, correction) = where-am-i(spec, loc)

    let vals = counter(page).at(loc)
    vals.at(0) = vals.at(0) - correction

    numbering(num, ..vals)
  }

  /// Returns the formatted page number at the given location with the required adjustments and
  /// numbering given by the spec.
  ///
  /// - spec (dictionary): the spec describing the document numbering, see @@anti-matter
  /// -> content
  let anti-page(spec) = locate(loc => anti-page-at(spec, loc))

  /// Render a page header while maintaining anti-matter counter stepping.
  ///
  /// - spec (dictionary): the spec describing the document numbering, see @@anti-matter
  /// - header (content): the header to render
  /// -> content
  let anti-header(spec, header) = {
    locate(loc => anti-active-counter-at(spec, loc).step())
    header
  }

  /// A template function that applies the page numbering and a show rule for outline.entry to fix
  /// it's page numbering. If you need more granular control over outline entries and page headers
  /// see the library documentation. This can be used for a show rule. The parameters are validated.
  ///
  /// - spec (dictionary): the spec describing the document numbering, see @@anti-matter
  /// - body (content): the content to render with anti-matter numbering
  /// -> content
  let anti-matter(
    spec: anti-thesis(),
    body,
  ) = {
    assert-spec-valid(spec)

    set page(
      header: anti-header(spec, none),
      numbering: (..args) => anti-page(spec),
    )
    show outline.entry: it => {
      link(it.element.location(), it.body)
      if it.fill != none {
        [ ]
        box(width: 1fr, it.fill)
        [ ]
      } else {
        h(1fr)
      }
      link(it.element.location(), anti-page-at(spec, it.element.location()))
    }
  
    body
  }

  (
    anti-front-end,
    anti-back-start,
    anti-outer-counter,
    anti-inner-counter,
    anti-active-counter-at,
    anti-page-at,
    anti-page,
    anti-header,
    anti-thesis,
    anti-matter,
  )
}
