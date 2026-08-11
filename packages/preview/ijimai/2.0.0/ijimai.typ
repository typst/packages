#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/datify:0.1.4": custom-date-format, day-name, month-name
#import "@preview/droplet:0.3.1": dropcap
#import "@preview/numbly:0.1.0": numbly
#import "@preview/t4t:0.4.3": get
#import "@preview/titleize:0.1.1": string-to-titlecase, titlecase
#import "@preview/sela:0.1.0": any, sel

/// IJIMAI (foreground) accent color.
#let blue-unir = rgb("#0098cd")

/// IJIMAI background accent color.
#let blue-unir-soft = rgb("#eaf6fd")

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
    [#smallcaps(text(blue-unir, first-word)) #body],
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

  let space-above-tables = 4.5mm
  let space-above-images = 4.5mm

  let journal-name = (
    "International Journal of Interactive Multimedia and Artificial Intelligence"
  )

  let (preprint, special-issue) = config.paper
  let message = (
    "\"special-issue\" and \"preprint\" keys cannot be both set to \"true\""
  )
  assert(not (special-issue and preprint), message: message)

  let keywords = config.paper.keywords.sorted().map(string-to-titlecase)

  let message = "Page must be a positive integer"
  assert(config.paper.starting-page > 0, message: message)
  counter(page).update(config.paper.starting-page)

  set document(
    title: string-to-titlecase(config.paper.title),
    author: config.authors.map(x => x.name),
    keywords: keywords,
    date: config.paper.published-date,
  )
  set text(9pt, font: "Libertinus Serif")
  set columns(gutter: 4mm)
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
    margin: 15mm,
    columns: 2,
    header: context {
      set align(center)
      set text(
        size: 10pt,
        fill: blue-unir,
        font: "Unit OT",
        weight: "light",
        style: "italic",
      )

      // First page of the article in journal can be odd or even.
      // With `here().page()`, however, it will always be odd (1).
      let page-in-journal = counter(page).get().first()
      if (config.paper.special-issue == true) {
        let gradient = gradient.linear(white, blue-unir, angle: 180deg)
        let stripe = rect.with(width: 165%, height: 17pt - 8%)
        if calc.odd(page-in-journal) {
          place(dx: -80%, stripe(fill: gradient))
        } else {
          place(dx: -page.margin, stripe(fill: gradient.sharp(5)))
        }
      }

      let (preprint, special-issue, special-issue-title) = config.paper

      if calc.odd(page-in-journal) {
        if preprint {
          if page-in-journal > 1 [Article in Press] else {
            let stripe-height = 13mm // Required height.
            let available = (
              page.margin.length * (100% - page.header-ascent.ratio)
            ) // Available height in the header container.
            // Amount of height needed to match required height.
            let y-extend-needed = stripe-height - available
            let height = 100% + y-extend-needed
            let width = page.width
            show: move.with(dy: y-extend-needed)
            show: block.with(width: width, height: height, fill: blue-unir)
            set align(horizon)
            image("article_in_press.svg")
          }
        } else {
          if special-issue [#special-issue-title] else [Regular Issue]
        }
      } else {
        let name = journal-name
        let (volume, number) = config.paper
        let volume-and-number = [, Vol. #volume, #sym.numero #number]
        if preprint [#name] else [#name#volume-and-number]
      }
    },
    footer: context {
      set align(center)
      set text(8pt, blue-unir, font: "Unit OT")
      "- " + counter(page).display() + " -"
    },
  )

  set footnote.entry(indent: 0pt)
  show footnote.entry: it => {
    show h.where(amount: 0.05em): h(0.5em)
    it
  }

  show bibliography: set text(8pt)
  show bibliography: set par(leading: 4pt, spacing: 5pt, first-line-indent: 0pt)
  show bibliography: set block(below: 2em)
  show bibliography: it => {
    show regex("^\[\d+\]$"): set text(blue-unir)
    // 1. Prepend visible https://doi.org suffix, if absent.
    // 2. Remove 2nd instance of doi.org from URL, if present.
    // 3. Disallow use of short DOI (https://shortdoi.org).
    show link: it => {
      if "doi.org" not in it.dest or it.body == [#it.dest] { return it }
      let doi = it.dest.replace(regex("(https?://)?doi.org/"), "")
      let message = (
        "Short DOI is not allowed: " + doi + ". Please use unshortened form."
      )
      assert("/" in doi and doi.len() > 7, message: message)
      if it.dest.matches("doi.org/").len() == 1 {
        link(it.dest, it.dest)
      } else {
        link("https://doi.org/" + doi, it.body)
      }
    }
    it
  }
  show ref: it => {
    show regex("^\[\d+\]$"): set text(blue-unir)
    it
  }

  let sequence = [].func()
  let space = [ ].func()
  let styled = text(red)[].func()
  let symbol-func = $.$.body.func()
  let context-func = (context {}).func()

  /// Used for table figure caption.
  /// See https://github.com/pammacdotnet/IJIMAI/pull/13 for details.
  let remove-trailing-period(in-table: none, element) = {
    assert(type(in-table) == bool, message: "provide true or false to in-table")
    remove-trailing-period = remove-trailing-period.with(in-table: in-table)
    assert(type(element) == content)
    if element.func() == text {
      if element.text.last() != "." { return element }
      text(element.text.slice(0, -1))
    } else if element.func() == symbol-func {
      if element.text != "." { element }
    } else if element.func() in (space, linebreak, parbreak) {
      none
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
      let message = "Table title should not contain math mode content"
      assert(not in-table, message: message)
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
  let remove-trailing-spaces(in-table: none, element) = {
    assert(type(in-table) == bool, message: "provide true or false to in-table")
    remove-trailing-spaces = remove-trailing-spaces.with(in-table: in-table)
    if element == none { return element }
    assert(type(element) == content)
    let new = if element.func() == text {
      if element.text.last() != " " { element } else {
        text(element.text.slice(0, -1))
      }
    } else if element.func() == symbol-func {
      if element.text != " " { element }
    } else if element.func() in (space, linebreak, parbreak) {
      none
    } else if element.func() in (ref, footnote, math.equation) {
      let message = "Table title should not contain math mode content"
      let is-math = element.func() == math.equation
      assert(not (is-math and in-table), message: message)
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
      let args = (in-table: true)
      remove-trailing-period(..args, remove-trailing-spaces(..args, it.body))
    }
  }
  show figure.caption.where(kind: table): smallcaps
  // `text` show rules can match whole caption line (for simple content), or
  // separately for table supplement + numbering + separator and caption body
  // (or its parts).
  // This show rule avoids destructive changes for applying titlecase only to
  // caption body by utilizing `text` show rule. Does not affect numbering.
  show figure.caption.where(kind: table): it => {
    let sep = get.text(it.separator).replace(".", "\\.").replace(" ", "\\s")
    show regex("^.+$"): it => context {
      let match = it.text.match(regex("(?i)^(table\\s\\w+" + sep + ")(.+)"))
      let (rest, title) = if match != none {
        match.captures
      } else if not lower(it.text).starts-with(regex("table\\s")) {
        (none, it.text)
      } else {
        return it
      }
      rest
      string-to-titlecase(title)
    }
    it
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
    let args = (in-table: false)
    // Some periods can be in raw, footnote, strong, etc. It must be unstyled.
    remove-trailing-period(..args, remove-trailing-spaces(..args, it.body))
    "."
  }

  // Only needed for tables, so heading destructive show rule below is fine.
  let in-ref = state("_ijimai-in-ref", false)
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

  show title: set text(24pt, weight: "regular")
  show title: set par(leading: 11pt, spacing: 7mm, linebreaks: "optimized")
  show title: set block(below: 6mm)

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
  for author in config.authors {
    let message = "Missing \"credit\" key for " + author.name
    assert("credit" in author, message: message)
    let credit = author.credit
    let message = (
      "\"credit\" key must be a non-empty list of roles (" + author.name + ")"
    )
    assert(type(credit) == array and credit.len() > 0, message: message)
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
  }

  /// Automatically generate the whole body for the CRediT section.
  let generate-author-credit-roles() = {
    let display-role(role) = roles.at(role)
    let author-roles = config
      .authors
      .map(author => (author.name, author.credit.sorted().map(display-role)))
      .to-dict()
    let format-author-roles = ((author, roles)) => {
      [#eval(author, mode: "markup"): #roles.join[, ]]
    }
    author-roles.pairs().map(format-author-roles).join[; ] + "."
  }

  let used-sections = state("_ijimai-used-sections", ())
  let credit-section-name = "CRediT Authorship Contribution Statement"
  let first-special-heading = credit-section-name
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

  set heading(numbering: (..n) => {
    let supported-level = n.pos().len() <= 4
    assert(supported-level, message: "Headings of level 5+ are not supported")
    numbly("{1:I}.", "{2:A}.", "{3:1}.", "{4:a})")(..n)
  })

  // Apply titlecase, but ignore long letter-based numberings (Roman numerals).
  // https://forum.typst.app/t/7866/3
  let titlecase-only-name(it) = {
    let limit = 4 // "III." already has length of 4.
    show regex(".{" + str(limit) + ",}"): it => {
      if it.text.match(regex("^[IVXLCDM]+\\.$")) != none { return it }
      string-to-titlecase(it.text)
    }
    it
  }

  // Headings starting from `first-special-heading` must have no numbering.
  // How to conditionally disable heading numbering for some headings?
  // https://forum.typst.app/t/7670/4
  show: doc => context {
    let is-special = it => (
      lower(it.body.at("text", default: "")) == lower(first-special-heading)
    )
    let special-heading = query(heading.where(level: 1))
      .filter(is-special)
      .first(default: none)
    if special-heading == none { return doc }
    let rest-of-the-headings = query(
      selector(heading).after(special-heading.location()),
    )
    show selector.or(..rest-of-the-headings.map(it => heading.where(
      level: it.level,
      body: it.body,
    ))): set heading(numbering: none)
    doc
  }

  // Remove numbering suffix from heading references (callback numbering).
  // More flexible separators in numbering patterns
  // https://github.com/typst/typst/issues/905
  // Option to hide last dot in refs to heading that had custom numbering.
  // https://github.com/typst/typst/issues/6032
  show ref.where(form: "normal", supplement: auto): it => {
    if (
      it.element == none
        or it.element.func() != heading
        or it.element.numbering == none
        or it.element.supplement != [Section]
    ) { return it }
    let elem = it.element
    elem.supplement
    [~]
    // Combine numbering from all levels, and remove the suffix.
    let numbers = counter(heading).at(elem.location())
    let display(level) = numbering(elem.numbering, ..numbers.slice(0, level))
    range(1, numbers.len() + 1).map(display).join().slice(0, -1)
  }

  show heading: set text(10pt, blue-unir, weight: "regular")
  show heading: set block(above: 1.5em, below: 1em, sticky: true)
  show heading: titlecase-only-name
  show heading: it => {
    show h.where(amount: 0.3em): h(0.5em)
    it
  }

  // Opposite of `counter.step()`. Use as `counter(...).update(unstep)`.
  let unstep(..n) = {
    let (..rest, last) = n.pos()
    (..rest, calc.max(0, last - 1))
  }

  // How to apply titlecase to headings in Document Outline?
  // https://forum.typst.app/t/7866/3
  // Apply heading name transformation show rules to PDF's Document Outline
  // https://github.com/typst/typst/issues/7803
  set heading(bookmarked: false)
  show heading: it => {
    if it.hanging-indent == 1pt * float.inf { return it }
    let (body, ..settings) = it.fields()
    let _ = settings.remove("label", default: none)
    it
    show heading: none
    counter(heading).update(unstep)
    let name = get.text(body)
    if lower(name) == lower(credit-section-name) { name = credit-section-name }
    heading(
      ..settings,
      outlined: false,
      bookmarked: true,
      hanging-indent: 1pt * float.inf,
      string-to-titlecase(name),
    )
  }

  // 1. Keep track of used sections (required sections must be present).
  // 2. Draw the "underline".
  // 3. For `credit-section-name` section, automatically generate its content.
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): smallcaps
  show heading.where(level: 1): it => {
    let name = lower(get.text(it.body))
    let required = required-sections.values().flatten().map(x => lower(x.text))
    if name in required { used-sections.update(x => x + (it.body,)) }
    {
      set block(below: 0pt)
      it
    }
    {
      set block(above: 1mm)
      line(length: 100%, stroke: blue-unir + 0.5pt)
    }
    if lower(it.body.text) == lower(credit-section-name) {
      // Cancel heading styling.
      set align(left)
      set text(9pt, black)
      generate-author-credit-roles()
    }
  }
  // Special formatting for special section with special casing.
  show heading.where(level: 1): it => {
    show regex("^(?i)" + credit-section-name + "$"): credit-section-name
    it
  }

  // 1 em is below the "underline," without it the spacing is reduced by 1 mm.
  show sel(heading.where(level: any(2, 3, 4))): set block(below: 1em - 1mm)
  show sel(heading.where(level: any(2, 3, 4))): set text(style: "italic")

  let institution-names = config
    .authors
    .map(author => author.institution)
    .dedup()
  let numbered-institution-names = institution-names.enumerate(start: 1)
  let authors-line = config
    .authors
    .map(author => {
      let institution-number = numbered-institution-names
        .filter(((_, name)) => name == author.institution)
        .first() // One and only numbered institution
        .first() // Institution number
      author.name
      super[#institution-number]
      [ ]
      let alt-text = "ORCID iD logo"
      // Source: https://commons.wikimedia.org/wiki/File:ORCID_iD.svg
      let orcid-id-logo = box(image("ORCID_iD.svg", alt: alt-text, height: 8pt))
      link("https://orcid.org/" + author.orcid, orcid-id-logo)
      if author.corresponding [#super[#sym.star]]
    })
    .join[, ]

  {
    show: place.with(
      top + left,
      scope: "parent",
      float: true,
      clearance: 16mm,
    )

    v(5mm)

    title()

    block(below: 6mm, text(12pt, blue-unir, authors-line))

    // Wraps the rest of content around logo, that is placed at the bottom
    // right. Works automatically by splitting content at `parbreak`. Space
    // between logo and text (to the left and top) is configured through `gap`.
    let wrap-logo(gap: 3mm, logo, wrap-it) = {
      let sequence = [].func()
      let parts = wrap-it.children.split(parbreak()).map(sequence)
      let content(before, after) = {
        before
        grid(
          columns: (1fr, auto),
          align: bottom,
          after,
          grid.cell(inset: (top: gap, left: gap), logo),
        )
      }
      let just-grid(i) = content(none, parts.slice(i).join(parbreak()))
      let body(i) = content(
        parts.slice(0, i).join(parbreak()),
        parts.slice(i).join(parbreak()),
      )
      layout(((width, ..)) => {
        let logo-height = measure(logo).height
        let min-height
        let best-index = 0 // Index with minimal height.
        let get-height(body) = measure(body, width: width).height
        let n = parts.len()
        if n == 1 { return body(0) }
        for i in range(n) {
          let height = get-height(body(i))
          if min-height == none {
            min-height = height
            continue
          }
          // It's better to get true (hence not strict comparison), as it will
          // shorten left side (closer to logo height). But only if total height
          // is smaller than before and left side is not shorter than logo. This
          // ensures the bottom of logo and bottom of left side are always
          // aligned together, and there is no empty space between top part and
          // left side.
          if (
            min-height + 0.001pt >= height
              and get-height(just-grid(i)) >= logo-height
          ) {
            min-height = height
            best-index = i
          }
        }
        body(best-index)
      })
    }

    {
      show: block
      set par(spacing: 0.65em)
      show: wrap-logo.with(pdf.artifact(image("UNIR_logo.svg")))

      for (number, name) in numbered-institution-names {
        let str-name = get.text(eval(name, mode: "markup"))
        if str-name == none { continue } // Maybe use state to skip it all?
        let message = (
          "Country must be enclosed in parentheses (without leading comma): "
            + str-name
        )
        assert(str-name.clusters().last() == ")", message: message)
      }
      numbered-institution-names
        .map(((number, name)) => {
          set text(10pt)
          super[#number]
          " "
          eval(name, mode: "markup")
        })
        .join(parbreak())

      {
        show: block.with(below: 6mm - 4pt, above: 5mm)
        set text(8pt)
        text(blue-unir)[#super(sym.star) Corresponding author:]
        " "
        config.authors.filter(author => author.corresponding).first().email
      }

      let month(date, capitalize: true) = month-name(date.month(), capitalize)
      let format-date(date) = [#date.day() #month(date) #date.year()]
      let received = format-date(config.paper.received-date)
      let accepted = format-date(config.paper.accepted-date)
      let published = format-date(config.paper.published-date)
      show: block.with(stroke: (y: 0.5pt + blue-unir), inset: (y: 4pt))
      set text(8pt, font: "Unit OT", weight: "light")
      show "|": set text(blue-unir)
      [Received #received | Accepted #accepted | Published #published]
    }

    v(14mm)

    show grid.cell.where(y: 0): set text(14pt, blue-unir, font: "Unit OT")
    show grid.cell.where(y: 0): name => smallcaps(name) + line()
    show grid.cell.where(y: 1): set par(leading: 5pt)
    set line(length: 100%, stroke: blue-unir)
    show line: set block(above: 1mm)

    let doi-line = {
      set text(7pt, font: "Unit OT", weight: "light")
      show: block.with(stroke: (y: 0.5pt + blue-unir), inset: (y: 4pt))
      text(blue-unir)[DOI:]
      h(3.5pt)
      config.paper.doi
    }

    context grid(
      columns: (auto, measure(doi-line).width),
      column-gutter: 9mm,
      row-gutter: 4mm,
      grid.header[Abstract][Keywords],

      par(justify: true, eval(config.paper.abstract, mode: "markup")),
      keywords.join[, ] + [.] + align(bottom, doi-line),
    )
  }

  set list(indent: 1em)
  set enum(indent: 1em)
  set terms(indent: 1em)
  set par(
    first-line-indent: (amount: 1em, all: true),
    justify: true,
    leading: 5pt,
    spacing: 2.5mm,
  )

  let short-author-list = if "short-author-list" in config.paper {
    config.paper.short-author-list.trim().replace(regex(" {2,}"), " ")
  } else {
    let format-author = author => {
      let name = author.name.split()
      assert(
        name.len() == 2,
        message: "Failed to generate short author list.\n"
          + "Please provide a custom value in the TOML file:\n"
          + "[paper]\nshort-author-list = \"<Your short list of authors>\"",
      )
      let (first, last) = name
      [#first.first(). #last]
    }
    config.authors.map(format-author).join[, ]
  }
  let cite-string = context {
    let doi-link-text = "https://doi.org/" + config.paper.doi
    let doi-link = link(doi-link-text)
    let last-page = counter(page).final().first()
    let paper = config.paper
    // This style is based on IEEE.
    (
      [#short-author-list. #string-to-titlecase(paper.title)],
      journal-name,
      ..if not config.paper.preprint {
        (
          [vol. #paper.volume],
          [no. #paper.number],
          [pp. #paper.starting-page;--#last-page],
        )
      },
      [#paper.published-date.year()],
      doi-link,
    ).join[, ]
  }
  let cite-as-section = {
    set align(left)
    set par(leading: 1mm)
    set text(8pt)
    show: rect.with(width: 100%, fill: silver, stroke: 0.5pt + blue-unir)
    [Please, cite this article as: #cite-string]
  }
  place(bottom, float: true, scope: "parent", cite-as-section)

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
      let visible-level1-headings = heading.where(level: 1, outlined: true)
      let a = query(visible-level1-headings.before(here())).filter(
        x => lower(get.text(x)) == lower(introduction-section-name),
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
          for val in values {
            if lower(val.text) in used-sections.get().map(get.text).map(lower) {
              exists = true
              break
            }
          }
          if not exists { not-used.insert(section, values) }
        }
        let message = "Next required sections are missing:\n"
        message += not-used.pairs().map(((key, value)) => "- " + key).join("\n")
        message += (
          "\nPlease, use document structure "
            + "from the official IJIMAI Typst template."
        )
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
      message += (
        "\nPlease, use document structure "
          + "from the official IJIMAI Typst template."
      )
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

  bibliography(bibliography-data, style: "ieee", title: "References")

  set text(8pt)
  set block(below: 1.7em)
  set par(leading: 4pt, spacing: 10pt, first-line-indent: 0pt)

  let author-bio = ((i, author)) => {
    let photo-data() = read(photos + author.photo)
    let photo = if type(photos) == array { photos.at(i) } else { photo-data() }
    let author-photo = image(alt: "Photo of " + author.name, width: 2cm, photo)
    show: wrap-content.with(author-photo)
    text(blue-unir, font: "Unit OT", weight: "light", author.name)
    parbreak()
    eval(author.bio, mode: "markup")
  }
  config.authors.enumerate().map(author-bio).join()
}
