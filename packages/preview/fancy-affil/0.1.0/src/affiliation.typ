#let SPACE = " "
#let GAP = h(1pt)

/*
Check if all elements in an array belong to one type.

Parameters
----------
array: array
    An array whose elements' types are to be checked.

Returns
-------
consistent: bool
    A boolean indicating whether all elements in the array are of the same type.
element-type: type
    The type of the first element in the array.
*/
#let is-consistent(array) = {
  let element-type = type(array.at(0))
  let consistent = true
  for element in array.slice(1) {
    if type(element) != element-type {
      consistent = false
      break
    }
  }
  (consistent, element-type) // Return
}

/*
Check the type of the input argument.

Parameters
----------
authors: any
    The input argument whose type is to be checked.

Returns
-------
type-num: int
    The return value is:
    0 if the argument is an array of strings.
    1 if the argument is an array of dictionaries.
    2 if the argument is a string.
    3 if the argument is a dictionary.
*/
#let argument-type(authors) = {
  let arg-type = -1
  let type-table = (str: 0, dictionary: 1)
  if type(authors) == array {
    let (consistent, element-type) = is-consistent(authors)
    assert(
      consistent,
      message: "Inconsistent elements.",
    )
    assert(
      element-type in (str, dictionary),
      message: "Invalid elements.",
    )
    if element-type == str {
      arg-type = 0
    } else if element-type == dictionary {
      arg-type = 1
    }
  } else if type(authors) == str {
    arg-type = 2
  } else if type(authors) == dictionary {
    arg-type = 3
  }
  assert(
    arg-type != -1,
    message: "Invalid arguments.",
  )
  arg-type // Return
}

/*
Find the location of an element in an array.

Parameters
----------
array: array
    The array in which to search for the element.
element: any
    The element to find in the array.

Returns
-------
int or none
    The index of the element in the array if found, otherwise none.
*/
#let findloc(array, element) = {
  let loc = array.position(x => { x == element })
  loc // Return
}

/*
Push indices (inner function of join-indices).

Given an array of indices, this function formats and pushes
the indices into the results array based on the specified format.

Parameters
----------
indices: array of integers
    The array to which the formatted indices will be pushed.
start-end: array of two integers
    A 2-element array representing the start and end of a range of indices.
format: string
    The numbering format to be used for formatting the indices.

Returns
-------
None
    This function modifies the `indices` array in place.
*/
#let push-indices(indices, start-end, format) = {
  let start-str = numbering(format, start-end.at(0))
  let end-str = numbering(format, start-end.at(1))

  if start-end.at(1) == start-end.at(0) {
    indices.push(start-str)
  } else if start-end.at(1) == start-end.at(0) + 1 {
    indices.push(start-str + "," + end-str)
  } else {
    indices.push(start-str + "-" + end-str)
  }
  indices // Return
}

/*
Join indices into a formatted string.

This function takes an array of indices and joins them
into a single string, using the specified format. 
Consecutive indices are represented as a range.

Parameters
----------
indices: array of integers
    An array of indices to be joined.
format: string
    The numbering format to be used for formatting the indices.

Returns
-------
string
    A string representing the joined indices.
*/
#let join-indices(indices, format) = {
  indices = indices.sorted()
  let start-end = (indices.at(0), indices.at(0))
  let results = ()

  for i in range(1, indices.len()) {
    if indices.at(i) == start-end.at(1) + 1 {
      start-end.at(1) = indices.at(i)
    } else {
      results = push-indices(results, start-end, format)
      start-end = (indices.at(i), indices.at(i))
    }
  }
  // Concatenate the last pair
  results = push-indices(results, start-end, format)
  results.join(",") // Return
}

/*
Parse authors, which is a dictionary to another dictionary.

Parameters
----------
authors: dictionary
    A dictionary containing authors' information. Each key is an author's name,
    and each value is a dictionary with detailed information about the author.
authors-numbering: string
    The numbering style for affiliation indices in authors.

Returns
-------
dictionary
A dictionary with the following keys:
- names: an array of strings
    An array containing the names of the authors.
- affils: an array of strings
    An array containing the names of the affiliations.
- affil-indices: an array of integer arrays
    An array of integer arrays representing the affiliation(s) of each author.
- emails: an array of strings
    An array containing the email addresses of the authors.
- orcids: an array of strings
    An array containing the ORCID IDs of the authors.
*/
#let parse-authors-dict(authors, authors-numbering) = {
  let (affils, affil-indices, emails, orcids) = ((), (), (), ())
  let orcid-domain = "https://orcid.org/"

  let names = authors.keys()
  for (name, author) in authors {
    if not "email" in author {
      emails.push(none)
    } else if type(author.email) == str {
      emails.push(author.email)
    }

    if not "orcid" in author {
      orcids.push(none)
    } else if type(author.orcid) == str {
      if not orcid-domain in author.orcid {
        author.orcid = orcid-domain + author.orcid
      }
      orcids.push(author.orcid)
    }

    if not "affiliation" in author {
      assert(false, message: "Missing affiliation.")
      affil-indices.push(none)
      affils.push(none)
      continue
    }

    let affil-local = ()
    let affil-type = argument-type(author.affiliation)

    assert(affil-type in (0, 2), message: "Invalid affiliation.")
    if affil-type == 0 {
      affil-local = author.affiliation
    } else if affil-type == 2 {
      affil-local.push(author.affiliation)
    }

    let indices = ()
    let loc = 0
    for affil in affil-local {
      loc = findloc(affils, affil)
      if loc != none {
        indices.push(loc + 1)
      } else {
        affils.push(affil)
        indices.push(affils.len())
      }
    }
    affil-indices.push(indices)
  }

  // Assemble affiliation indices
  let temp = ()
  for i in range(names.len()) {
    if affil-indices.at(i) != none {
      temp.push(join-indices(affil-indices.at(i), authors-numbering))
    } else { temp.push(none) }
  }
  affil-indices = temp

  // The output is a dictionary where
  // each element is an array of strings.
  let output-dict = (
    "name": names,
    "affil-index": affil-indices,
    "email": emails,
    "orcid": orcids,
    "affil": affils,
  )
  output-dict // Return
}

/* Initialize optional argument with a default value */
#let optional-argument(parameters-dict, argument, default) = {
  let result = default
  if argument in parameters-dict {
    result = parameters-dict.at(argument)
  }
  result // Return
}

/* Default author function */
#let default-authors-func(authors-text) = {
  set align(center)
  block(text(size: 12pt, authors-text))
}

/* Default affiliation function */
#let default-affil-func(affil-text) = {
  set align(center)
  set par(justify: false)
  set block(width: 95%)
  block(text(size: 10pt, affil-text))
}

/*
Extracts and formats authors' names and affiliations.

Parameters
----------
authors: array of strings or dictionaries
    An array containing authors' information. 
    Each element can be a string (author's name) or a dictionary with detailed information.
authors-join: string (default: ", ")
    The string used to join multiple authors' names.
authors-join-2: string (default: " and ")
    The string used to join two authors' names.
authors-func: function (default: default-authors-func)
    A function to style the authors' block.
authors-numbering: string (default: "1")
    The numbering style for affiliation indices in authors.
orcid-logo-size: length (default: 9.5pt)
    The size of the ORCID logo.
email-symbol: string (default: "🖂")
    The symbol used to denote email addresses.
authors-order: array (default: ("name", "orcid", "email", "affil-index"))
    The order of elements within each author box.
name-style: function (default: x => x)
    A function to style the author's name.
orcid-style: function (default: x => link(x, orcid-logo))
    A function to style the ORCID link.
email-style: function (default: x => link(x, email-symbol))
    A function to style the email link.
affil-indices-style: function (default: x => super(x))
    A function to style the affiliation indices.
authors-box-join: string (default: " ")
    The string used to join elements within each author box.
affil-label-numbering: string (default: "1.")
    The numbering style for affiliations.
affil-label-style: function (default: x => super(x))
    A function to style the affiliation labels.
affil-join: string (default: ", ")
    The string used to join multiple affiliations.
affil-func: function (default: default-affil-func)
    A function to style the affiliations' block.
affil-style: function (default: x => x)
    A function to style each affiliation.
affil-box-join: string (default: " ")
    The string used to join elements within each affiliation box.
affil-order: tuple (default: ("number", "affil"))
    The order of elements within each affiliation box.

Return
------
array of two blocks
    An array containing two blocks: the authors' block and the affiliations' block.
*/
#let get-affiliations(authors, ..parameters) = {
  // Local constant and functions
  let optional = optional-argument.with(parameters.named())

  let authors-type = argument-type(authors)
  assert(authors-type in (0, 3), message: "Invalid authors.")
  let authors-join = optional("authors-join", "," + SPACE)
  let authors-join-2 = optional("authors-join-2", SPACE + "and" + SPACE)
  let authors-func = optional("authors-func", default-authors-func)

  let authors-block = none
  let affiliations-block = none

  // If authors is an array of strings.
  if authors-type == 0 {
    // If there are only 2 authors use "and" otherwise use ",".
    if authors.len() == 2 { authors-join = authors-join-2 }
    authors-block = authors-func(authors.join(authors-join))
    // If authors is an array of dictionaries.
  } else if authors-type == 3 {
    let authors-numbering = optional("authors-numbering", "1")
    let authors-info = parse-authors-dict(authors, authors-numbering)

    // Authors
    if authors-info.name.len() == 2 {
      authors-join = authors-join-2
      // If two authors share same affiliation combine them.
      if affil-indices.at(0) == affil-indices.at(1) { affil-indices.at(0) = none }
    }

    let orcid-logo-size = optional("orcid-logo-size", 9.5pt)
    let orcid-logo = box(image("../data/ORCID_iD.svg", height: orcid-logo-size))
    let email-symbol = optional("email-symbol", symbol("🖂"))

    let authors-order = optional("authors-order", ("name", "orcid", "email", "affil-index"))
    let name-style = optional("name-style", x => x)
    let orcid-style = optional("orcid-style", x => link(x, orcid-logo))
    let email-style = optional("email-style", x => link(x, email-symbol))
    let affil-indices-style = optional("affil-indices-style", x => super(x))
    let style-funcs = (
      name: name-style,
      orcid: orcid-style,
      email: email-style,
      affil-index: affil-indices-style,
    )
    let authors-box-join = optional("authors-box-join", GAP)

    let (current-box, current-boxes) = (none, none)
    let authors-boxes = ()
    for i in range(authors-info.name.len()) {
      current-boxes = ()
      for key in authors-order {
        current-box = authors-info.at(key).at(i)
        if current-box != none { current-boxes.push(style-funcs.at(key)(current-box)) }
      }
      authors-boxes.push(current-boxes.join(authors-box-join))
    }
    authors-block = authors-func(authors-boxes.join(authors-join))

    // Affiliations
    let affil-label-numbering = optional("affil-label-numbering", "1")
    let affil-label-style = optional("affil-label-style", x => super(x))
    let affil-style = optional("affil-style", x => x)

    let affil-join = optional("affil-join", "," + SPACE)
    let affil-box-join = optional("affil-box-join", GAP)
    let affil-func = optional("affil-func", default-affil-func)
    let affil-order = optional("affil-order", ("number", "affil"))

    let affil-boxes = ()
    let (affil-label, affil) = ("", "")
    for i in range(authors-info.affil.len()) {
      affil-label = affil-label-style(numbering(affil-label-numbering, i + 1))
      affil = affil-style(authors-info.affil.at(i))

      if affil-order == ("number", "affil") {
        current-boxes = (affil-label, affil)
      } else if affil-order == ("affil", "number") {
        current-boxes = (affil, affil-label)
      }
      affil-boxes.push(current-boxes.join(affil-box-join))
    }
    affiliations-block = affil-func(affil-boxes.join(affil-join))
  }
  (authors-block, affiliations-block) // Return
}
