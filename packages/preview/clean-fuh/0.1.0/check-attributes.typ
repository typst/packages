#let check-attributes(
  title,
  authors,
  language,
  confidentiality-marker,
  type-of-thesis,
  show-gender-notice,
  show-confidentiality-statement,
  show-declaration-of-authorship,
  show-table-of-contents,
  show-abstract,
  abstract,
  appendix,
  confidentiality-statement-content,
  university,
  faculty,
  supervisor,
  date,
  date-format,
  companies,
  city,
  bibliography,
  glossary,
  bib-style,
  logo,
  math-numbering,
  ignored-link-label-keys-for-highlighting,
  startdate,
  enddate,
) = {

  
  // Check availability of title

  if (title == none or title == "") {
    panic("Title is missing. Specify a title in the 'title' attribute of the template.")
  }


  // Check type of boolean attributes

  let boolean-attributes = (
    show-confidentiality-statement: show-confidentiality-statement,
    show-table-of-contents: show-table-of-contents,
    show-declaration-of-authorship: show-declaration-of-authorship,
    show-abstract: show-abstract,
    show-gender-notice: show-gender-notice
  )

  for (key, attribute) in boolean-attributes {
    if (type(attribute) != bool) {
      panic("Attribute '" + key + "' is invalid. Specify 'true' or 'false' in the '" + key + "' attribute of the template.")
    }
  }


  // Check type and content (some shouldn't be empty) of string attributes

  let string-attributes = (
    university: university,
    faculty: faculty,
    date-format: date-format,
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
    city: city,
  )
  for (key, attribute) in optional-string-attributes {
    if (attribute != none and (type(attribute) != str or attribute.len() == 0)) {
      panic("Attribute '" + key + "' is invalid. Specify a string in the '" + key + "' attribute of the template.")
    }
  }

  // Check correctness of `abstract`

  if (abstract != none) {
    if (type(abstract) != array) {
      panic("Abstract is invalid. Specify an array of dictionaries in the 'abstract' attribute of the template.")
    }

    for abstract-entry in abstract {
      if (
        type(abstract-entry) != dictionary or
        "language" not in abstract-entry or
        type(abstract-entry.language) != str or
        abstract-entry.language == "" or
        (abstract-entry.language != "en" and abstract-entry.language != "de") or
        "content" not in abstract-entry or
        type(abstract-entry.content) != content
      ) {
        panic("Abstract is invalid. Specify an array of dictionaries with 'language' ('en' or 'de') and 'content' values in the 'abstract' attribute of the template.")
      }
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

  let max-authors = 8

  if (
    (type-of-thesis != none and type-of-thesis != "") or (
      confidentiality-marker.display == true
    )
  ) {
    max-authors -= 2
  }

  if (authors.len() > max-authors) {
    panic("Too many authors. Specify a maximum of " + str(max-authors) + " authors in the 'authors' attribute of the template.")
  }

  for author in authors {
    if ("name" not in author or author.name == none or author.name == "") {
      panic("Author name is missing. Specify a name for each author in the 'authors' attribute of the template.")
    }

    if ("student-id" not in author or author.student-id == none or author.student-id == "") {
      panic("Student ID of '" + author.name + "' is missing. Specify a student ID for each author in the 'authors' attribute of the template.")
    }


    if ("course-of-studies" not in author or author.course-of-studies == none or author.course-of-studies == "") {
      panic("Course of studies of '" + author.name + "' is missing. Specify a course of studies for each author in the 'authors' attribute of the template.")
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


  // Check correctness of optional date range fields

  if (
    (startdate == none and enddate != none) or (
      startdate != none and enddate == none
    )
  ) {
    panic("Date range is invalid. Specify both 'startdate' and 'enddate' or leave both as 'none'.")
  }

  if (startdate != none and type(startdate) != datetime) {
    panic("Attribute 'startdate' is invalid. Specify a datetime in the 'startdate' attribute of the template.")
  }

  if (enddate != none and type(enddate) != datetime) {
    panic("Attribute 'enddate' is invalid. Specify a datetime in the 'enddate' attribute of the template.")
  }


  // Check correctness of `companies`

  if (companies != none and type(companies) != array) {
    panic("Attribute 'companies' is invalid. Specify an array of dictionaries in the 'companies' attribute of the template.")
  }

  if (type(companies) == array) {
    for company in companies {
      if (
        type(company) != dictionary or
        "name" not in company or
        type(company.name) != str or
        company.name == ""
      ) {
        panic("Attribute 'companies' is invalid. Specify an array of dictionaries containing a non-empty string 'name' in the 'companies' attribute of the template.")
      }
    }
  }

  if (
    show-confidentiality-statement and
    confidentiality-statement-content == none and
    (type(companies) != array or companies.len() == 0)
  ) {
    panic("Companies are missing. Specify at least one company in the 'companies' attribute when using the generated confidentiality statement.")
  }


  // Checkt type and content of image-attributes

  let image-attributes = (
      logo: logo,
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
      "first" not in supervisor or supervisor.first == none or supervisor.first == ""
    ) and ("second" not in supervisor or supervisor.second == none or supervisor.second == "")
  ) {
    panic("At least one supervisor is required. Specify either a 'first' or 'second' supervisor in the 'supervisor' attribute of the template.")
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