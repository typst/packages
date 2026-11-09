// Entry point of the e-invoice generation: builds the data model, validates
// it and serializes the XML. The test suite checks the XML itself against
// the schema and Schematron of every profile (tools/zugferd/guard/, the
// corpus of tools/zugferd/).

#import "model.typ": build-model
#import "profile.typ": switch-profile
#import "rules/engine.typ": run-rules
#import "build.typ": build-xml

#let _has-errors(diagnostics) = diagnostics.any(d => d.level == "error")

// What only some invoices need (a fallback of `zugferd: auto`, a self-billed
// invoice) is in rare.typ, which loads when an invoice needs it.

/// Builds and checks the e-invoice of the computed invoice.
///
/// With `zugferd: auto`, the richest candidate profile the invoice satisfies
/// is chosen (see `resolve-profile`); the errors that ruled out a better one
/// are listed as warnings.
///
/// Returns `(profile: .., model: .., diagnostics: .., xml: ..)`. The XML is
/// always built; `diagnostics` lists every problem found (errors first), so
/// the caller decides whether to stop, report or ignore them.
///
/// -> dictionary
#let process-zugferd(
  ctx,
  item-data,
  // the signal of `payment-terms`
  payment-goal: none,
  bank: none,
  payment-means: none,
) = {
  let model = build-model(
    ctx,
    item-data,
    payment-goal: payment-goal,
    bank: bank,
    payment-means: payment-means,
  )
  let diagnostics = run-rules(model)

  // `zugferd: auto`: the next candidate while there are errors. The model
  // does not depend on the candidate profile, so switching the profile only
  // repeats the validation.
  let skipped = ()
  for id in model.profile.candidates.slice(1) {
    if not _has-errors(diagnostics) { break }
    skipped.push((
      id: model.profile.id,
      name: model.profile.name,
      diagnostics: diagnostics,
    ))
    model.profile = switch-profile(model.profile, id)
    diagnostics = run-rules(model)
  }
  if skipped.len() > 0 {
    import "rare.typ": skipped-warnings
    model.profile.skipped = skipped.map(c => (id: c.id, name: c.name))
    diagnostics += skipped-warnings(skipped, diagnostics)
  }

  let document = model.invoice.at("document", default: (:))
  if document.at("self-billed", default: false) {
    import "rare.typ": self-billed-diagnostic
    diagnostics = diagnostics.map(self-billed-diagnostic)
  }

  (
    profile: model.profile,
    model: model,
    diagnostics: diagnostics,
    xml: bytes(build-xml(model)),
  )
}
