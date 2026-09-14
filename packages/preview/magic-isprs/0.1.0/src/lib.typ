// Default line spacing and paragraph spacing.
#let line-space = 4.4mm
#let add-line-space() = v(line-space, weak: true)


#let isprs-heading(body) = {
  // Remove the linebreak after h3 headings
  show: doc => {
    let i = 0
    let elements = doc.children
    while i < elements.len() {
      if elements.at(i).func() == heading {
        elements.at(i)
        let j = i + 1
        // For whatever reason the depth of the heading is not accessible there but accessible in the while loop
        let depth = none
        while (
          j < elements.len() and elements.at(j).func() in (linebreak, parbreak, [ ].func())
        ) {
          depth = elements.at(i).depth
          // Only work with heading of depth 3
          if (depth != 3) { break }
          j += 1
        }
        if j >= elements.len() { break }
        if (depth == 3) {
          [ ]
        }
        i = j
      }
      if (elements.at(i).func() != heading) {
        elements.at(i)
        i += 1
      }
    }
  }

  body
}


/// Formats the content of a heading according to the ISPRS style. It also takes care of the numbering, which is a bit tricky because of the appendix.
///
/// - it (heading): the heading in a show rule
/// - force-numbering (any): what to force the numbering to be, or false to keep it as is. This is useful for the appendix.
/// ->
#let format-heading(it, force-numbering: false) = {
  // Find out the final number of the heading counter.
  let levels = counter(heading).get()

  let numbering-func = if force-numbering != false { force-numbering } else { it.numbering }
  let number = if (numbering-func == none) { none } else { numbering(numbering-func, ..levels) }

  let horizontal-space = if (it.level == 1) {
    3mm
  } else if (it.level == 2) {
    2mm
  } else if (it.level == 3) {
    4mm
  } else {
    2mm
  }
  let postfix = if (it.level == 3) {
    [:]
  } else {
    []
  }

  let content = if number != none {
    [#number#h(horizontal-space)#it.body#postfix]
  } else {
    [#it.body#postfix]
  }

  if (it.level == 1) {
    set align(center)
    block(content, spacing: line-space, sticky: true)
  } else if (it.level == 2) {
    set align(start)
    block(content, spacing: line-space, sticky: true)
  } else {
    content
  }
}


// This function gets your whole document as its `body` and formats
// it as an article in the style of the ISPRS.
#let isprs(
  // The paper's title.
  title: [Paper Title],
  // An array of authors. For each author you can specify a 'name', an
  // 'email', and 'institutions' field (which can be a string or an
  // array of strings) referencing the institution(s) they are
  // affiliated with.
  authors: (),
  // Institutions referenced by the authors, each with a name and a
  // location.
  institutions: (:),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // A list of keywords to display after the abstract.
  keywords: (),
  // The file containing the acknowledgements, if any. Can be omitted.
  acknowledgements: none,
  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,
  // The file containing the appendix, if any. Can be omitted.
  appendix: none,
  // Whether to render it as anonymous, hiding authors and acknowledgements.
  anonymous: false,
  // The paper's content.
  body,
) = {
  // Set document metadata.
  let authors-string = if anonymous {
    "Anonymous"
  } else {
    if (authors.len() > 0) {
      authors.map(author => author.name).join(", ")
    } else {
      "No authors"
    }
  }
  set document(title: title, author: authors-string)

  // Set the body font.
  set text(font: ("Times New Roman", "TeX Gyre Termes"), size: 9pt, lang: "en")

  // Enums numbering
  set enum(numbering: "1.")

  // Show URLs in blue.
  show link: set text(fill: blue)

  // Tables & figures
  show figure.caption: set align(center)
  show figure.caption.where(kind: image): it => {
    v(3mm, weak: true)
    it
  }
  set figure.caption(separator: ". ")


  // Configure the page and multi-column properties.
  set columns(gutter: 6mm)
  set page(
    columns: 2,
    paper: "a4",
    margin: (
      x: 20mm,
      y: 25mm,
    ),
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: it => {
    if (it.block) [
      #add-line-space()
      #it
      #add-line-space()
    ] else {
      it
    }
  }

  // Configure appearance of equation references
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location()),
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  let lists-shorter = true
  let list-indent = 13.8pt
  let list-body-indent = 11.5pt
  if lists-shorter {
    list-indent = 6pt
    list-body-indent = 4pt
  }
  set enum(indent: list-indent, body-indent: list-body-indent)
  set list(indent: list-indent, body-indent: list-body-indent)
  show enum: it => {
    it
  }
  show list: it => {
    it
  }

  // Configure headings.
  show heading: set text(weight: "bold", size: 9pt)
  show heading.where(level: 1): set heading(numbering: "1.")
  show heading.where(level: 2): set heading(numbering: "1.1")
  show heading.where(level: 3): set heading(numbering: "1.1.1")
  show heading: it => {
    format-heading(it)
  }

  // Style bibliography.
  set std.bibliography(title: none, style: "custom-isprs.csl")
  // Fix for this issue: https://github.com/typst/typst/issues/5898
  show std.bibliography: set block(width: 100%)

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  place(
    top + center,
    float: true,
    scope: "parent",
    {
      show std.title: set align(center)
      show std.title: set text(size: 12pt, weight: "bold")
      show std.title: set block(below: 8mm)
      std.title()

      // Check that all institutions have the necessary fields.
      let necessary-institution-fields = ("name", "location", "email-suffix")
      for (institution-name, institution-info) in institutions.pairs() {
        let missing-it = "The institution '" + institution-name + "' is missing the following field: "
        for field in necessary-institution-fields {
          if (not field in institution-info) {
            panic(missing-it + field)
          }
        }
      }

      // Check that all authors have the necessary fields and that their institutions are valid.
      let necessary-author-fields = ("name", "email", "institutions")
      let authors-formatted = ()
      for author in authors {
        let missing-it = "An author is missing the following field: "
        for field in necessary-author-fields {
          if (not field in author) {
            panic(missing-it + field)
          }
        }
        if type(author.institutions) == str {
          author.institutions = (author.institutions,)
        }
        let insts = author.institutions
        if type(insts) != array {
          panic("The institutions field of each author must be a string or an array of strings.")
        }
        for inst in insts {
          if not inst in institutions {
            panic("The institutions '" + inst + "' referenced by an author is not defined in the institutions array.")
          }
        }

        authors-formatted.push(author)
      }

      let names-content = ()
      let institutions-content = ()

      if anonymous {
        names-content += ("*********** (Anonymized)",)
        institutions-content += ("*********** (Anonymized)",)
      } else {
        // Assign a number to each institution
        let institutions-numbers = (:)
        for institution-name in institutions.keys() {
          institutions-numbers.insert(institution-name, institutions-numbers.len() + 1)
        }

        // Connect institutions to authors
        let authors-superscripts = ()
        let institutions-emails = (:)
        for author in authors-formatted {
          let insts = author.institutions
          let found-email-institution = false
          let author-superscripts = ()
          for inst in insts {
            // Check that the author email ends with the correct suffix for the institution
            let inst-email-suffix = institutions.at(inst).at("email-suffix")
            if (not found-email-institution and author.email.ends-with(inst-email-suffix)) {
              found-email-institution = true
              if inst in institutions-emails {
                institutions-emails.at(inst) += (author.email,)
              } else {
                institutions-emails.insert(inst, (author.email,))
              }
            }

            author-superscripts.push(str(institutions-numbers.at(inst)))
          }
          authors-superscripts.push(author-superscripts)

          if (not found-email-institution) {
            panic(
              "Could not find an institution for the author '"
                + author.name
                + "' matching their email suffix among their listed institutions.",
            )
          }
        }

        // Display the authors list.
        for i in range(authors.len()) {
          let name-content = []
          name-content += authors.at(i).name
          name-content += super(authors-superscripts.at(i).join(","))
          names-content.push(name-content)
        }


        // Display the authors' affiliations below.
        for inst-key in institutions.keys() {
          let inst-contents = ()
          let inst-info = institutions.at(inst-key)
          inst-contents.push(inst-info.at("name"))
          inst-contents.push(inst-info.at("location"))
          let inst-email-suffix = inst-info.email-suffix
          let inst-emails = ()
          for email in institutions-emails.at(inst-key) {
            if not email.ends-with(inst-email-suffix) {
              panic("Email assigned to an insitution does not end with the institution's email suffix.")
            }
            inst-emails.push(email.slice(0, email.len() - inst-email-suffix.len()))
          }
          let inst-emails-joined = inst-emails.join(", ")
          if inst-emails.len() >= 2 {
            inst-emails-joined = "(" + inst-emails-joined + ")"
          }
          inst-contents.push([#inst-emails-joined#inst-email-suffix])
          let inst-content = [#super(str(institutions-numbers.at(inst-key))) #inst-contents.join([ -- ])]
          institutions-content.push(inst-content)
        }
      }
      names-content.join(", ")
      if institutions-content.len() > 0 {
        add-line-space()
        institutions-content.join(linebreak())
      }
    },
  )

  set par(justify: true, spacing: line-space, leading: 0.5em)

  place(
    top + left,
    float: true,
    scope: "parent",
    clearance: 3em,
    {
      // Keywords
      linebreak()
      linebreak()
      [*Keywords:* #keywords.join[, ].]

      if abstract != none {
        linebreak()
        linebreak()
        linebreak()
        [*Abstract*]
        linebreak()
        linebreak()
        abstract
      }
    },
  )

  show: isprs-heading

  // Display the paper's contents.
  body

  // Display the acknowledgements, if any and if not anonymous.
  if (acknowledgements != none) {
    heading("Acknowledgements", level: 1, numbering: none)
    if (anonymous) {
      [Anonymized.]
    } else {
      acknowledgements
    }
  }

  // Display bibliography.
  if (bibliography != none) {
    heading("References", level: 1, numbering: none)

    set par(justify: true)
    bibliography
  }

  // Display appendix, if any.
  if (appendix != none) {
    heading("Appendix", level: 1, numbering: none)
    show heading: it => {
      format-heading(it, force-numbering: none)
    }
    appendix
  }
}
