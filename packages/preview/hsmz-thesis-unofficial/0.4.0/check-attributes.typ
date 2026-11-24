#import "utils.typ": final-thesis-level, is-missing

// Every message names the parameter of `hsmz-thesis-unofficial.with(...)` in main.typ and shows an example, so that
// users can fix the problem without reading the source code. Messages are kept on a single line, because older
// Typst versions print them as a quoted string.
#let fail(message) = panic("hsmz-thesis-unofficial: " + message)

#let fail-missing(parameter, example, note: none) = fail(
  "the parameter `"
    + parameter
    + "` is missing"
    + if note != none { " (" + note + ")" } else { "" }
    + ". Add it to hsmz-thesis-unofficial.with(...) in main.typ, e.g. "
    + parameter
    + ": "
    + example,
)

#let check-attributes(
  thesis-type: none,
  title: none,
  faculty: none,
  degree-program: none,
  submission-date: none,
  confidentiality-period: none,
  ai-declaration-option: none,
  language: none,
  acronyms: none,
  symbols: none,
  bibliography: none,
  appendix: none,
  author: none,
  company: none,
  supervisor: none,
  font: none,
  citation-style: none,
  print-only-used-acronyms: none,
  show-full-bibliography: none,
  show-restriction-notice: none,
  show-management-summary: none,
  show-abstract: none,
  show-word-count: none,
  draft: none,
) = {
  // thesis data
  if is-missing(thesis-type) {
    fail-missing("thesis-type", "\"Bachelorarbeit\"")
  }

  if is-missing(title) {
    fail-missing("title", "\"Titel der Arbeit\"")
  }

  if is-missing(faculty) {
    fail-missing("faculty", "\"Wirtschaft\"")
  }

  if is-missing(degree-program) {
    fail-missing("degree-program", "\"Betriebswirtschaftslehre B. Sc.\"")
  }

  if is-missing(submission-date) {
    fail-missing("submission-date", "datetime(year: 2026, month: 3, day: 31)")
  }

  for (name, date) in (("submission-date", submission-date), ("confidentiality-period", confidentiality-period)) {
    if date != none and type(date) not in (str, content, datetime) {
      fail("`" + name + "` must be a date, e.g. " + name + ": datetime(year: 2026, month: 3, day: 31), or a string.")
    }
  }

  if ai-declaration-option == none {
    fail-missing(
      "ai-declaration-option",
      "1",
      note: "the option of the declaration of originality agreed with your supervisor",
    )
  }

  if ai-declaration-option not in (1, 2, 3) {
    fail(
      "`ai-declaration-option` must be 1 (AI tools allowed, brief documentation), 2 (AI tools allowed, extensive documentation) or 3 (AI tools prohibited), not "
        + repr(ai-declaration-option)
        + ".",
    )
  }

  if language not in ("de", "en") {
    fail("`language` must be \"de\" (German) or \"en\" (English), not " + repr(language) + ".")
  }

  if type(acronyms) != dictionary {
    fail("`acronyms` must be a dictionary, e.g. acronyms: (\"IT\": \"Informationstechnik\"), or (:) for none.")
  }

  if type(symbols) != array or symbols.any(it => type(it) != array or it.len() != 2) {
    fail(
      "`symbols` must be a list of (symbol, description) pairs, e.g. symbols: (($alpha$, [Signifikanzniveau]),). Note the comma at the end if there is only one symbol.",
    )
  }

  if is-missing(bibliography) {
    fail-missing("bibliography", "bibliography(\"literature.bib\")")
  }

  if appendix != none and type(appendix) != content {
    fail("`appendix` must be content, e.g. appendix: [= Fragebogen ...], or none.")
  }

  // people
  if type(author) != dictionary or author.len() == 0 {
    fail-missing(
      "author",
      "(name: \"Max Mustermann\", matriculation-number: \"1234567\", address: (street: \"Musterstraße 1\", zip: \"55128\", city: \"Mainz\"))",
    )
  }

  for (key, example) in (
    ("name", "\"Max Mustermann\""),
    ("matriculation-number", "\"1234567\""),
    ("address", "(street: \"Musterstraße 1\", zip: \"55128\", city: \"Mainz\")"),
  ) {
    if is-missing(author.at(key, default: none)) {
      fail("`author` has no `" + key + "`. Add it to the author dictionary in main.typ, e.g. " + key + ": " + example)
    }
  }

  if type(author.address) != dictionary {
    fail(
      "`author.address` must be a dictionary, e.g. address: (street: \"Musterstraße 1\", zip: \"55128\", city: \"Mainz\")",
    )
  }

  for (key, example) in (("street", "\"Musterstraße 1\""), ("zip", "\"55128\""), ("city", "\"Mainz\"")) {
    if is-missing(author.address.at(key, default: none)) {
      fail("`author.address` has no `" + key + "`. Add it to the address in main.typ, e.g. " + key + ": " + example)
    }
  }

  if is-missing(supervisor) {
    fail-missing("supervisor", "\"Prof. Dr. Norma Neugier\"", note: "including the academic degree")
  }

  // settings
  if is-missing(font) or font == () {
    fail-missing("font", "(\"Arial\", \"Liberation Sans\")")
  }

  if is-missing(citation-style) {
    fail-missing("citation-style", "\"apa\"")
  }

  for (name, value) in (
    ("print-only-used-acronyms", print-only-used-acronyms),
    ("show-full-bibliography", show-full-bibliography),
    ("show-restriction-notice", show-restriction-notice),
    ("show-management-summary", show-management-summary),
    ("show-abstract", show-abstract),
    ("show-word-count", show-word-count),
    ("draft", draft),
  ) {
    if type(value) != bool {
      fail("`" + name + "` must be true or false, not " + repr(value) + ".")
    }
  }

  // final theses need a Management Summary or an Abstract, or both (Leitfaden, Section 2.3)
  if final-thesis-level(thesis-type) != none and not show-management-summary and not show-abstract {
    fail(
      "a "
        + thesis-type
        + " needs a Management Summary or an Abstract (or both). Set show-abstract: true or show-management-summary: true.",
    )
  }

  // company and confidentiality period are only needed for the restriction notice
  if show-restriction-notice {
    let note = "required for the restriction notice; set show-restriction-notice: false if you don't need one"
    if is-missing(company) {
      fail-missing("company", "\"Musterfirma GmbH\"", note: note)
    }

    if is-missing(confidentiality-period) {
      fail-missing("confidentiality-period", "datetime(year: 2031, month: 3, day: 31)", note: note)
    }
  }
}
