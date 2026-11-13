// Validated author records shared by all title layouts.
#import "shared.typ": fail

#let author-keys = (
  "affiliations",
  "corresponding",
  "email",
  "kind",
  "name",
  "orcid",
)
#let is-name(value) = value != none and (
  type(value) == content
    or (type(value) == str and value != "")
)

#let validate-name(value, name) = {
  if not is-name(value) {
    fail(name + " must be content or a non-empty string")
  }
  value
}

#let is-email(value) = type(value) == str and value.match(
  regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"),
) != none

// Format only: four hyphen-separated groups, with `X` allowed as the final
// character. The iD also carries a mod-11 check digit, but verifying it here
// bought little (it catches only rare transcription slips a format check
// misses) at the cost of the most intricate arithmetic in the file.
#let is-orcid(value) = type(value) == str and value.match(
  regex("^\\d{4}-\\d{4}-\\d{4}-\\d{3}[\\dX]$"),
) != none

#let validate-author(value, name: "author") = {
  if (
    type(value) != dictionary
      or value.keys().sorted() != author-keys
      or value.kind != "mosaic-author"
  ) {
    fail(name + " must be a name or created with author()")
  }
  _ = validate-name(value.name, name + " name")
  let affiliations = value.affiliations
  if type(affiliations) != array {
    fail(name + " affiliations must be an array")
  }
  for (index, affiliation) in affiliations.enumerate() {
    _ = validate-name(affiliation, name + " affiliation " + str(index + 1))
  }
  let email = value.email
  if email != none and not is-email(email) {
    fail(name + " email must be a valid email address")
  }
  let orcid = value.orcid
  if orcid != none and not is-orcid(orcid) {
    fail(name + " orcid must be a valid ORCID iD")
  }
  let corresponding = value.corresponding
  if type(corresponding) != bool {
    fail(name + " corresponding must be a boolean")
  }
  if corresponding and email == none and orcid == none {
    fail(name + " corresponding requires email or orcid")
  }
  value
}

/// Creates a validated author record for `setup(authors:)` and
/// `layouts.title(authors:)`.
///
/// A name on its own needs no record at all. `authors:` takes content or a
/// string wherever it takes a record, so `authors: [Ada Lovelace]` and
/// `authors: ([Ada Lovelace], [Charles Babbage])` are both complete author
/// lists. Reach for `author()` when a name carries more than itself:
///
/// ```typ
/// #let ada = mosaic.layouts.author(
///   [Ada Lovelace],
///   affiliations: ([Analytical Society], [University of London]),
///   email: "ada@example.org",
///   orcid: "0000-0002-1825-0097",
///   corresponding: true,
/// )
/// ```
///
/// *Affiliations*
///
/// An affiliation is the institution itself: content or a non-empty string.
/// Two authors share one legend number exactly when they give the same
/// affiliation, so bind a shared institution once and reuse the binding:
///
/// ```typ
/// #let lon = [University of London]
/// #let ada = mosaic.layouts.author([Ada Lovelace], affiliations: (lon,))
/// #let bab = mosaic.layouts.author([Charles Babbage], affiliations: (lon,))
/// ```
///
/// The `academic` title variant renders these as superscript numbers over a
/// numbered legend. Compact variants list them without numbering.
///
/// *Validation*
///
/// Values are checked at construction rather than at render time:
///
/// - `email` must look like an address.
/// - `orcid` must be a well-formed iD.
/// - `corresponding` requires at least one of `email` or `orcid`.
///
/// -> dictionary
#let author(
  /// The author's name, as the sole positional argument.
  /// -> content | str
  name,
  /// Array of institutions, as content or non-empty strings, in the order they
  /// should be listed for this author.
  /// -> array
  affiliations: (),
  /// Contact address, shown on the `academic` title variant and linked as a
  /// `mailto:`. Independent of `orcid`.
  /// -> str | none
  email: none,
  /// ORCID iD in `0000-0000-0000-0000` form (the last group may end in `X`,
  /// the iD's check-digit form), rendered as a linked ORCID label
  /// beside the name on every title variant. Independent of `email`.
  /// -> str | none
  orcid: none,
  /// Whether to mark this author as the corresponding one, with an asterisk
  /// beside the name and on the contact line. Requires `email` or `orcid`.
  /// -> bool
  corresponding: false,
) = validate-author((
  kind: "mosaic-author",
  name: name,
  affiliations: affiliations,
  email: email,
  orcid: orcid,
  corresponding: corresponding,
))

// Flattens a name to the plain string Typst's document author metadata takes.
//
// `set document(title: ..)` accepts content and flattens it itself, but
// `author:` accepts strings only. Without this, writing a name as content the
// way every other deck field is written would silently ship a PDF with no
// author. Names are ordinary words, so the cases below cover them: a bare name
// is one `text` element, and markup inside one is a sequence or a wrapper
// around further content. Anything else (a box, an image, a formula) has no
// plain reading, and `none` is what says so.
#let plain-name(value) = {
  if type(value) == str { return value }
  if type(value) != content { return none }
  let func = value.func()
  if func == text { return value.text }
  if func == [ ].func() { return " " }
  if func == linebreak { return " " }
  let children = value.at("children", default: none)
  if children != none {
    let parts = children.map(plain-name)
    return if none in parts { none } else { parts.join("") }
  }
  let body = value.at("body", default: none)
  if body != none { return plain-name(body) }
  none
}

// Normalizes every spelling an author list is allowed to take into an array of
// validated records, so nothing downstream sees a bare name.
//
// A name is whatever `author()` accepts as one, which makes `authors:` read
// like `subtitle:` and `date:` in the common case where an author is only a
// name. An array carries several of them, and the two spellings mix freely: a
// deck writes plain names until one author needs an affiliation or an ORCID iD,
// and then wraps that one in `author()` and leaves the rest alone.
#let resolve-authors(value, name: "author") = {
  let values = if type(value) == array { value } else { (value,) }
  values
    .enumerate()
    .map(((index, entry)) => validate-author(
      if is-name(entry) { author(entry) } else { entry },
      name: name + " " + str(index + 1),
    ))
}

// Canonical relationship analysis shared by validation and title renderers.
//
// Affiliations are deduplicated by the affiliation itself, so two authors share
// a legend number exactly when they name the same institution. A `#let` binding
// reused across authors therefore lands on one number without any separate
// identifier to declare. The key is the `repr` of the affiliation as content,
// because content is not hashable and because a string and the same text as
// content are one institution, not two.
#let analyze-authors(values) = {
  let name = "layout \"title\" author"
  let known = (:)
  let affiliations = ()
  let authors = ()
  for author in resolve-authors(values, name: name) {
    let numbers = ()
    for affiliation in author.affiliations {
      let key = repr(if type(affiliation) == str { [#affiliation] } else {
        affiliation
      })
      if key in known {
        numbers.push(known.at(key) + 1)
      } else {
        let index = affiliations.len()
        known.insert(key, index)
        affiliations.push(affiliation)
        numbers.push(index + 1)
      }
    }
    authors.push(author + (numbers: numbers,))
  }
  (authors: authors, affiliations: affiliations)
}
