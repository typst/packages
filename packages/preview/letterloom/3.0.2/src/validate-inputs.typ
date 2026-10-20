/// Input Validation Module
///
/// Every public function in this module validates one concern and either
/// returns silently (valid) or panics with a human-readable message (invalid).
/// No content is produced here — validation is purely a precondition check
/// that runs before any layout work begins.
///
/// Design principles:
///
///   Fail fast and loudly — panics fire at the earliest possible point with a
///   message that names the offending field and states exactly what was wrong.
///   This is intentional: a bad parameter caught here produces a one-line error;
///   the same problem caught at render time produces a cryptic layout failure.
///
///   Narrow functions — each validate-* function validates exactly one
///   parameter group. validate-inputs() orchestrates them and is the only
///   function called from lib.typ.
///
///   Default-aware — several validators accept a `required` flag so they can
///   be reused for both mandatory fields (panic when absent) and optional fields
///   (silently pass when absent). Labels and other parameters that have sensible
///   defaults are validated only when the caller has overridden the default,
///   avoiding spurious errors on values the user never set.
///
///   Normalise before iterating — array-like parameters (signatures, cc,
///   enclosures, footer) accept both a single item and an array. Each validator
///   normalises to an array first so the per-item loop is always uniform.

// =============================================================================
// PRIMITIVE VALIDATORS
// These are the lowest-level helpers used by all composite validators.
// =============================================================================

/// Validates that a value is a Typst length (pt, em, cm, mm, etc.).
///
/// Used for all size parameters — font sizes, paragraph spacing, and so on.
/// Typst's `length` type covers absolute units (pt, mm, cm, in) and relative
/// units (em, fr). The `ratio` and `relative` types are distinct and are
/// intentionally excluded here; callers that need those accept them separately.
///
/// - length-value (any): The value to check.
/// - field-name (str): Parameter name shown in the panic message.
#let validate-length(length-value: none, field-name: none) = {
  if type(length-value) != length {
    panic(str(field-name) + " must be of type length.")
  }
}

/// Validates that a value is a non-empty string or content block.
///
/// Handles three distinct failure modes:
///   absent  — value is none when the field is required → "… is missing."
///   wrong type — value is neither str nor content       → "… must be a string or content block."
///   empty   — value is "" or []                         → "… is empty."
///
/// The `required` flag controls behaviour when the value is none:
///   required: true  → panic with "missing" message (field must be present)
///   required: false → return silently (field is optional; absence is fine)
///
/// Note: [] is an empty content block in Typst, distinct from none. Both ""
/// and [] are caught by the emptiness check so callers do not need to handle
/// either case separately.
///
/// - string-data (any): The value to check.
/// - field-name (str): Parameter name shown in panic messages.
/// - required (bool): Whether the field must be present (true) or may be none (false).
#let validate-string(string-data: none, field-name: none, required: true) = {
  // Optional field absent: nothing to validate
  if not required and string-data == none { return }

  // Required field absent
  if required and string-data == none {
    panic(str(field-name) + " is missing.")
  }

  // Wrong type: neither str nor content
  if type(string-data) not in (str, content) {
    panic(str(field-name) + " must be a string or content block.")
  }

  // Correct type but empty value
  if string-data in ("", []) {
    panic(str(field-name) + " is empty.")
  }
}

/// Validates that a value is a boolean (true or false).
///
/// The `required` flag mirrors the behaviour in validate-string:
///   required: true  → none triggers a "missing" panic
///   required: false → none is silently accepted
///
/// In practice this function is only called for `number-pages`, which defaults
/// to false — the validator is therefore invoked only when the caller has
/// explicitly supplied a non-false value (see validate-inputs).
///
/// - boolean-data (any): The value to check.
/// - field-name (str): Parameter name shown in panic messages.
/// - required (bool): Whether the field must be present.
#let validate-boolean(boolean-data: none, field-name: none, required: true) = {
  if not required and boolean-data == none { return }

  if required and boolean-data == none {
    panic(str(field-name) + " is missing.")
  }

  if type(boolean-data) != bool {
    panic(str(field-name) + " must be a true or false value.")
  }
}

// =============================================================================
// COMPOSITE VALIDATORS — LETTER CONTENT FIELDS
// Each function validates one parameter group in full.
// =============================================================================

/// Validates the signatures array.
///
/// Signatures are the only required field that cannot be checked by
/// validate-string because the expected type is a dictionary (or array of
/// dictionaries), not a string or content block.
///
/// Validation is layered: structure first, then required keys, then types,
/// then emptiness. This order means the earliest possible failure produces
/// the most specific message — a non-dictionary value is caught before the
/// "name is missing" check that would otherwise produce a confusing error.
///
/// A single dictionary (one signatory) is normalised to a one-element array
/// before iteration so the per-item loop is always uniform.
///
/// - signatures (any): The signatures parameter value from the caller.
#let validate-signatures(signatures: none) = {
  // Absent or explicitly empty array: field is required so always panic.
  // An empty tuple () is treated the same as none — there must be at least
  // one signatory.
  if signatures in (none, ()) {
    panic("signatures are missing.")
  }

  // Normalise a bare dictionary to a one-element array
  if type(signatures) != array {
    signatures = (signatures,)
  }

  for signature in signatures {
    // Each item must be a dictionary. str and content are common mistakes
    // (e.g. passing a list of name strings instead of dictionaries).
    if type(signature) != dictionary {
      panic("signature '" + str(signature) + "' must be a dictionary with a required name field and optional signature and affiliation fields.")
    }

    // The name key is required; all other keys (signature, affiliation) are optional.
    if "name" not in signature {
      panic("signature name is missing.")
    }

    let name = signature.at("name")

    // Name must be renderable text — numbers, booleans, and none are all invalid.
    if type(name) not in (str, content) {
      panic("signature name '" + str(name) + "' must be a string or content block.")
    }

    // Name must carry visible text; an empty string or empty content block
    // would produce a blank line in the signature area.
    if name in ("", []) {
      panic("signature name is empty.")
    }
  }
}

/// Validates the attention line parameters.
///
/// Called only when attn-name is present (see validate-inputs). The name
/// itself is checked via validate-string. The label is only validated when
/// the caller has overridden the default ("Attn:") — leaving the default
/// in place skips the label check entirely to avoid false positives.
/// attn-position is an enum-style string limited to "above" or "below".
///
/// - attn-name (any): The attention recipient name.
/// - attn-label (any): The label printed before the name.
/// - attn-position (any): Placement relative to the recipient address.
#let validate-attn(attn-name: none, attn-label: none, attn-position: none) = {
  // Name is required when this function is called
  validate-string(string-data: attn-name, field-name: "attn-name")

  // Label only needs checking when the caller has changed it from the default.
  // The default "Attn:" is a known-good value that was never passed through
  // user input, so re-validating it every time would be noise.
  if attn-label != "Attn:" {
    validate-string(string-data: attn-label, field-name: "attn-label")
  }

  // Position is an enum string — only two values are accepted.
  if attn-position not in ("above", "below") {
    panic("attn-position must be one of above or below.")
  }
}

/// Validates the cc list and its label.
///
/// Called only when cc is non-none (see validate-inputs). The cc value may
/// be a single string/content or an array of them; either form is normalised
/// to an array before iteration so each item is checked individually.
///
/// The label is validated only when overridden from the default ("cc:"),
/// using the same default-bypass pattern as validate-attn.
///
/// - cc (any): One or more cc recipients.
/// - cc-label (any): The label printed before the recipient list.
#let validate-cc(cc: none, cc-label: none) = {
  // cc was already confirmed non-none by the caller guard, but an explicit
  // empty string, empty content block, or empty array is still invalid —
  // there must be at least one readable recipient.
  if cc in (none, (), "", []) {
    panic("cc is empty.")
  }

  // Normalise a bare string or content to a one-element array
  if type(cc) != array {
    cc = (cc,)
  }

  // Each recipient must be renderable text
  for cc-recipient in cc {
    if type(cc-recipient) not in (str, content) {
      panic("cc recipient '" + str(cc-recipient) + "' must be a string or content block.")
    }
  }

  // Label: skip validation when using the default to avoid unnecessary checks
  if cc-label != "cc:" {
    if type(cc-label) not in (str, content) {
      panic("cc-label '" + str(cc-label) + "' must be a string or content block.")
    }
    if cc-label in ("", []) {
      panic("cc-label is empty.")
    }
  }
}

/// Validates the enclosures list and its label.
///
/// Called only when enclosures is non-none (see validate-inputs). The
/// enclosures value is normalised to an array and each item is validated
/// in full before the label is checked.
///
/// Per-item validation order:
///   1. Must be a dictionary (not a bare string or number).
///   2. Must contain the required "description" key.
///   3. description must be a non-empty string or content block.
///   4. file, if present, must be bytes (from read("path", encoding: none)).
///   5. pages, if present, must be a positive integer (≥ 1).
///   6. page-inset, if present, must be a length or a dictionary of lengths
///      using only the recognised shorthand keys.
///
/// page-inset key validation is strict: any unrecognised key is rejected
/// immediately rather than silently ignored, because an unknown key would be
/// discarded during normalisation in construct-outputs.typ and the user would
/// never know their inset was not applied.
///
/// - enclosures (any): One or more enclosure dictionaries.
/// - enclosures-label (any): The label printed before the enclosure list.
#let validate-enclosures(enclosures: none, enclosures-label: none) = {
  // An explicit empty value is treated as a programming error: the caller
  // passed enclosures but provided no actual enclosure data.
  if enclosures in (none, (), "", []) {
    panic("enclosures are empty.")
  }

  // Normalise a bare dictionary to a one-element array
  if type(enclosures) != array {
    enclosures = (enclosures,)
  }

  for enclosure in enclosures {
    // Structure check: each item must be a dictionary
    if type(enclosure) != dictionary {
      panic("enclosure must be a dictionary with a description field.")
    }

    // Required key: description
    if "description" not in enclosure {
      panic("enclosure description is missing.")
    }

    let description = enclosure.at("description")
    if type(description) not in (str, content) {
      panic("enclosure description '" + str(description) + "' must be a string or content block.")
    }
    if description in ("", []) {
      panic("enclosure description is empty.")
    }

    // Optional key: file
    // Must be raw bytes loaded via read("path", encoding: none). Passing an
    // image() call or a string path are both common mistakes that produce
    // confusing errors at render time without this check.
    if "file" in enclosure {
      let file = enclosure.at("file")
      if type(file) != bytes {
        panic("enclosure file must be bytes loaded via read(\"path\", encoding: none).")
      }
    }

    // Optional key: pages
    // Must be a positive integer. Zero and negative values are meaningless
    // (no pages would be rendered); floats are rejected because Typst's
    // image() page argument requires an integer.
    if "pages" in enclosure {
      let pages = enclosure.at("pages")
      if type(pages) != int or pages < 1 {
        panic("enclosure pages '" + str(pages) + "' must be a positive integer.")
      }
    }

    // Optional key: page-inset
    // Accepts a single length (applied to all sides) or a dictionary using
    // the recognised shorthand keys. An unrecognised key is rejected here
    // rather than silently ignored during normalisation in construct-outputs.typ.
    if "page-inset" in enclosure {
      let page-inset = enclosure.at("page-inset")
      if type(page-inset) == length {
        // Single length: valid — applied uniformly to all four sides
      } else if type(page-inset) == dictionary {
        let valid-keys = ("top", "bottom", "left", "right", "x", "y", "rest")
        for (key, value) in page-inset {
          if key not in valid-keys {
            panic("enclosure page-inset key '" + key + "' is not valid. Must be one of top, bottom, left, right, x, y, or rest.")
          }
          if type(value) != length {
            panic("enclosure page-inset value for '" + key + "' must be a length.")
          }
        }
      } else {
        panic("enclosure page-inset must be a length or a dictionary of lengths.")
      }
    }
  }

  // Label: skip validation when using the default to avoid unnecessary checks.
  // Only validate when the caller has explicitly overridden "encl:".
  if enclosures-label != "encl:" {
    if type(enclosures-label) not in (str, content) {
      panic("enclosure label '" + str(enclosures-label) + "' must be a string or content block.")
    }
    if enclosures-label in ("", []) {
      panic("enclosure label is empty.")
    }
  }
}

/// Validates the custom footer array.
///
/// Called only when footer is non-none and non-empty (see validate-inputs).
/// A bare dictionary is normalised to a one-element array before iteration.
///
/// Per-item validation:
///   1. Each item must be a dictionary.
///   2. footer-text is required and must be a non-empty string or content block.
///   3. footer-type, if present, must be one of "url", "email", or "string".
///      Any other value would cause construct-custom-footer to silently fall
///      through to the plain-text branch, producing a link that looks like
///      text — a subtle bug caught here instead.
///
/// - footer (any): One or more footer element dictionaries.
#let validate-footer(footer: none) = {
  if footer not in (none, ()) {
    // Normalise a bare dictionary to a one-element array
    if type(footer) != array {
      footer = (footer,)
    }

    for footer-elem in footer {
      // Each element must be a dictionary carrying at minimum a footer-text key
      if type(footer-elem) != dictionary {
        panic("footer element '" + str(footer-elem) + "' must be a dictionary.")
      }

      // footer-text is the only required key; footer-type is optional
      if "footer-text" not in footer-elem {
        panic("footer-text is missing.")
      }

      let footer-text = footer-elem.at("footer-text")
      if type(footer-text) not in (str, content) {
        panic("footer-text '" + str(footer-text) + "' must be a string or content block.")
      }

      // footer-type is optional; when absent, construct-custom-footer defaults
      // to "string". When present, it must be one of the three recognised values.
      if "footer-type" in footer-elem {
        let footer-type = footer-elem.at("footer-type")
        if footer-type not in ("url", "email", "string") {
          panic("footer-type '" + str(footer-type) + "' must be one of url, email or string.")
        }
      }
    }
  }
}

/// Validates the letterhead dictionary.
///
/// Called unconditionally from validate-inputs; returns immediately when
/// letterhead is none so callers do not need their own none-guard.
///
/// Validation order matches the visual importance of each key:
///   1. Overall structure: must be a dictionary.
///   2. file: required; must be bytes (a common mistake is passing image()).
///   3. width: optional; must be length, ratio, or relative.
///   4. height: optional; must be a plain length.
///   5. image-inset: optional; length or per-side dictionary with known keys.
///   6. image-alignment: optional; one of left, center, right.
///   7. sender-position: optional; one of left, center, right.
///   8. bottom-gap: optional; must be a length.
///   9. sender-valign: optional; one of top, horizon, bottom.
///
/// image-inset and page-inset share the same shorthand key set and the same
/// validation logic. Both reject unrecognised keys immediately rather than
/// silently discarding them during normalisation.
///
/// sender-position and image-alignment accept Typst alignment values (left,
/// center, right), not strings. Passing "left" instead of left would pass a
/// type(alignment) check but fail the `not in (left, center, right)` membership
/// check, which is why membership is tested rather than type.
///
/// sender-valign accepts vertical alignment values (top, horizon, bottom).
/// Horizontal alignments (left, center, right) and strings are both rejected.
///
/// - letterhead (any): The letterhead parameter value from the caller.
#let validate-letterhead(letterhead: none) = {
  if letterhead == none { return }

  // Must be a dictionary; any other type (str, content, int) is invalid
  if type(letterhead) != dictionary {
    panic("letterhead must be a dictionary with a required file key.")
  }

  // file is the only required key — everything else is optional
  if "file" not in letterhead {
    panic("letterhead is missing the required file key.")
  }

  // file must be raw bytes from read("path", encoding: none). An image()
  // call, a string path, or a content block are all common mistakes.
  if type(letterhead.file) != bytes {
    panic("letterhead.file must be bytes loaded via read(path, encoding: none).")
  }

  // width: length covers pt/mm/cm/in/em; ratio covers %; relative covers
  // mixed expressions like "50% + 5mm". auto is the accepted default and
  // is handled at runtime, not validated here.
  if "width" in letterhead {
    if type(letterhead.width) not in (length, ratio, relative) {
      panic("letterhead.width must be a length or percentage (e.g. 50% or 50% + 5mm).")
    }
  }

  // height: plain length only — ratio and relative are not accepted because
  // percentage heights are ambiguous without an explicit reference height.
  if "height" in letterhead {
    if type(letterhead.height) != length {
      panic("letterhead.height must be a length.")
    }
  }

  // image-inset: the same shorthand key set as enclosure page-inset.
  // An empty if-body for the length branch documents that a single length
  // is valid without requiring a noop statement or re-ordering the branches.
  if "image-inset" in letterhead {
    let m = letterhead.at("image-inset")
    if type(m) == length {
      // Single length: valid — applied uniformly to all four sides
    } else if type(m) == dictionary {
      let valid-keys = ("top", "bottom", "left", "right", "x", "y", "rest")
      for (key, value) in m {
        if key not in valid-keys {
          panic("letterhead.image-inset key '" + key + "' is not valid. Must be one of top, bottom, left, right, x, y, or rest.")
        }
        if type(value) != length {
          panic("letterhead.image-inset value for '" + key + "' must be a length.")
        }
      }
    } else {
      panic("letterhead.image-inset must be a length or a dictionary of lengths.")
    }
  }

  // image-alignment: only applicable in the full-width layout (sender-position
  // absent). Horizontal alignment values only — top/bottom/horizon are invalid.
  if "image-alignment" in letterhead {
    if letterhead.at("image-alignment") not in (left, center, right) {
      panic("letterhead.image-alignment must be left, center, or right.")
    }
  }

  // sender-position: selects the layout mode (left/right = side-by-side,
  // center = stacked). Accepts alignment values, not strings.
  if "sender-position" in letterhead {
    if letterhead.sender-position not in (left, center, right) {
      panic("letterhead.sender-position must be left, center, or right.")
    }
  }

  // bottom-gap: extra space below the sender in center layout only.
  // Irrelevant for other layouts but not an error if supplied — it is
  // simply ignored by the other branches in construct-letterhead.
  if "bottom-gap" in letterhead {
    if type(letterhead.at("bottom-gap")) != length {
      panic("letterhead.bottom-gap must be a length (e.g. 1em, 5mm).")
    }
  }

  // sender-valign: vertical alignment of the sender column in left/right
  // layouts. Accepts only vertical alignment values; horizontal alignments
  // (left, center, right) and strings are both rejected by the membership check.
  if "sender-valign" in letterhead {
    if letterhead.at("sender-valign") not in (top, horizon, bottom) {
      panic("letterhead.sender-valign must be top, horizon, or bottom.")
    }
  }
}

/// Validates the required-fields configuration array.
///
/// required-fields is a meta-parameter that controls which of the nine
/// standard letter fields are enforced as mandatory. Validating it first
/// (before any field content) means a misconfigured required-fields array
/// fails immediately with a clear message rather than causing confusing
/// downstream behaviour such as unexpected "missing" panics or silently
/// omitted sections.
///
/// Every entry must be a string and must be one of the nine recognised field
/// names. An unrecognised string would be silently ignored by the `in`
/// membership test in validate-inputs, so it is rejected here to prevent
/// the user from believing they have made a field optional when they have not.
///
/// - required-fields (any): The required-fields parameter value from the caller.
#let validate-required-fields(required-fields: none) = {
  // The nine field names that may be listed in required-fields.
  // Any string outside this set is a typo or an unsupported extension.
  let valid = (
    "from-name", "from-address", "to-name", "to-address",
    "date", "salutation", "subject", "closing", "signatures",
  )

  // Must be an array; a bare string or none is a common mistake
  if type(required-fields) != array {
    panic("required-fields must be an array of field names.")
  }

  for field in required-fields {
    // Each entry must be a string — numbers and booleans are not valid names
    if type(field) != str {
      panic("required-fields entry '" + str(field) + "' must be a string.")
    }
    // Must be one of the nine recognised names
    if field not in valid {
      panic("'" + field + "' is not a valid required field name.")
    }
  }
}

// =============================================================================
// ORCHESTRATOR
// =============================================================================

/// Runs all validations for the letterloom function in a defined order.
///
/// Validation is grouped into five phases:
///
///   1. required-fields configuration  — validates the meta-parameter first so
///      subsequent phase 2 membership tests (`"x" in required-fields`) are
///      operating on a known-good array.
///
///   2. configurable required fields   — the nine standard letter fields, each
///      checked via validate-string or validate-signatures. The `required`
///      argument is derived from the already-validated required-fields array,
///      so fields removed by the caller are silently accepted as none.
///      signatures uses a two-branch guard: validate when required, and also
///      validate when optional-but-supplied, because a present-but-malformed
///      signatures value should always be caught regardless of required-fields.
///
///   3. formatting parameters          — length type checks for all size and
///      spacing values. These are always required regardless of required-fields
///      because they affect the document layout unconditionally.
///
///   4. optional letter elements       — attn, cc, enclosures, letterhead,
///      footer. Each is guarded by a none check so its validator is only
///      invoked when the caller has supplied a value. validate-letterhead is
///      the exception: it includes its own internal none guard and is called
///      unconditionally for clarity.
///
///   5. Typst-specific types           — alignment and color parameters cannot
///      be checked by the generic validators above (there is no alignment
///      equivalent of validate-string), so they are checked inline using
///      Typst's type() function and explicit membership tests.
///
/// - (all letterloom parameters): Forwarded directly from lib.typ.
#let validate-inputs(
  from-name: none,
  from-address: none,
  to-name: none,
  to-address: none,
  date: none,
  salutation: none,
  subject: none,
  closing: none,
  signatures: none,
  required-fields: ("from-name", "from-address", "to-name", "to-address", "date", "salutation", "subject", "closing", "signatures"),
  signature-alignment: left,
  attn-name: none,
  attn-label: "Attn:",
  attn-position: "above",
  cc: none,
  cc-label: "cc:",
  enclosures: none,
  enclosures-label: "encl:",
  letterhead: none,
  footer: none,
  par-leading: 0.8em,
  par-spacing: 1.8em,
  number-pages: false,
  main-font-size: 11pt,
  footer-font-size: 9pt,
  footnote-font-size: 7pt,
  from-alignment: right,
  date-alignment: right,
  footnote-alignment: left,
  link-color: blue,
) = {

  // ===========================================================================
  // PHASE 1 — REQUIRED-FIELDS CONFIGURATION
  //
  // Validate the meta-parameter before anything else. If required-fields
  // contains an unrecognised name or a non-string, the membership tests in
  // phase 2 would silently pass instead of correctly enforcing the field.
  // ===========================================================================
  validate-required-fields(required-fields: required-fields)

  // ===========================================================================
  // PHASE 2 — CONFIGURABLE REQUIRED FIELDS
  //
  // Each field is checked with required: <field> in required-fields, so fields
  // removed from required-fields are validated as optional (none is accepted).
  // Fields left in the array are validated as mandatory (none triggers a panic).
  //
  // Signatures are special: validate-signatures handles the full structure check
  // (dictionary, name key, name type/emptiness) that validate-string cannot.
  // The two-branch guard ensures a supplied-but-malformed signatures value is
  // always caught, even when "signatures" has been removed from required-fields.
  // ===========================================================================
  validate-string(string-data: from-name,    field-name: "from-name",    required: "from-name"    in required-fields)
  validate-string(string-data: from-address, field-name: "from-address", required: "from-address" in required-fields)
  validate-string(string-data: to-name,      field-name: "to-name",      required: "to-name"      in required-fields)
  validate-string(string-data: to-address,   field-name: "to-address",   required: "to-address"   in required-fields)
  validate-string(string-data: date,         field-name: "date",         required: "date"         in required-fields)
  validate-string(string-data: salutation,   field-name: "salutation",   required: "salutation"   in required-fields)
  validate-string(string-data: subject,      field-name: "subject",      required: "subject"      in required-fields)
  validate-string(string-data: closing,      field-name: "closing",      required: "closing"      in required-fields)

  if "signatures" in required-fields {
    // Required: must be present and well-formed
    validate-signatures(signatures: signatures)
  } else if signatures != none {
    // Optional but supplied: still must be well-formed
    validate-signatures(signatures: signatures)
  }

  // ===========================================================================
  // PHASE 3 — FORMATTING PARAMETERS
  //
  // Size and spacing values are always required regardless of required-fields,
  // because they affect the document geometry unconditionally. Each must be a
  // Typst length; passing a number (e.g. 11 instead of 11pt) is a common
  // mistake caught here.
  // ===========================================================================
  validate-length(length-value: main-font-size,    field-name: "main-font-size")
  validate-length(length-value: footer-font-size,  field-name: "footer-font-size")
  validate-length(length-value: footnote-font-size, field-name: "footnote-font-size")
  validate-length(length-value: par-leading,        field-name: "par-leading")
  validate-length(length-value: par-spacing,        field-name: "par-spacing")

  // ===========================================================================
  // PHASE 4 — OPTIONAL LETTER ELEMENTS
  //
  // Each validator is guarded by a none check so it only runs when the caller
  // has supplied the corresponding feature. validate-letterhead is the
  // exception: it guards itself internally and is called unconditionally here
  // for readability.
  // ===========================================================================

  if attn-name != none {
    validate-attn(attn-name: attn-name, attn-label: attn-label, attn-position: attn-position)
  }

  if cc != none {
    validate-cc(cc: cc, cc-label: cc-label)
  }

  if enclosures != none {
    validate-enclosures(enclosures: enclosures, enclosures-label: enclosures-label)
  }

  // Called unconditionally — validate-letterhead returns immediately when none
  validate-letterhead(letterhead: letterhead)

  if footer != none {
    validate-footer(footer: footer)
  }

  // ===========================================================================
  // PHASE 5 — TYPST-SPECIFIC TYPES
  //
  // Alignment and color values have dedicated Typst types that cannot be
  // checked via the generic primitive validators. type(x) == alignment catches
  // any non-alignment value (strings, integers, none) in a single test.
  // The alignment checks do not constrain which direction (left/right/center/
  // top/etc.) is used — that is enforced within each construct-* function where
  // the specific direction matters (e.g. signature-alignment only uses
  // horizontal alignments, which is guaranteed by construct-signatures).
  // ===========================================================================

  if type(from-alignment) != alignment {
    panic("from-alignment must be a valid alignment type.")
  }

  if type(date-alignment) != alignment {
    panic("date-alignment must be a valid alignment type.")
  }

  if type(footnote-alignment) != alignment {
    panic("footnote-alignment must be a valid alignment type.")
  }

  if type(signature-alignment) != alignment {
    panic("signature-alignment must be a valid alignment type.")
  }

  if type(link-color) != color {
    panic("link-color must be a valid color type.")
  }
}
