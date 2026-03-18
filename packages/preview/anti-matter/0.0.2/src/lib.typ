// avoid exporting util
#let (
  anti-front-end,
  anti-inner-end,
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

  let meta-label = <anti-matter:label>
  let key-front-end = "anti-matter:front-end"
  let key-inner-end = "anti-matter:inner-end"

  // get matter and correction at given loc
  let where-am-i(spec, loc) = {
    let markers = query(meta-label, loc)

    assert.eq(
      markers.len(),
      2,
      message: "Must have exactly start marker (do not use <anti-matter:meta>)"
    )
    assert.eq(markers.at(0).value, key-front-end, message: "First marker must be front end marker")
    assert.eq(markers.at(1).value, key-inner-end, message: "Second marker must be inner end marker")

    let front-matter = markers.first().location()
    let inner-matter = markers.last().location()

    let front-matter-end = counter(page).at(front-matter).at(0)
    let inner-matter-end = counter(page).at(inner-matter).at(0)

    if loc.page() <= front-matter.page() {
      ("front", spec.front, 0)
    } else if front-matter.page() < loc.page() and loc.page() <= inner-matter.page() {
      ("inner", spec.inner, front-matter-end)
    } else {
      ("back", spec.back, inner-matter-end - front-matter-end)
    }
  }

  /// Mark the end of the front matter of your document, place this on the last page of your front
  /// matter. Make sure to put this before trainling `pagebreaks`.
  ///
  /// -> content
  let anti-front-end() = [#metadata(key-front-end) #meta-label]

  /// Mark the end of the inner matter of your document, place this on the last page of your inner
  /// matter. Make sure to put this before trainling `pagebreaks`.
  ///
  /// -> content
  let anti-inner-end() = [#metadata(key-inner-end) #meta-label]

  /// Returns the counter for the front and back matter of your document.
  ///
  /// -> counter
  let anti-outer-counter() = counter("anti-matter:outer")

  /// Returns the counter for the main content of your document.
  ///
  /// -> counter
  let anti-inner-counter() = counter("anti-matter:inner")

  /// Returns the active counter at the given loction. This can be used to set the page counter at
  /// a certain position.
  ///
  /// - spec (dictionary): the spec of the document, see @@anti-matter
  /// - loc (location): the location to get the active counter for
  /// -> counter
  let anti-active-counter-at(spec, loc) = {
    let (matter, _, _) = where-am-i(spec, loc)

    if matter == "inner" {
      anti-inner-counter()
    } else {
      anti-outer-counter()
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
  /// - debug (bool): display the current matter and assocaited infor in the page header
  /// - body (content): the content to render with anti-matter numbering
  /// -> content
  let anti-matter(
    spec: anti-thesis(),
    debug: false,
    body,
  ) = {
    assert-spec-valid(spec)

    set page(
      header: if debug {
        locate(loc => anti-header(spec)[
          #let (matter, numbering, correction) = where-am-i(spec, loc)
          #(matter: matter, numbering: numbering, correction: correction)
        ])
      } else {
        anti-header(spec, none)
      },
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
    anti-inner-end,
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
