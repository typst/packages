#let check-attributes(
  title,
  authors,
  language,
  at-university,
  confidentiality-marker,
  type-of-thesis,
  show-confidentiality-statement,
  show-declaration-of-authorship,
  show-table-of-contents,
  show-abstract,
  abstract,
  appendix,
  university,
  university-location,
  supervisor,
  date,
  city,
  bibliography,
  glossary,
  bib-style,
  logo-left,
  logo-right,
  university-short,
  math-numbering,
  ignored-link-label-keys-for-highlighting,
) = {

  
  // Check availability of title

  if (title == none or title == "") {
    panic("Title is missing. Specify a title in the 'title' attribute of the template.")
  }


  // Check type of boolean attributes

  let boolean-attributes = (
    at-university: at-university,
    show-confidentiality-statement: show-confidentiality-statement,
    show-table-of-contents: show-table-of-contents,
    show-declaration-of-authorship: show-declaration-of-authorship,
    show-abstract: show-abstract,
  )

  for (key, attribute) in boolean-attributes {
    if (type(attribute) != bool) {
      panic("Attribute '" + key + "' is invalid. Specify 'true' or 'false' in the '" + key + "' attribute of the template.")
    }
  }


  // Check type and content (some shouldn't be empty) of string attributes

  let string-attributes = (
    university: university,
    university-location: university-location,
    university-short: university-short,
  )

  // required string attributes
  for (key, attribute) in string-attributes {
    if (type(attribute) != str or attribute.len() == 0) {
      panic("Attribute '" + key + "' is missing. Specify a " + key + " in the '" + key + "' attribute of the template.")
    }
  }

  // optional string attribute
  let optional-string-attributes = (
    type-of-thesis: type-of-thesis,
    bib-style: bib-style,
    math-numbering: math-numbering,
  )
  for (key, attribute) in optional-string-attributes {
    if (attribute != none and (type(attribute) != str or attribute.len() == 0)) {
      panic("Attribute '" + key + "' is invalid. Specify a string in the '" + key + "' attribute of the template.")
    }
  }


  // Check validity of confidentialty-marker attributes

  if (type(confidentiality-marker) != none) {
    if (
      type(confidentiality-marker) != dictionary or "display" not in confidentiality-marker or type(confidentiality-marker.display) != bool
    ) {
      panic("Confidentiality marker is invalid. Specify a dictionary in the 'confidentiality-marker' attribute of the template containing a 'display' attribute with a boolean value.")
    }
  }


  // Check type of attributes containing `length`-values

  let length-attributes = ()

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


  // Check consistency of all attributes related to `authors`

  if (authors == none or authors == ()) {
    panic("Author is missing. Specify authors in the 'authors' attribute of the template.")
  }

  let max-authors = if at-university {
    8
  } else {
    6
  }

  if (
    (type-of-thesis != none and type-of-thesis != "") or (
      confidentiality-marker.display == true
    )
  ) {
    max-authors -= 2
  }

  if (authors.len() > max-authors) {
    panic("Too many authors. Specify a maximum of " + str(max-authors) + " authors in the 'authors' attribute of the template. To increase the maximum number of authors (max. 8), change one of the following attributes: 'at-university', 'type-of-thesis'. (See the package documentation for more information.)")
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


  // Check allowed languages

  if (language != "en" and language != "de") {
    panic("Language is invalid. Specify 'en' for English or 'de' for German in the 'language' attribute of the template.")
  }


  // Check correctness of `date`

  if (
    type(date) != datetime and (
      type(date) != array or date.len() != 2 or type(date.at(0)) != datetime or type(date.at(1)) != datetime
    )
  ) {
    panic("Date is invalid. Specify a datetime in the 'date' attribute of the template to display a specific date or use a array containing two datetime elements to display a date range.")
  }


  // Checkt type and content of image-attributes

  let image-attributes = (
    logo-left: logo-left,
    logo-right: logo-right,
  )

  for (key, attribute) in image-attributes {
    if (type(attribute) != content and attribute != none) {
      panic("Attribute '" + key + "' is invalid. Specify an image in the '" + key + "' attribute of the template.")
    }
  }


  // Check type of `glossary`
  if (glossary != none and type(glossary) != array) {
    panic("Type of `glossary` is invalid. It must be an array of arrays")
  }
  
  
  // Check availability of `bibliography`

  if (type(bibliography) != content and bibliography != none) {
    panic("Bibliography is invalid. Specify a bibliography in the 'bibliography' attribute of the template.")
  }


  // Check correctness of `supervisor`

  if (
    type(supervisor) != dictionary or (
      "company" not in supervisor or supervisor.company == none or supervisor.company == ""
    ) and ("university" not in supervisor or supervisor.university == none or supervisor.university == "")
  ) {
    panic("Supervisor(s) is/are invalid. Specify a supervisor either for the company and/or the university in the 'supervisor' attribute of the template.")
  }


  // Check type and content (not empty) of string array attributes
  
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