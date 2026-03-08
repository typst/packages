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


/// Validates contact information structure (name and address).
#let validate-contact(contact: none, field-name: none) = {
  // Validate presence
  if contact in (none, ()) {
    panic(str(field-name) + " is missing.")
  }

  // Validate dictionary type
  if type(contact) != dictionary {
    panic(str(field-name) + " details must be a dictionary with name and address fields.")
  }

  // Validate presence of name field
  if "name" not in contact {
    panic(str(field-name) + " name is missing.")
  }

  let name = contact.at("name")
  // Validate name field type
  if type(name) not in (str, content) {
    panic(str(field-name) + " name must be a string or content block.")
  }

  // Validate name field is not empty
  if name in ("", []) {
    panic(str(field-name) + " name is empty.")
  }

  // Validate presence of address field
  if "address" not in contact {
    panic(str(field-name) + " address is missing.")
  }

  let address = contact.at("address")
  // Validate address field type
  if type(address) != content {
    panic(str(field-name) + " address must be a content block.")
  }

  // Validate address field is not empty
  if address == [] {
    panic(str(field-name) + " address is empty.")
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
    signatures = (signatures, )
  }

  // Validate each signature
  for signature in signatures {
    // Validate signature is a dictionary
    if type(signature) != dictionary {
      panic("signature '" + str(signature) + "' must be a dictionary with a name field and an optional signature field.")
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

/// Validates cc list format (optional).
#let validate-cc(cc: none) = {
  if cc not in (none, ()) {
    // Validate dictionary type
    if type(cc) != dictionary {
      panic("cc must be a dictionary.")
    }

    // Validate cc-list field
    if "cc-list" not in cc {
      panic("cc dictionary must have a cc-list field.")
    }

    let cc-list = cc.at("cc-list")
    // Handle the case where only one cc recipient is given
    if type(cc-list) != array {
      cc-list = (cc-list, )
    }

    // Validate cc-list field is not empty
    if cc-list in (none, ()) {
      panic("cc-list is empty.")
    }

    // Validate each recipient
    for cc-recipient in cc-list {
      // Validate item is a string or content block
      if type(cc-recipient) not in (str, content) {
        panic(str("cc recipient '" + str(cc-recipient)) + "' must be a string or content block.")
      }
    }

    // Validate optional label
    if "label" in cc {
      let label = cc.at("label")
      // Validate label field type
      if type(label) not in (str, content) {
        panic("cc label '" + str(label) + "' must be a string or content block.")
      }

      // Validate label field is not empty
      if label in ("", []) {
        panic("cc label is empty.")
      }
    }
  }
}

/// Validates enclosure list format (optional).
#let validate-enclosures(enclosures: none) = {
  if enclosures not in (none, ()) {
    // Validate dictionary type
    if type(enclosures) != dictionary {
      panic("enclosures must be a dictionary with an encl-list field.")
    }

    // Validate encl-list field
    if "encl-list" not in enclosures {
      panic("enclosures dictionary must have an encl-list field.")
    }

    let encl-list = enclosures.at("encl-list")
    // Handle the case where only one enclosure item is given
    if type(encl-list) != array {
      encl-list = (encl-list, )
    }

    // Validate encl-list field is not empty
    if encl-list in (none, ()) {
      panic("enclosure encl-list field is empty.")
    }

    // Validate each item
    for encl-item in encl-list {
      // Validate item is a string or content block
      if type(encl-item) not in (str, content) {
        panic("enclosure '" + str(encl-item) + "' must be a string or content block.")
      }

      // Validate item is not empty
      if encl-item in ("", []) {
        panic("empty enclosure item found.")
      }
    }

    // Validate optional label
    if "label" in enclosures {
      let label = enclosures.at("label")
      // Validate label field type
      if type(label) not in (str, content) {
        panic("enclosure label '" + str(label) + "' must be a string or content block.")
      }

      // Validate label field is not empty
      if label in ("", []) {
        panic("enclosure label is empty.")
      }
    }
  }
}

/// Validates footer structure with text and optional type (optional).
#let validate-footer(footer: none) = {
  if footer not in (none, ()) {
    // Handle the case where only one footer item is given
    if type(footer) != array {
      footer = (footer, )
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

/// Validates attention line format (optional).
#let validate-attn-line(attn-line: none) = {
  if attn-line not in (none, ()) {
    // Validate dictionary type
    if type(attn-line) != dictionary {
      panic("attn-line must be a dictionary.")
    }

    // Validate required name field
    if "name" not in attn-line {
      panic("attn-line dictionary must have a name field.")
    }

    let name = attn-line.at("name")
    // Validate name field type
    if type(name) not in (str, content) {
      panic("attn-line name must be a string or content block.")
    }

    // Validate name field is not empty
    if name in ("", []) {
      panic("attn-line name is empty.")
    }

    // Validate optional label
    if "label" in attn-line {
      let label = attn-line.at("label")

      // Validate label field type
      if type(label) not in (str, content) {
        panic("attn-line label must be a string or content block.")
      }

      // Validate label field is not empty
      if label in ("", []) {
        panic("attn-line label is empty.")
      }
    }

    // Validate optional position
    if "position" in attn-line {
      let position = attn-line.at("position")

      // Validate position field is valid
      if position not in ("above", "below") {
        panic("attn-line position must be one of above or below.")
      }
    }
  }
}


/// Main validation function that orchestrates all validations for the letterloom function.
#let validate-inputs(
    from: none,
    to: none,
    date: none,
    salutation: none,
    subject: none,
    closing: none,
    signatures: none,
    attn-line: none,
    cc: none,
    enclosures: none,
    footer: none,
    par-leading: 0.8em,
    par-spacing: 1.8em,
    number-pages: false,
    main-font-size: 11pt,
    footer-font-size: 9pt,
    footnote-font-size: 7pt,
    from-alignment: right,
    footnote-alignment: left,
    link-color: blue,
  ) = {
  // =============================================================================
  // VALIDATE REQUIRED FIELDS
  // =============================================================================

  validate-contact(contact: from, field-name: "from")
  validate-contact(contact: to, field-name: "to")
  validate-string(string-data: date, field-name: "date")
  validate-string(string-data: salutation, field-name: "salutation")
  validate-string(string-data: subject, field-name: "subject")
  validate-string(string-data: closing, field-name: "closing")
  validate-signatures(signatures: signatures)

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

  if attn-line != none {
    validate-attn-line(attn-line: attn-line)
  }

  if cc != none {
    validate-cc(cc: cc)
  }

  if enclosures != none {
    validate-enclosures(enclosures: enclosures)
  }

  if footer != none {
    validate-footer(footer: footer)
  }

  // =============================================================================
  // VALIDATE CONDITIONAL FIELDS
  // =============================================================================

  if number-pages != false {
    validate-boolean(boolean-data: number-pages, field-name: "number-pages", required: false)
  }

  // =============================================================================
  // VALIDATE TYPST-SPECIFIC TYPES
  // =============================================================================

  if type(from-alignment) != alignment {
    panic("from-alignment must be a valid alignment type.")
  }

  if type(footnote-alignment) != alignment {
    panic("footnote-alignment must be a valid alignment type.")
  }

  if type(link-color) != color {
    panic("link-color must be a valid color type.")
  }
}
