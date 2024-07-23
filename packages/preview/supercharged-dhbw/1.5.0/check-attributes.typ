#let check-attributes(
    title,
    authors,
    language,
    at-dhbw,
    type-of-thesis,
    type-of-degree,
    show-confidentiality-statement,
    show-declaration-of-authorship,
    show-table-of-contents,
    show-acronyms,
    show-list-of-figures,
    show-list-of-tables,
    show-code-snippets,
    show-appendix,
    show-abstract,
    show-header,
    numbering-alignment,
    toc-depth,
    acronym-spacing,
    abstract,
    appendix,
    acronyms,
    university,
    university-location,
    supervisor,
    date,
    bibliography,
    logo-left,
    logo-right,
    logo-size-ratio,
  ) = {
  if (title == none or title == "") {
    panic("Title is missing. Specify a title in the 'title' attribute of the template.")
  }

  let boolean-attributes = (
    at-dhbw: at-dhbw,
    show-confidentiality-statement: show-confidentiality-statement,
    show-table-of-contents: show-table-of-contents,
    show-acronyms: show-acronyms,
    show-declaration-of-authorship: show-declaration-of-authorship,
    show-list-of-figures: show-list-of-figures,
    show-list-of-tables: show-list-of-tables,
    show-code-snippets: show-code-snippets,
    show-appendix: show-appendix,
    show-abstract: show-abstract,
    show-header: show-header
  )

  for (key, attribute) in boolean-attributes {
    if (type(attribute) != bool) {
      panic("Attribute '" + key + "' is invalid. Specify 'true' or 'false' in the '" + key + "' attribute of the template.")
    }
  }

  let string-attributes = (
    university: university,
    university-location: university-location,
    supervisor: supervisor,
  )

  for (key, attribute) in string-attributes {
    if (type(attribute) != str or attribute.len() == 0) {
      panic("Attribute '" + key + "' is missing. Specify a " + key + " in the '" + key + "' attribute of the template.")
    }
  }

  let optional-string-attributes = (
    type-of-thesis: type-of-thesis,
    type-of-degree: type-of-degree,
  )

  for (key, attribute) in optional-string-attributes {
    if (attribute != none and (type(attribute) != str or attribute.len() == 0)) {
      panic("Attribute '" + key + "' is invalid. Specify a string in the '" + key + "' attribute of the template.")
    }
  }

  if (authors == none or authors == ()) {
    panic("Author is missing. Specify authors in the 'authors' attribute of the template.")
  }

  let max-authors = if at-dhbw {
    8
  } else {
    6
  }

  if (
    (type-of-thesis != none and type-of-thesis != "") or
    (type-of-degree != none and type-of-degree != "")
  ) {
    max-authors -= 2
  }

  if (authors.len() > max-authors) {
    panic("Too many authors. Specify a maximum of " + str(max-authors) + " authors in the 'authors' attribute of the template. To increase the maximum number of authors (max. 8), change one of the following attributes: 'at-dhbw', 'type-of-thesis', 'type-of-degree'. (See the package documentation for more information.)")
  }

  for author in authors {
    if (
      "name" not in author or
      author.name == none or
      author.name == ""
    ) {
      panic("Author name is missing. Specify a name for each author in the 'authors' attribute of the template.")
    }

    if (
      "student-id" not in author or
      author.student-id == none or
      author.student-id == ""
    ) {
      panic("Student ID of '" + author.name + "' is missing. Specify a student ID for each author in the 'authors' attribute of the template.")
    }

    if (
      "course" not in author or
      author.course == none or
      author.course == ""
    ) {
      panic("Course of '" + author.name + "' is missing. Specify a course for each author in the 'authors' attribute of the template.")
    }

    if (
      "course-of-studies" not in author or
      author.course-of-studies == none or
      author.course-of-studies == ""
    ) {
      panic("Course of studies of '" + author.name + "' is missing. Specify a course of studies for each author in the 'authors' attribute of the template.")
    }

    if (not at-dhbw and "company" not in author) {
      panic("Author '" + author.name + "' is missing a company. Add the 'company' object to the author.")
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

  if (type(date) != datetime and (type(date) != array or date.len() != 2 or type(date.at(0)) != datetime or type(date.at(1)) != datetime)) {
    panic("Date is invalid. Specify a datetime in the 'date' attribute of the template to display a specific date or use a array containing two datetime elements to display a date range.")
  }

  let image-attributes = (
    logo-left: logo-left,
    logo-right: logo-right
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
}