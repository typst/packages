/// Output Construction Module
///
/// This module provides layout and construction functions for various
/// letter components including signatures, cc recipients, enclosures,
/// custom footers, and page numbering. It handles the visual presentation
/// and formatting of these elements according to the letterloom specification.

/// Constructs a signature grid layout for one or more signatories.
#let construct-signatures(signatures: none) = {
  // Set the number of signatures per row and the blank space
  let sigs-per-row = 3
  let blank-space = none

  // Handle the case where only one signature is given
  if type(signatures) != array {
    signatures = (signatures, )
  }

  grid(
    columns: 1,
    rows: auto,
    row-gutter: 10pt,
    align: start + horizon,
    // Construct the signature inner grid
    ..signatures.chunks(sigs-per-row).map(sigs => {
      grid(
        columns: (1fr, ) * sigs-per-row,
        align: left,
        rows: 2,
        row-gutter: 10pt,
        column-gutter: 40pt,
        // Signature images row
        ..sigs.map(signatory =>
          signatory.at("signature", default: rect(height: 40pt, stroke: none))) +
          (blank-space, ) * (sigs-per-row - sigs.len()),
        // Names row
        ..sigs.map(signatory => signatory.name) +
          (blank-space, ) * (sigs-per-row - sigs.len()),
      )
    })
  )
}

/// Constructs an enumerated list of cc recipients (optional).
#let construct-cc(cc: none) = {
  if cc not in (none, ()) {
    set enum(indent: 15pt)

    // Display the label
    cc.at("label", default: "cc:")

    // Get and normalize the cc-list
    let cc-list = cc.at("cc-list")
    if type(cc-list) != array {
      cc-list = (cc-list, )
    }

    // Display each recipient as an enumerated item
    for cc-recipient in cc-list {
      enum.item(text(cc-recipient))
    }
  }
}

/// Constructs an enumerated list of enclosures (optional).
#let construct-enclosures(enclosures: none) = {
  if enclosures not in (none, ()) {
    set enum(indent: 15pt)

    // Display the label
    enclosures.at("label", default: "encl:")

    // Get and normalize the items
    let items = enclosures.at("encl-list")
    if type(items) != array {
      items = (items, )
    }

    // Display each item as an enumerated item
    for item in items {
      enum.item(text(item))
    }
  }
}


/// Constructs a custom footer grid with specific styling for urls and emails (optional).
#let construct-custom-footer(
  footer: none,
  footer-font: "DejaVu Sans Mono",
  footer-font-size: 7pt,
  link-color: blue
) = {
  if footer not in (none, ()) {
    // Handle the case where only one footer item is given
    if type(footer) != array {
      footer = (footer, )
    }

    // Construct the footer grid
    grid(
      columns: footer.len(),
      rows: 1,
      gutter: 20pt,
      ..footer.map(footer-item => {
        let footer-type = footer-item.at("footer-type", default: "string")
        let footer-text = footer-item.at("footer-text")

        if footer-type == "url" {
          // Construct the footer text for URLs
          text(
            link(footer-text),
            font: footer-font,
            size: footer-font-size,
            fill: link-color
          )
        } else if footer-type == "email" {
          // Construct the footer text for emails
          text(
            link("mailto:" + footer-text),
            font: footer-font,
            size: footer-font-size,
            fill: link-color
          )
        } else {
          // Default to string type
          text(footer-text, font: footer-font, size: footer-font-size)
        }
      })
    )
  } else {
    grid()
  }
}

/// Constructs page numbering display for multi-page letters (optional).
#let construct-page-numbering(number-pages: false) = {
  if number-pages {
    // Construct the page numbering grid
    grid(
      context(
        // Display the page number from the second page onwards
        if here().page() > 1 {
          counter(page).display("1")
        }
      )
    )
  } else {
    grid()
  }
}
