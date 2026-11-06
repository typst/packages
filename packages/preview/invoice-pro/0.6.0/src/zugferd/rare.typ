// The rarely needed parts of process-zugferd (zugferd.typ): the warnings of
// the candidate profiles `zugferd: auto` skipped, and the diagnostics of a
// self-billed invoice. Most e-invoices need neither, so zugferd.typ loads
// this module only for an invoice that does (Typst parses a module when it
// is first imported).

// On a self-billed invoice, the sender of the document is the buyer and its
// recipient the seller (see `build-model`). The validator names the inputs
// of the seller as `sender` and those of the buyer as `recipient`, so they
// change places in the field and the texts of each diagnostic.
#let _other-party = (sender: "recipient", recipient: "sender")

#let _swap-parties(text) = {
  if type(text) != str { return text }
  text
    .replace("the sender", "\u{E000}")
    .replace("the recipient", "the sender")
    .replace("\u{E000}", "the recipient")
}

/// A diagnostic of a self-billed invoice with the parties in the field and
/// the texts swapped (see above).
///
/// -> dictionary
#let self-billed-diagnostic(d) = {
  let field = d.at("field", default: none)
  if type(field) == str {
    let (first, ..rest) = field.split(".")
    if first in _other-party {
      field = (_other-party.at(first), ..rest).join(".")
    }
  }
  (
    d
      + (
        field: field,
        message: _swap-parties(d.at("message", default: none)),
        hint: _swap-parties(d.at("hint", default: none)),
      )
  )
}

/// The errors that kept a better candidate profile out of reach and that the
/// chosen profile does not report itself, as warnings of the chosen profile.
/// A problem the chosen profile reports under a rule of its own (e.g. two
/// payment means: `BR-DE-23-b` in XRechnung, `CII-SR-467` in EN 16931; a
/// missing electronic address: `PEPPOL-EN16931-R010` in XRechnung, the
/// warning `IP-EADDR-01` in EN 16931) has the same field and message, and is
/// not listed twice either.
///
/// -> array
#let skipped-warnings(skipped, diagnostics) = {
  let reported = diagnostics.map(d => (d.rule, d.field))
  let problems = diagnostics.map(d => (d.field, d.message))
  let warnings = ()
  for candidate in skipped {
    for d in candidate.diagnostics {
      if (
        d.level == "error"
          and (d.rule, d.field) not in reported
          and (d.field, d.message) not in problems
      ) {
        reported.push((d.rule, d.field))
        warnings.push(
          d
            + (
              level: "warning",
              message: "Needed for " + candidate.name + ": " + d.message,
            ),
        )
      }
    }
  }
  warnings
}
