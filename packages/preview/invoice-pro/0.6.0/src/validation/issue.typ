// Validation issues: one record type for every check that follows the
// validation level. API misuse (unknown keys, wrong types, cycles, unknown
// parts, undefined geometry) never becomes an issue: it panics directly,
// because no output could honour what the user wrote.

#import "../utils/patch.typ": did-you-mean

/// Issue classes that follow the validation level.
/// - data:  legally required data is missing or invalid (§ 14 UStG, EN 16931)
/// - theme: the theme cannot carry required output (unplaced role, empty part)
/// - lint:  a quality or export guard (contrast, footer fit, overlap, assets)
/// The rules of the e-invoice are no class: they run once no data issue is
/// open and follow `zugferd-errors` (see `components/root.typ`).
#let classes = ("data", "theme", "lint")

/// Classes whose issues make the machine-readable invoice incomplete. While
/// any of them is open, `draft` withholds the XML attachment (`strict` stops;
/// `none` runs no check, and `zugferd-errors` alone decides).
#let blocking-classes = ("data",)

/// The validation levels, strictest last. `none` switches every check of the
/// three classes off; misuse still panics.
#let levels = (none, "draft", "strict")

/// sys.inputs key that overrides `invoice(validation: ..)`, e.g.
/// `typst compile --input invoice-pro-validation=strict`.
#let input-key = "invoice-pro-validation"

/// Builds an issue record.
/// -> dictionary
#let issue(
  /// Stable identifier, unique per document (e.g. "invoice-number", "theme/role-recipient").
  /// -> str
  id,
  /// One of `classes`.
  /// -> str
  class,
  /// Developer message in English: the panic text under `strict`.
  /// -> str
  message,
  /// Legal or normative reference, shown in the issue list.
  /// -> none | str
  ref: none,
  /// How to fix it, as code (shown verbatim in the issue list); an array lists
  /// alternatives.
  /// -> none | str | array
  fix: none,
  /// Locale key under `strings.validation.field` for data issues (label and inline marker).
  /// -> none | str
  field: none,
  /// Locale key under `strings.validation.issues`: the report text in the document's
  /// language, a function of `args` (the English `message` stays the panic text
  /// and the fallback for keys a locale does not define).
  /// -> none | str
  key: none,
  /// Values the localised text interpolates (names, numbers).
  /// -> dictionary
  args: (:),
) = {
  assert(
    class in classes,
    message: "internal: unknown issue class " + repr(class),
  )
  (
    id: id,
    class: class,
    message: message,
    ref: ref,
    fix: fix,
    field: field,
    key: key,
    args: args,
  )
}

/// Resolves the effective level: `--input invoice-pro-validation=..` wins over
/// the parameter, so CI and batch pipelines can enforce `strict` (or render
/// thumbnails with `none`) without editing documents.
/// -> none | str
#let resolve-level(param, inputs: sys.inputs) = {
  // common synonyms get a pointed hint instead of a generic did-you-mean
  let synonym(v) = {
    let to = (
      visual: "\"draft\"",
      mark: "\"draft\"",
      warn: "\"draft\"",
      preview: "\"draft\"",
      panic: "\"strict\"",
      error: "\"strict\"",
      fail: "\"strict\"",
      off: "none",
      "none": "none",
      "false": "none",
    ).at(lower(str(v)), default: none)
    if to == none { did-you-mean(str(v), ("draft", "strict")) } else {
      " Did you mean " + to + "?"
    }
  }
  if param not in levels {
    panic(
      "variable `invoice::validation`("
        + repr(param)
        + ") must be one of none, \"draft\", \"strict\"."
        + if type(param) in (str, bool) { synonym(param) } else { "" },
    )
  }
  let raw = inputs.at(input-key, default: auto)
  if raw == auto { return param }
  let names = ("none", "draft", "strict")
  if raw not in names {
    panic(
      "--input "
        + input-key
        + "="
        + raw
        + " is not a validation level; use none, draft or strict."
        + synonym(raw).replace("\"", ""),
    )
  }
  if raw == "none" { none } else { raw }
}

/// The strict-level panic text for a list of issues. One issue: its message
/// verbatim. Several: a header line and a numbered list.
/// -> str
#let panic-text(issues) = {
  if issues.len() == 1 { return issues.first().message }
  (
    "invoice-pro found "
      + str(issues.len())
      + " problems (validation: \"strict\"; preview them with validation: \"draft\" or --input "
      + input-key
      + "=draft):\n"
      + issues
        .enumerate()
        .map(((i, x)) => "  " + str(i + 1) + ". " + x.message)
        .join("\n")
  )
}

/// Under `strict`, panics with every issue given; otherwise returns them.
/// -> array
#let enforce(issues, level) = {
  if level == "strict" and issues.len() > 0 { panic(panic-text(issues)) }
  issues
}

/// Drops later issues whose id was already seen (a render-time check may run
/// once per page).
/// -> array
#let dedupe(issues) = {
  let seen = ()
  let out = ()
  for x in issues {
    if x.id not in seen {
      seen.push(x.id)
      out.push(x)
    }
  }
  out
}
