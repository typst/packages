#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/datify:0.1.4": custom-date-format, day-name, month-name
#import "@preview/droplet:0.3.1": dropcap
#import "@preview/t4t:0.4.3": get
#import "@preview/titleize:0.1.1": titlecase

#let blue-unir = rgb("#0098cd")
#let blue-unir-soft = rgb("#eaf6fd")
#let space-above-tables = 4.5mm
#let space-above-images = 4.5mm
#let abstract-font-size = 8.8pt

/// Remove indentation for a specific paragraph. This is useful when using
/// "where" paragraph right after an equation that must not be indented.
///
/// - body: (content): Paragraph that needs to be unindented.
#let no-indent(body) = {
  set par(first-line-indent: 0pt)
  body
}

/// Add "Equation" supplement before the equation reference.
///
/// Intended to be used only for equations that are referenced immediately at
/// the start of a sentence, as per IJIMAI requirements. In any other
/// situations, reference equations as usual (directly).
///
/// Named with a capital letter to avoid shadowing `math.eq` that is directly
/// accessible in the math mode. As a consequence, it also reminds that it must
/// be used at the start of a sentence.
///
/// ```typ
/// Usage: #Eq[@pythagorean], #Eq(<pythagorean>), #Eq(ref(<pythagorean>))
/// ```
///
/// - reference: (ref, label): equation's label or reference to it.
#let Eq(reference) = {
  assert(type(reference) in (content, label))
  if type(reference) == content { assert(reference.func() == ref) }
  if type(reference) == label { reference = ref(reference) }
  ref(reference.target, supplement: [Equation])
}

/// Function that styles the first paragraph of the Introduction section.
///
/// - first-word (str, content): First word that will be styled.
/// - body (str, content): The rest of the first paragraph that is needed to
///     properly style the first word.
#let first-paragraph(first-word, body) = {
  dropcap(
    height: 2,
    gap: 1pt,
    hanging-indent: 1em,
    overhang: 0pt,
    fill: blue-unir,
    [#upper(text(fill: blue-unir, weight: "semibold", first-word)) #body],
  )
  counter("_ijimai-first-paragraph-usage").step()
}

/// An alias to `read.with(encoding: none)`. Intended to be used with
/// `ijimai.read` (also `ijimai.photos`, or `ijimai.bibliography`).
#let read-raw = read.with(encoding: none)

/// The template function.
///
/// ```typ
/// #show: ijimai.with(
///   config: toml("paper.toml"),
///   bibliography: "bibliography.yaml",
///   read: path => read-raw(path),
/// )
/// ```
///
/// - config (dictionary): Configuration that defines paper and author metadata.
/// - photos (str, array): Path to directory with authors' photos or an array
///     of raw photos data (bytes of images).
/// - bibliography (str, bytes): Path to the bibliography file or raw content of
///     the file (bytes).
/// - read (function): A special function that allows passing path strings to
///     the other parameters. Should be set to `path => read-raw(path)`.
/// - auto-first-paragraph (bool): Whether to automatically detect and style the
///     first paragraph. Normally this parameter should be ignored.
/// - body (content): Content passed to the template function when it is
///     applied.
#let ijimai(
  config: none,
  photos: "photos/",
  bibliography: none,
  read: none,
  auto-first-paragraph: true,
  body,
) = {
  assert(type(config) == dictionary, message: "\"config\" was not provided")
  if str in (photos, bibliography).map(type) {
    assert(
      type(read) == function,
      message: "To be able to automatically read files,"
        + " set \"read\" parameter to `path => read-raw(path)`.",
    )
  }
  assert(
    type(photos) == str
      or type(photos) == array and photos.all(x => type(x) == bytes),
    message: "\"photos\" can be path to author photos (`str`),"
      + " or raw image data (`array` of `bytes`)",
  )
  assert(
    type(bibliography) in (str, bytes),
    message: "\"bibliography\" must be path to the bibliography file (`str`),"
      + " or raw file content (`bytes`)",
  )
  let bibliography-data = if type(bibliography) == str {
    read(bibliography)
  } else {
    bibliography
  }
  bibliography = std.bibliography

  set text(font: "Libertinus Serif", size: 9pt, lang: "en")
  set columns(gutter: 0.4cm)
  // The requirements state that the supplement can only appear if an equation
  // reference is at the start of a sentence, but it must be dropped otherwise.
  //
  // Since currently sentence detection is not present in Typst
  // (https://forum.typst.app/t/sentence-spacing/6015), it is expected that
  // authors will manually add the correct supplement when referencing at the
  // beginning of a sentence. To ease the burden, the `Eq` function can be used.
  set math.equation(numbering: n => numbering("(1)", n), supplement: none)
  set page(
    paper: "ansi-a",
    margin: 1.5cm,
    columns: 2,
    header: context {
      set align(center)
      set text(10pt, blue-unir, font: "Unit OT", weight: "light", style: "italic")

      if (config.paper.special-issue == true) {
        let gradient = gradient.linear(white, blue-unir, angle: 180deg)
        let stripe = rect.with(width: 165%, height: 17pt - 8%)
        if calc.odd(here().page()) {
          place(dx: -80%, stripe(fill: gradient))
        } else {
          place(dx: -page.margin, stripe(fill: gradient.sharp(5)))
        }
      }

      if calc.odd(here().page()) {
        if (config.paper.special-issue) {
          config.paper.special-issue-title
        } else [Regular issue]
      } else {
        let (journal, volume, number) = config.paper
        [#journal, Vol. #volume, N#super[o]#number]
      }
    },
    footer: context {
      set align(center)
      set text(8pt, blue-unir, font: "Unit OT")
      "- " + counter(page).display() + " -"
    },
  )

  show bibliography: it => {
    show link: set text(blue)
    show link: underline
    it
  }

  let sequence = [].func()
  let space = [ ].func()
  let styled = text(red)[].func()
  let symbol-func = $.$.body.func()
  let context-func = (context{}).func()

  /// Used for table figure caption.
  /// See https://github.com/pammacdotnet/IJIMAI/pull/13 for details.
  let remove-trailing-period(element) = {
    assert(type(element) == content)
    if element.func() == text {
      if element.text.last() != "." { return element }
      text(element.text.slice(0, -1))
    } else if element.func() == symbol-func {
      if element.text != "." { element }
    } else if element.func() in (space, linebreak, parbreak) {
    } else if element.func() in (ref, footnote) {
      element
    } else if element.func() == sequence {
      let (..rest, last) = element.children
      (..rest, remove-trailing-period(last)).join()
    } else if element.func() == styled {
      styled(remove-trailing-period(element.child), element.styles)
    } else if element.func() == emph {
      emph(remove-trailing-period(element.body))
    } else if element.func() == strong {
      strong(remove-trailing-period(element.body))
    } else if element.func() == link {
      link(element.dest, remove-trailing-period(element.body))
    } else if element.func() == box {
      let fields = element.fields()
      let body = fields.remove("body")
      box(..fields, remove-trailing-period(body))
    } else if element.func() == raw {
      let fields = element.fields()
      let text = fields.remove("text")
      raw(..fields, text.replace(regex("\\.$"), ""))
    } else if element.func() == math.equation {
      let fields = element.fields()
      let body = fields.remove("body")
      if body == symbol-func(".") { return }
      if body.func() == sequence and body.children.last() == symbol-func(".") {
        return math.equation(..fields, remove-trailing-period(body))
      }
      element
    } else {
      panic(repr(element.func()) + " was not handled properly")
    }
  }

  /// Used to normalize figure captions. If there is an invisible space of
  /// different kinds at the end of the caption, it will remove all of them,
  /// until there are none left.
  /// See https://github.com/pammacdotnet/IJIMAI/pull/13 for details.
  let remove-trailing-spaces(element) = {
    if element == none { return element }
    assert(type(element) == content)
    let new = if element.func() == text {
      if element.text.last() != " " { element } else {
        text(element.text.slice(0, -1))
      }
    } else if element.func() == symbol-func {
      if element.text != " " { element }
    } else if element.func() in (space, linebreak, parbreak) {
    } else if element.func() in (ref, footnote, math.equation) {
      element
    } else if element.func() == sequence {
      let (..rest, last) = element.children
      (..rest, remove-trailing-spaces(last)).join()
    } else if element.func() == styled {
      styled(remove-trailing-spaces(element.child), element.styles)
    } else if element.func() == emph {
      emph(remove-trailing-spaces(element.body))
    } else if element.func() == strong {
      strong(remove-trailing-spaces(element.body))
    } else if element.func() == link {
      link(element.dest, remove-trailing-spaces(element.body))
    } else if element.func() == box {
      let fields = element.fields()
      let body = fields.remove("body")
      box(..fields, remove-trailing-spaces(body))
    } else if element.func() == raw {
      let fields = element.fields()
      let text = fields.remove("text")
      raw(..fields, text.replace(regex(" $"), ""))
    } else {
      panic(repr(element.func()) + " was not handled properly")
    }
    if new != element { remove-trailing-spaces(new) } else { new }
  }

  show figure.caption.where(kind: table): it => {
    show: smallcaps
    let text = get.text(it)
    // text == none when caption == [].
    // Don't remove period for empty caption.
    // Don't remove period if it doesn't exist.
    if text == none or text.trim().len() == 0 or text.trim().last() != "." {
      it
    } else {
      show: block
      it.supplement
      if it.supplement != none { sym.space.nobreak }
      context it.counter.display(it.numbering)
      it.separator
      remove-trailing-period(remove-trailing-spaces(it.body))
    }
  }

  show figure.caption.where(kind: image): it => {
    let text = get.text(it)
    // text == none when caption == [].
    // Don't add period for empty caption (spaces pre-trimmed).
    if text == none or text.trim().len() == 0 { return it }
    show: block
    it.supplement
    if it.supplement != none { sym.space.nobreak }
    context it.counter.display(it.numbering)
    it.separator
    // Some periods can be in raw, footnote, strong, etc. It must be unstyled.
    remove-trailing-period(remove-trailing-spaces(it.body))
    "."
  }

  let in-ref = state("in-ref", false)
  show ref: it => in-ref.update(true) + it + in-ref.update(false)

  // Make floating figures by default to avoid gaps in document flow.
  set figure(placement: auto)
  show figure.where(kind: image): set figure(supplement: "Fig.")
  show figure.where(kind: image): set block(below: space-above-images)
  show figure.where(kind: table): set block(above: space-above-tables)
  show figure.where(kind: table): set block(below: space-above-tables)
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(
    supplement: context if in-ref.get() [Table] else [TABLE],
    numbering: "I",
  )

  set figure.caption(separator: [. ])
  // https://github.com/typst/typst/issues/5357#issuecomment-3384254721
  show figure.caption.where(kind: table): set block(sticky: true)

  set heading(numbering: "I.A.a)")

  /// Automatically generate the whole body for the CRediT section.
  let generate-author-credit-roles() = {
    if state("_ijimai-generate-author-credit-roles").get() == false { return }
    // ANSI/NISO Z39.104-2022
    // Contributor roles
    let roles = (
      conceptualization: [Conceptualization],
      data-curation: [Data curation],
      formal-analysis: [Formal analysis],
      funding-acquisition: [Funding acquisition],
      investigation: [Investigation],
      methodology: [Methodology],
      project-administration: [Project administration],
      resources: [Resources],
      software: [Software],
      supervision: [Supervision],
      validation: [Validation],
      visualization: [Visualization],
      writing-original-draft: [Writing -- original draft],
      writing-review-editing: [Writing -- review & editing],
    )
    let author-roles = config
      .authors
      .map(author => {
        let message = "Missing \"credit\" key for " + author.name
        assert("credit" in author, message: message)
        let credit = author.credit
        let message = "\"credit\" key must be a list of roles"
        assert(type(credit) == array, message: message)
        let message = role => (
          "Invalid CRediT role: "
            + role
            + " ("
            + author.name
            + ").\nValid roles:"
            + roles.keys().map(x => "\n- " + x).join()
        )
        for role in credit {
          assert(role in roles.keys(), message: message(role))
        }
        ((author.name): credit.sorted().map(role => roles.at(role)))
      })
      .join()
    let format-author-roles = ((author, roles)) => {
      [#eval(author, mode: "markup"): #roles.join[, ]]
    }
    author-roles.pairs().map(format-author-roles).join[; ] + "."
  }

  let used-sections = state("_ijimai-used-sections", ())
  let credit-section-name = "CRediT Authorship Contribution Statement"
  let introduction-section-name = "Introduction"
  let required-sections = (
    (introduction-section-name): (),
    (credit-section-name): (),
    "Data Statement": (),
    "Declaration of Conflicts of Interest": (),
    "Acknowledgment": (
      [Acknowledgments],
      [Acknowledgement],
      [Acknowledgements],
    ),
  )
    .pairs()
    .map(((k, v)) => (k, (text(k),) + v))
    .to-dict()

  show heading: it => {
    let deepest = counter(heading).get().last()

    set text(weight: "regular")
    let is-special = (
      it.level == 1
        and lower(get.text(it.body))
          in required-sections.values().flatten().map(x => lower(x.text))
    )
    if it.level == 1 {
      if is-special { used-sections.update(x => x + (it.body,)) }
      // This is a special section that must be styled like a normal section.
      if lower(it.body.text) == lower(introduction-section-name) {
        is-special = false
      }
      // Special formatting for special section.
      show regex("^(?i)" + credit-section-name + "$"): credit-section-name

      set align(center)
      set text(blue-unir, if is-special { 10pt } else { 11pt })
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      if it.numbering != none and not is-special {
        numbering("I.", deepest)
        h(7pt, weak: true)
      }
      show: smallcaps
      show: titlecase
      it.body
    } else if it.level == 2 {
      //set par(first-line-indent: 0pt)
      set text(10pt, blue-unir, style: "italic")
      show: block.with(spacing: 10pt, sticky: true, above: 1.2em + 0.22em)
      if it.numbering != none {
        numbering("A.", deepest)
        h(7pt, weak: true)
      }
      it.body
    } else {
      set text(10pt)
      if it.level == 3 {
        numbering("a)", deepest)
        [ ]
      }
      [_#(it.body):_]
    }
    if it.level == 1 {
      v(-12pt)
      line(length: 100%, stroke: blue-unir + 0.5pt)
    }
    if is-special and lower(it.body.text) == lower(credit-section-name) {
      set text(9pt) // Cancel heading styling.
      generate-author-credit-roles()
    }
  }

  let institution-names = config
    .authors
    .map(author => author.institution)
    .dedup()
  let numbered-institution-names = institution-names.enumerate(start: 1)
  let authors-string = config
    .authors
    .map(author => {
      let institution-number = numbered-institution-names
        .filter(((_, name)) => name == author.institution)
        .first() // One and only numbered institution
        .first() // Institution number
      [#author.name#h(0.7pt)#super[#institution-number]]
      if author.corresponding [#super[#sym.star]]
    })
    .join(", ")

  counter(page).update(config.paper.starting-page)

  place(
    top + left,
    scope: "parent",
    float: true,
    dy: 0.6cm,
  )[
    #align(left)[
      #par(spacing: 0.7cm, leading: 1.5em)[
        #text(size: 24pt)[#titlecase(config.paper.title)]
      ]]

    #text(fill: blue-unir, size: 13pt)[#authors-string]

    #text(fill: black, size: 10pt)[
      #(
        numbered-institution-names
          .map(((number, name)) => super[#number] + " " + eval(name, mode: "markup"))
          .join([\ ])
      )
    ]

    #text(fill: blue-unir)[#super[#sym.star] Corresponding author:] #(
      config.authors.filter(author => author.corresponding).at(0).email
    )

    #v(0.3cm)
    #let received-date-string = [#config.paper.received-date.day() #month-name(
        config.paper.received-date.month(),
        true,
      ) #config.paper.received-date.year()]
    #let accepted-date-string = [#config.paper.accepted-date.day() #month-name(
        config.paper.accepted-date.month(),
        true,
      ) #config.paper.accepted-date.year()]
    #let published-date-string = [#config.paper.published-date.day() #month-name(
        config.paper.published-date.month(),
        true,
      ) #config.paper.published-date.year()]
    #underline(offset: 4pt, stroke: blue-unir)[#overline(offset: -10pt, stroke: blue-unir)[#text(
      font: "Unit OT",
      size: 8pt,
    )[Received #received-date-string | Accepted #accepted-date-string | Published #published-date-string]]]

    #context [
      #let abstract-y = here().position().y
      #place(
        top + left,
        dx: 14.8cm,
        dy: abstract-y - 5cm,
        image("UNIR_logo.svg", width: 17.5%),
      )]
    #v(1.3cm)


    #let keywords-string = (config.paper.keywords.sorted().join(", ") + ".")

    #grid(
      columns: (3.5fr, 1fr),
      rows: (auto, 60pt),
      gutter: 25pt,
      [#text(size: 15pt, font: "Unit OT", fill: blue-unir)[A]#text(
          size: 13pt,
          font: "Unit OT",
          fill: blue-unir,
        )[BSTRACT]#v(-.3cm)#line(length: 100%, stroke: blue-unir) #par(justify: true, leading: 5.5pt)[#text(
          size: abstract-font-size,
        )[#config.paper.abstract]]],
      [#text(size: 15pt, font: "Unit OT", fill: blue-unir)[K]#text(
          size: 13pt,
          font: "Unit OT",
          fill: blue-unir,
        )[EYWORDS]#v(-.3cm)#line(length: 100%, stroke: blue-unir) #par(justify: false, leading: 4pt)[#text(
          size: abstract-font-size,
        )[#keywords-string]] #align(left + bottom)[
          #underline(offset: 4pt, stroke: blue-unir)[#overline(offset: -10pt, stroke: blue-unir)[#text(
            font: "Unit OT",
            size: 7.5pt,
          )[#text(fill: blue-unir, "DOI: ") #config.paper.doi]]]]],
    )
    #v(-1.7cm)
  ]

  let author-bios = (
    config
      .authors
      .enumerate()
      .map(((i, author)) => {
        let photo-data = if type(photos) == array { photos.at(i) } else {
          read(photos + author.photo)
        }
        let author-photo = image(photo-data, width: 2cm)
        let author-bio = [#par(
            text(fill: blue-unir, font: "Unit OT", size: 8.0pt, author.name),
          ) #(
            text(size: 8pt, eval(author.bio, mode: "markup"))
          )]
        wrap-content(author-photo, author-bio)
      })
      .join()
  )

  set list(indent: 1em)
  set enum(indent: 1em)
  set terms(indent: 1em)
  set par(
    first-line-indent: (amount: 1em, all: true),
    justify: true,
    leading: 5pt,
    spacing: 0.25cm,
  )

  let short-author-list = if "short-author-list" in config.paper {
    config.paper.short-author-list.trim().replace(regex(" {2,}"), " ")
  } else {
    config.authors.map(author => {
      let name = author.name.split()
      assert(
        name.len() == 2,
        message: "Failed to generate short author list.\n"
          + "Please provide a custom value in the TOML file:\n"
          + "[paper]\nshort-author-list = \"<Your short list of authors>\"",
      )
      let (first, last) = name
      [#first.first(). #last]
    }).join([, ], last: [ and ])
  }
  let cite-string = context {
    let doi-link-text = "https://dx.doi.org/" + config.paper.doi
    let doi-link = link(doi-link-text)
    let last-page = counter(page).final().first()
    [#short-author-list. #config.paper.title. #config.paper.journal, vol. #config.paper.volume, no. #config.paper.number, pp. #config.paper.starting-page - #last-page, #config.paper.publication-year, #doi-link]
  }

  let cite-as-section = {
    set align(left)
    set par(leading: 1mm)
    set text(size: 8.1pt)
    show: rect.with(width: 100%, fill: silver, stroke: 0.5pt + blue-unir)
    [Please, cite this article as: #cite-string]
  }

  figure(
    scope: "parent",
    placement: bottom,
    kind: "_ijimai-citing-notice",
    supplement: none,
    cite-as-section,
  )

  // Detect first paragraph after the Introduction section using location
  // proximity relative to the section.
  // Based on hacks from https://github.com/typst/typst/issues/2953.
  // Make an early (in-context) return if an explicit function used in the
  // document. There is a second non-contextual switch in case user is using
  // their own par show rule and template's one breaks the user's one.
  show par: it => {
    if not auto-first-paragraph { return it }
    if it.body.func() == context-func or it.body == h(0.1pt) { return it }
    context {
      if here().page() > 1 { return it }
      let used = counter("_ijimai-first-paragraph-usage").final().first()
      if used > 1 { return it } // Context quirk (can't use `used == 1`).
      let a = query(selector(heading.where(level: 1)).before(here())).filter(
        x => lower(get.text(x)) == "introduction",
      )
      if a.len() != 1 { return it }
      let intro = a.first()
      if intro.location().page() != here().page() { return it }
      if intro.location().position().x != here().position().x { return it }
      let distance = here().position().y - intro.location().position().y
      if distance.cm() > 1 { return it }
      assert(it.body.func() in (text, sequence), message: repr(it))
      let first
      let rest
      if it.body.func() == text {
        (first, ..rest) = it.body.text.split()
        rest = rest.join(" ")
      } else {
        (first, ..rest) = it.body.children
        assert(first.func() == text)
        let (a, ..b) = first.text.split()
        rest.insert(0, b.join(" "))
        first = a
        rest = rest.join()
      }
      assert(type(first) == str)
      assert(
        first.clusters().len() != 1 or body != none,
        message: "First paragraph cannot be a single letter: " + first,
      )
      // Can't use because it triggers on first-word == "paragraph." when
      // `#first-paragraph[The][first paragraph.]`.
      // assert(
      //   first.clusters().first().match(regex("^\\p{Uppercase}$")) != none,
      //   message: "First paragraph must start with a capital letter"
      //     + " (starts with \"" + first + "\").",
      // )
      first-paragraph(first, rest)
    }
  }

  body

  // Make sure the required sections are:
  // - all included
  // - have correct order
  // - have no duplicates
  context {
    assert(
      used-sections.get().len() == required-sections.len(),
      message: if used-sections.get().len() < required-sections.len() {
        let not-used = (:)
        for (section, values) in required-sections {
          let exists = false
          for value in values {
            if lower(value.text) in used-sections.get().map(get.text).map(lower) {
              exists = true
              break
            }
          }
          if not exists { not-used.insert(section, values) }
        }
        let message = "Next required sections are missing:\n"
        message += not-used.pairs().map(((key, value)) => "- " + key).join("\n")
        message += "\nPlease, use document structure from the official IJIMAI Typst template."
        message
      } else if used-sections.get().len() > required-sections.len() {
        let dict = (:)
        for section in used-sections.get() {
          let key
          for (required-section, aliases) in required-sections {
            if lower(get.text(section)) in aliases.map(x => lower(x.text)) {
              key = required-section // Preserve preferred in-source casing.
              break
            }
          }
          assert(key != none)
          let value = dict.at(key, default: ())
          dict.insert(key, value + (section,))
        }
        for (key, instances) in dict {
          if instances.len() == 1 {
            _ = dict.remove(key)
          }
        }
        let message = "Found duplicate sections:\n"
        message += dict
          .pairs()
          .map(((section, instances)) => {
            "- " + section + ": " + instances.map(x => x.text).join(", ")
          })
          .join("\n")
        message += "\nPlease, remove the duplicates."
        message
      } else { "" },
    )

    for (used, required) in array.zip(
      used-sections.get(),
      required-sections.pairs(),
    ) {
      let (section, aliases) = required
      let message = (
        "Section "
          + repr(section)
          + " is included in the wrong order. The correct order:\n"
      )
      message += required-sections
        .pairs()
        .map(((key, value)) => "- " + key)
        .join("\n")
      message += "\nPlease, use document structure from the official IJIMAI Typst template."
      assert(
        lower(get.text(used)) in aliases.map(x => lower(x.text)),
        message: message,
      )
    }
  }

  // Make sure the `first-paragraph` function is used exactly once.
  context {
    let used = counter("_ijimai-first-paragraph-usage").final().first()
    assert(
      used == 1,
      message: "The \"first-paragraph\" function must be used exactly once, "
        + "but was used "
        + str(used)
        + " times.",
    )
  }

  show regex("^\[\d+\]"): set text(fill: blue-unir)

  set par(leading: 4pt, spacing: 5.5pt, first-line-indent: 0pt)
  set text(size: 7.5pt)

  bibliography(bibliography-data, style: "ieee", title: "References")
  v(1cm)
  set par(leading: 4pt, spacing: 9.5pt)
  author-bios
}
