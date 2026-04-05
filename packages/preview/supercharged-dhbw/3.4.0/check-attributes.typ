#let check-attributes(
  title,
  authors,
  language,
  at-university,
  confidentiality-marker,
  type-of-thesis,
  type-of-degree,
  show-confidentiality-statement,
  show-declaration-of-authorship,
  show-table-of-contents,
  show-acronyms,
  show-list-of-figures,
  show-list-of-tables,
  show-code-snippets,
  show-abstract,
  header,
  numbering-alignment,
  toc-depth,
  acronym-spacing,
  glossary-spacing,
  abstract,
  appendix,
  acronyms,
  university,
  university-location,
  supervisor,
  date,
  city,
  bibliography,
  bib-style,
  logo-left,
  logo-right,
  logo-size-ratio,
  university-short,
  heading-numbering,
  math-numbering,
  ignored-link-label-keys-for-highlighting,
  page-numbering,
) = {
  if (title == none or title == "") {
    panic("Title is missing. Specify a title in the 'title' attribute of the template.")
  }

  if (header != none and type(header) != dictionary) {
    panic("Header is invalid. Specify a dictionary in the 'header' attribute of the template. The following attributes can be set: 'display', 'show-chapter', 'show-left-logo', 'show-right-logo', 'show-divider', 'content'.")
  }

  let boolean-attributes = (
    at-university: at-university,
    show-confidentiality-statement: show-confidentiality-statement,
    show-table-of-contents: show-table-of-contents,
    show-acronyms: show-acronyms,
    show-declaration-of-authorship: show-declaration-of-authorship,
    show-list-of-figures: show-list-of-figures,
    show-list-of-tables: show-list-of-tables,
    show-code-snippets: show-code-snippets,
    show-abstract: show-abstract,
  )

  for (key, attribute) in boolean-attributes {
    if (type(attribute) != bool) {
      panic("Attribute '" + key + "' is invalid. Specify 'true' or 'false' in the '" + key + "' attribute of the template.")
    }
  }

  let string-attributes = (
    university: university,
    university-location: university-location,
    university-short: university-short,
  )

  for (key, attribute) in string-attributes {
    if (type(attribute) != str or attribute.len() == 0) {
      panic("Attribute '" + key + "' is missing. Specify a " + key + " in the '" + key + "' attribute of the template.")
    }
  }

  let optional-string-attributes = (
    type-of-thesis: type-of-thesis,
    type-of-degree: type-of-degree,
    bib-style: bib-style,
    heading-numbering: heading-numbering,
    math-numbering: math-numbering,
  )

  if (page-numbering != none and type(page-numbering) != dictionary) {
    panic("Page numbering is invalid. Specify a dictionary in the 'page-numbering' attribute of the template.")
  }

  if ("preface" in page-numbering) {
    optional-string-attributes.insert("preface (page-numbering)", page-numbering.preface)
  }

  if ("main" in page-numbering) {
    optional-string-attributes.insert("main (page-numbering)", page-numbering.main)
  }

  if ("appendix" in page-numbering) {
    optional-string-attributes.insert("appendix (page-numbering)", page-numbering.appendix)
  }

  for (key, attribute) in optional-string-attributes {
    if (attribute != none and (type(attribute) != str or attribute.len() == 0)) {
      panic("Attribute '" + key + "' is invalid. Specify a string in the '" + key + "' attribute of the template.")
    }
  }

  if (type(confidentiality-marker) != none) {
    if (
      type(confidentiality-marker) != dictionary or "display" not in confidentiality-marker or type(confidentiality-marker.display) != bool
    ) {
      panic("Confidentiality marker is invalid. Specify a dictionary in the 'confidentiality-marker' attribute of the template containing a 'display' attribute with a boolean value.")
    }
  }

  let length-attributes = (
    acronym-spacing: acronym-spacing,
    glossary-spacing: glossary-spacing,
  )

  if ("offset-x" in confidentiality-marker) {
    length-attributes.insert("offset-x (confidentiality-marker)", confidentiality-marker.offset-x)
  }
  if ("offset-y" in confidentiality-marker) {
    length-attributes.insert("offset-y (confidentiality-marker)", confidentiality-marker.offset-y)
  }
  if ("size" in confidentiality-marker) {
    length-attributes.insert("size (confidentiality-marker)", confidentiality-marker.size)
  }
  if ("title-spacing" in confidentiality-marker) {
    length-attributes.insert("title-spacing (confidentiality-marker)", confidentiality-marker.title-spacing)
  }

  for (key, attribute) in length-attributes {
    if (type(attribute) != length) {
      panic("Attribute '" + key + "' is invalid. Specify a length in the '" + key + "' attribute of the template.")
    }
  }

  if (authors == none or authors == ()) {
    panic("Author is missing. Specify authors in the 'authors' attribute of the template.")
  }

  let max-authors = if at-university {
    8
  } else {
    6
  }

  if (
    (type-of-thesis != none and type-of-thesis != "") or (type-of-degree != none and type-of-degree != "") or (
      confidentiality-marker.display == true
    )
  ) {
    max-authors -= 2
  }

  if (authors.len() > max-authors) {
    panic("Too many authors. Specify a maximum of " + str(max-authors) + " authors in the 'authors' attribute of the template. To increase the maximum number of authors (max. 8), change one of the following attributes: 'at-university', 'type-of-thesis', 'type-of-degree'. (See the package documentation for more information.)")
  }

  for author in authors {
    if ("name" not in author or author.name == none or author.name == "") {
      panic("Author name is missing. Specify a name for each author in the 'authors' attribute of the template.")
    }

    if ("student-id" not in author or author.student-id == none or author.student-id == "") {
      panic("Student ID of '" + author.name + "' is missing. Specify a student ID for each author in the 'authors' attribute of the template.")
    }

    if ("course" not in author or author.course == none or author.course == "") {
      panic("Course of '" + author.name + "' is missing. Specify a course for each author in the 'authors' attribute of the template.")
    }

    if ("course-of-studies" not in author or author.course-of-studies == none or author.course-of-studies == "") {
      panic("Course of studies of '" + author.name + "' is missing. Specify a course of studies for each author in the 'authors' attribute of the template.")
    }

    if (at-university) {
      if ("company" in author) {
        panic("Company of '" + author.name + "' is not allowed. Remove the 'company' object from the author.")
      }

      if (type(city) != str or city == "") {
        panic("City is invalid. Specify a string containing a city in the 'city' attribute.")
      }
    } else {
      if (type(city) == str) {
        panic("Remove the City attribute. When 'at-university' is true the city inside the company object is used.")
      }

      if ("company" not in author) {
        panic("Author '" + author.name + "' is missing a company. Add the 'company' object to the author.")
      }
    }
  }

  if (language != "en" and language != "de") {
    panic("Language is invalid. Specify 'en' for English or 'de' for German in the 'language' attribute of the template.")
  }

  if (type(numbering-alignment) != alignment) {
    panic("Numbering alignment is invalid. Specify a alignment in the 'numbering-alignment' attribute of the template.")
  }

  if (type(toc-depth) != int) {
    panic("TOC depth is invalid. Specify an integer in the 'toc-depth' attribute of the template.")
  }

  if (
    type(date) != datetime and (
      type(date) != array or date.len() != 2 or type(date.at(0)) != datetime or type(date.at(1)) != datetime
    )
  ) {
    panic("Date is invalid. Specify a datetime in the 'date' attribute of the template to display a specific date or use a array containing two datetime elements to display a date range.")
  }

  let image-attributes = (
    logo-left: logo-left,
    logo-right: logo-right,
  )

  for (key, attribute) in image-attributes {
    if (type(attribute) != content and attribute != none) {
      panic("Attribute '" + key + "' is invalid. Specify an image in the '" + key + "' attribute of the template.")
    }
  }

  if (type(logo-size-ratio) != str or logo-size-ratio.len() == 0) {
    panic("Logo size ratio is missing. Specify a ratio in the 'logo-size-ratio' attribute of the template.")
  }

  let ratio = logo-size-ratio.split(":")

  if (ratio.len() != 2) {
    panic("Invalid ratio. Specify a ratio in the format 'x:y' in the 'logo-size-ratio' attribute of the template.")
  }

  if (type(bibliography) != content and bibliography != none) {
    panic("Bibliography is invalid. Specify a bibliography in the 'bibliography' attribute of the template.")
  }

  if (
    type(supervisor) != dictionary or (
      "company" not in supervisor or supervisor.company == none or supervisor.company == ""
    ) and ("university" not in supervisor or supervisor.university == none or supervisor.university == "")
  ) {
    panic("Supervisor(s) is/are invalid. Specify a supervisor either for the company and/or the university in the 'supervisor' attribute of the template.")
  }

  let string-array-attributes = (
    ignored-link-label-keys-for-highlighting: ignored-link-label-keys-for-highlighting,
  )

  for (key, attribute) in string-array-attributes {
    if (type(attribute) != array) {
      panic("Attribute '" + key + "' is invalid. Specify an array of strings in the '" + key + "' attribute of the template.")
    } else if (attribute.len() > 0) {
      if (type(attribute.at(0)) != str) {
        panic("Attribute '" + key + "' is invalid. Specify an array of strings in the '" + key + "' attribute of the template.")
      }
    }
  }
}