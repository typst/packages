/// Input Validation Module
///
/// This module provides comprehensive validation functions for the letterloom package.
/// It ensures that all input parameters meet the required format and type constraints
/// before processing, providing clear error messages for invalid inputs.

/// Validates that a value is of length type (e.g., em, pt, cm, etc.).
#let validate-length(length-value: none, field-name: none) = {
  if type(length-value) != length {
    panic(str(field-name) + " must be of type length.")
  }
}

/// Validates that a value is a non-empty string or content block.
#let validate-string(string-data: none, field-name: none, required: true) = {
  // Handle optional fields
  if not required and string-data == none {
    return
  }

  // Validate required fields
  if required and string-data == none {
    panic(str(field-name) + " is missing.")
  }

  // Validate type
  if type(string-data) not in (str, content) {
    panic(str(field-name) + " must be a string or content block.")
  }

  // Validate non-empty
  if string-data in ("", []) {
    panic(str(field-name) + " is empty.")
  }
}

/// Validates that a value is of boolean type.
#let validate-boolean(boolean-data: none, field-name: none, required: true) = {
  // Handle optional fields
  if not required and boolean-data == none {
    return
  }

  // Validate required fields
  if required and boolean-data == none {
    panic(str(field-name) + " is missing.")
  }

  // Validate type
  if type(boolean-data) != bool {
    panic(str(field-name) + " must be a true or false value.")
  }
}

/// Validates signature structure and content.
#let validate-signatures(signatures: none) = {
  // Validate presence of signatures
  if signatures in (none, ()) {
    panic("signatures are missing.")
  }

  // Handle the case where only one signature is given
  if type(signatures) != array {
    signatures = (signatures,)
  }

  // Validate each signature
  for signature in signatures {
    // Validate signature is a dictionary
    if type(signature) != dictionary {
      panic("signature '" + str(signature) + "' must be a dictionary with a required name field and optional signature, title, and affiliation fields.")
    }

    // Validate presence of name field
    if "name" not in signature {
      panic("signature name is missing.")
    }

    let name = signature.at("name")
    // Validate name field type
    if type(name) not in (str, content) {
      panic("signature name '" + str(name) + "' must be a string or content block.")
    }

    // Validate name field is not empty
    if name in ("", []) {
      panic("signature name is empty.")
    }
  }
}

/// Validates attention line format (optional).
#let validate-attn(attn-name: none, attn-label: none, attn-position: none) = {
  validate-string(string-data: attn-name, field-name: "attn-name")

  // Validate optional label
  if attn-label != "Attn:" {
    validate-string(string-data: attn-label, field-name: "attn-label")
  }

  if attn-position not in ("above", "below") {
    panic("attn-position must be one of above or below.")
  }
}

/// Validates cc list and cc-label format (optional).
#let validate-cc(cc: none, cc-label: none) = {
  // Validate cc field is not empty
  if cc in (none, (), "", []) {
    panic("cc is empty.")
  }

  // Handle the case where only one cc recipient is given
  if type(cc) != array {
    cc = (cc,)
  }

  // Validate each recipient
  for cc-recipient in cc {
    // Validate item is a string or content block
    if type(cc-recipient) not in (str, content) {
      panic("cc recipient '" + str(cc-recipient) + "' must be a string or content block.")
    }
  }

  // Validate optional label
  if cc-label != "cc:" {
    // Validate label field type
    if type(cc-label) not in (str, content) {
      panic("cc-label '" + str(cc-label) + "' must be a string or content block.")
    }

    // Validate label field is not empty
    if cc-label in ("", []) {
      panic("cc-label is empty.")
    }
  }
}

/// Validates enclosure list format (optional).
/// Each enclosure must be a dictionary with:
/// - description (required): string or content
/// - file (optional): bytes — file content loaded via read("path", encoding: none)
/// - margin (optional): length or dictionary with keys top, bottom, left, right, x, y, or rest
/// - pages (optional): integer — number of pages to embed, e.g. 5 renders pages 1-5
#let validate-enclosures(enclosures: none, enclosures-label: none) = {
  if enclosures in (none, (), "", []) {
    panic("enclosures are empty.")
  }

  if type(enclosures) != array {
    enclosures = (enclosures,)
  }

  for enclosure in enclosures {
    // Validate enclosure is a dictionary
    if type(enclosure) != dictionary {
      panic("enclosure must be a dictionary with a description field.")
    }

    // Validate required description field
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

    // Validate optional file field
    if "file" in enclosure {
      let file = enclosure.at("file")
      if type(file) != bytes {
        panic("enclosure file must be bytes loaded via read(\"path\", encoding: none).")
      }
    }

    // Validate optional pages field
    if "pages" in enclosure {
      let pages = enclosure.at("pages")
      if type(pages) != int or pages < 1 {
        panic("enclosure pages '" + str(pages) + "' must be a positive integer.")
      }
    }

    // Validate optional margin field
    if "margin" in enclosure {
      let margin = enclosure.at("margin")
      if type(margin) == length {
        // valid: single length applies to all sides
      } else if type(margin) == dictionary {
        let valid-keys = ("top", "bottom", "left", "right", "x", "y", "rest")
        for (key, value) in margin {
          if key not in valid-keys {
            panic("enclosure margin key '" + key + "' is not valid. Must be one of top, bottom, left, right, x, y, or rest.")
          }
          if type(value) != length {
            panic("enclosure margin value for '" + key + "' must be a length.")
          }
        }
      } else {
        panic("enclosure margin must be a length or a dictionary of lengths.")
      }
    }
  }

  if enclosures-label != "encl:" {
    if type(enclosures-label) not in (str, content) {
      panic("enclosure label '" + str(enclosures-label) + "' must be a string or content block.")
    }
    if enclosures-label in ("", []) {
      panic("enclosure label is empty.")
    }
  }
}

/// Validates footer structure with text and optional type (optional).
#let validate-footer(footer: none) = {
  if footer not in (none, ()) {
    // Handle the case where only one footer item is given
    if type(footer) != array {
      footer = (footer,)
    }

    // Validate each footer element
    for footer-elem in footer {
      // Validate footer element is a dictionary
      if type(footer-elem) != dictionary {
        panic("footer element '" + str(footer-elem) + "' must be a dictionary.")
      }

      // Validate presence of footer-text field
      if "footer-text" not in footer-elem {
        panic("footer-text is missing.")
      }

      let footer-text = footer-elem.at("footer-text")
      // Validate footer-text field type
      if type(footer-text) not in (str, content) {
        panic("footer-text '" + str(footer-text) + "' must be a string or content block.")
      }

      // Validate optional footer-type
      if "footer-type" in footer-elem {
        let footer-type = footer-elem.at("footer-type")
        // Validate footer-type field is valid
        if footer-type not in ("url", "email", "string") {
          panic("footer-type '" + str(footer-type) + "' must be one of url, email or string.")
        }
      }
    }
  }
}

/// Validates the letterhead dictionary (optional).
///
/// When provided, letterhead must be a dictionary with a required file key
/// (bytes from read("path", encoding: none)) and optional keys width, height,
/// margin, and alignment.
#let validate-letterhead(letterhead: none) = {
  if letterhead == none { return }

  if type(letterhead) != dictionary {
    panic("letterhead must be a dictionary with a required file key.")
  }

  if "file" not in letterhead {
    panic("letterhead is missing the required file key.")
  }

  if type(letterhead.file) != bytes {
    panic("letterhead.file must be bytes loaded via read(path, encoding: none).")
  }

  if "width" in letterhead {
    if type(letterhead.width) not in (length, ratio, relative) {
      panic("letterhead.width must be a length or percentage (e.g. 50% or 50% + 5mm).")
    }
  }

  if "height" in letterhead {
    if type(letterhead.height) != length {
      panic("letterhead.height must be a length.")
    }
  }

  if "margin" in letterhead {
    let m = letterhead.margin
    if type(m) == length {
      // valid: uniform margin
    } else if type(m) == dictionary {
      let valid-keys = ("top", "bottom", "left", "right", "x", "y", "rest")
      for (key, value) in m {
        if key not in valid-keys {
          panic("letterhead.margin key '" + key + "' is not valid. Must be one of top, bottom, left, right, x, y, or rest.")
        }
        if type(value) != length {
          panic("letterhead.margin value for '" + key + "' must be a length.")
        }
      }
    } else {
      panic("letterhead.margin must be a length or a dictionary of lengths.")
    }
  }

  if "alignment" in letterhead {
    if letterhead.alignment not in (left, center, right) {
      panic("letterhead.alignment must be left, center, or right.")
    }
  }
}

/// Validates the required-fields configuration array.
#let validate-required-fields(required-fields: none) = {
  let valid = (
    "from-name", "from-address", "to-name", "to-address",
    "date", "salutation", "subject", "closing", "signatures",
  )

  if type(required-fields) != array {
    panic("required-fields must be an array of field names.")
  }

  for field in required-fields {
    if type(field) != str {
      panic("required-fields entry '" + str(field) + "' must be a string.")
    }
    if field not in valid {
      panic("'" + field + "' is not a valid required field name.")
    }
  }
}

/// Main validation function that orchestrates all validations for the letterloom function.
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
  // =============================================================================
  // VALIDATE REQUIRED-FIELDS CONFIGURATION
  // =============================================================================

  validate-required-fields(required-fields: required-fields)

  // =============================================================================
  // VALIDATE CONFIGURABLE REQUIRED FIELDS
  // =============================================================================

  validate-string(string-data: from-name, field-name: "from-name", required: "from-name" in required-fields)
  validate-string(string-data: from-address, field-name: "from-address", required: "from-address" in required-fields)
  validate-string(string-data: to-name, field-name: "to-name", required: "to-name" in required-fields)
  validate-string(string-data: to-address, field-name: "to-address", required: "to-address" in required-fields)
  validate-string(string-data: date, field-name: "date", required: "date" in required-fields)
  validate-string(string-data: salutation, field-name: "salutation", required: "salutation" in required-fields)
  validate-string(string-data: subject, field-name: "subject", required: "subject" in required-fields)
  validate-string(string-data: closing, field-name: "closing", required: "closing" in required-fields)

  if "signatures" in required-fields {
    validate-signatures(signatures: signatures)
  } else if signatures != none {
    validate-signatures(signatures: signatures)
  }

  // =============================================================================
  // VALIDATE FORMATTING PARAMETERS
  // =============================================================================

  validate-length(length-value: main-font-size, field-name: "main-font-size")
  validate-length(length-value: footer-font-size, field-name: "footer-font-size")
  validate-length(length-value: footnote-font-size, field-name: "footnote-font-size")
  validate-length(length-value: par-leading, field-name: "par-leading")
  validate-length(length-value: par-spacing, field-name: "par-spacing")

  // =============================================================================
  // VALIDATE OPTIONAL FIELDS
  // =============================================================================

  // Validate attention name, label and position
  if attn-name != none {
    validate-attn(attn-name: attn-name, attn-label: attn-label, attn-position: attn-position)
  }

  // Validate cc
  if cc != none {
    validate-cc(cc: cc, cc-label: cc-label)
  }

  // Validate enclosures
  if enclosures != none {
    validate-enclosures(enclosures: enclosures, enclosures-label: enclosures-label)
  }

  // Validate letterhead
  validate-letterhead(letterhead: letterhead)

  // Validate footer
  if footer != none {
    validate-footer(footer: footer)
  }

  // =============================================================================
  // VALIDATE CONDITIONAL FIELDS
  // =============================================================================

  // Validate number-pages
  if number-pages != false {
    validate-boolean(boolean-data: number-pages, field-name: "number-pages", required: false)
  }

  // =============================================================================
  // VALIDATE TYPST-SPECIFIC TYPES
  // =============================================================================

  // Validate from-alignment
  if type(from-alignment) != alignment {
    panic("from-alignment must be a valid alignment type.")
  }

  // Validate date-alignment
  if type(date-alignment) != alignment {
    panic("date-alignment must be a valid alignment type.")
  }

  // Validate footnote-alignment
  if type(footnote-alignment) != alignment {
    panic("footnote-alignment must be a valid alignment type.")
  }

  // Validate signature-alignment
  if type(signature-alignment) != alignment {
    panic("signature-alignment must be a valid alignment type.")
  }

  // Validate link-color
  if type(link-color) != color {
    panic("link-color must be a valid color type.")
  }
}
