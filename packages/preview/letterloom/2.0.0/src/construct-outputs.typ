/// Output Construction Module
///
/// This module provides layout and construction functions for various
/// letter components including signatures, cc recipients, enclosures,
/// custom footers, and page numbering. It handles the visual presentation
/// and formatting of these elements according to the letterloom specification.

/// Constructs a signature grid layout for one or more signatories.
///
/// Signatures are arranged in rows of up to three columns. When more than one
/// signature is provided, `signature-alignment` is ignored and all signatures
/// are left-aligned. A blank placeholder is inserted into any unused grid cell
/// so that column widths remain consistent across rows.
///
/// Each signature dictionary must contain:
/// - `name` (str or content, required): The signatory's display name.
/// - `title` (str or content, optional): The signatory's title or role.
/// - `affiliation` (str or content, optional): The signatory's affiliation.
/// - `signature` (content, optional): Signature image, typically an `image`.
///   When omitted, a blank space of fixed height is reserved for a
///   physical signature.
///
/// - signatures (array): One or more signature dictionaries. A single
///   dictionary is accepted and normalized to a one-element array internally.
/// - signature-alignment (alignment): Horizontal alignment of each signature
///   block. Applies only when a single signature is given.
/// -> content
#let construct-signatures(signatures: none, signature-alignment: left) = {
  // Set the number of signatures per row to 3 to handle 3 or more signatures
  let sigs-per-row = 3

  // Blank placeholder for empty grid cells when there are fewer than sigs-per-row
  let blank-space = none

  // Normalize to array when a single signature is given
  if type(signatures) != array {
    signatures = (signatures, )
  }

  // In cases where we have less than 3 signatures,
  // we set the number of signatures per row to the number of signatures given
  if signatures.len() < 3 {
    sigs-per-row = signatures.len()
  }

  if signatures.len() > 1 {
    signature-alignment = left
  }

  // Construct the signature table
  grid(
    columns: 1,
    rows: auto,
    row-gutter: 10pt,
    align: left,
    // Construct the signature inner grid
    ..signatures.chunks(sigs-per-row).map(sigs => {
      grid(
        columns: (1fr, ) * sigs-per-row,
        align: signature-alignment,
        rows: 2,
        row-gutter: 10pt,
        column-gutter: 40pt,
        // Signature images row
        ..sigs.map(signatory =>
          signatory.at(
            "signature", default: rect(height: 40pt, stroke: none)
            )
          ) + (blank-space, ) * (sigs-per-row - sigs.len()),
        // Names, affiliation row
        ..sigs.map(signatory => {
            let title = signatory.at("title", default: none)
            let affiliation = signatory.at("affiliation", default: none)
            if title != none or affiliation != none {
              let items = (signatory.name,)
              if title != none { items.push(title) }
              if affiliation != none { items.push(affiliation) }
              stack(spacing: 10pt, ..items)
            } else {
              signatory.name
            }
          }) + (blank-space, ) * (sigs-per-row - sigs.len()),
      )
    })
  )
}

/// Constructs a labelled list of carbon copy recipients.
///
/// A single recipient (str or content) is accepted and normalized to a
/// one-element array internally. When exactly one recipient is given, it is
/// rendered as an undecorated list item. When multiple recipients are given,
/// they are rendered as an enumerated list. Passing `none` suppresses the
/// section entirely.
///
/// - cc (none, str, content, or array): One or more cc recipients.
/// - cc-label (str or content): Label displayed before the recipient list.
/// -> content
#let construct-cc(cc: none, cc-label: "cc:") = {
  if cc != none {
    set enum(indent: 15pt)

    // Display the label
    cc-label

    if type(cc) != array {
      cc = (cc, )
    }

    if cc.len() == 1 {
      set list(indent: 15pt, marker: "")
      list.item(text(cc.first()))
    } else {
      // Display each recipient as an enumerated item
      for cc-recipient in cc {
        enum.item(text(cc-recipient))
      }
    }
  }
}

/// Constructs a labelled list of enclosures and embeds attached files.
///
/// The enclosure list is rendered first, followed by each file attachment on
/// its own page. A single enclosure dictionary is accepted and normalized to a
/// one-element array internally. When exactly one enclosure is given, it is
/// rendered as an undecorated list item. When multiple enclosures are given,
/// they are rendered as an enumerated list. Passing `none` suppresses the
/// section entirely.
///
/// Each enclosure dictionary must contain:
/// - `description` (str or content, required): Label shown in the enclosure
///   list.
/// - `file` (bytes, optional): File content loaded via
///   `read("path", encoding: none)`. When present, the file is rendered on a
///   dedicated page after the letter body.
/// - `pages` (int, optional): Number of pages to render starting from page 1.
///   Defaults to `1`.
/// - `margin` (length or dictionary, optional): Page margin for the embedded
///   file. Defaults to `0mm` on all sides when omitted.
///
/// - enclosures (none or array): One or more enclosure dictionaries.
/// - enclosures-label (str or content): Label displayed before the enclosure
///   list.
/// -> content
#let construct-enclosures(enclosures: none, enclosures-label: "encl:") = {
  if enclosures != none {
    set enum(indent: 15pt)

    // Display the label
    enclosures-label

    // Normalize a bare dictionary to a one-element array
    if type(enclosures) != array {
      enclosures = (enclosures, )
    }

    // Single enclosure: undecorated list item; multiple: enumerated list
    if enclosures.len() == 1 {
      set list(indent: 15pt, marker: "")
      list.item(text(enclosures.first().description))
    } else {
      for enclosure in enclosures {
        enum.item(text(enclosure.description))
      }
    }

    // Render each attached file on its own page
    for enclosure in enclosures {
      let file = enclosure.at("file", default: none)
      if file != none {
        let raw-margin = enclosure.at("margin", default: 0mm)
        // Expand shorthand keys so every side is explicit — prevents unspecified
        // sides from inheriting the outer letter page margins
        let margin = if type(raw-margin) == dictionary {
          let fallback = raw-margin.at("rest", default: 0mm)
          (
            top: raw-margin.at("top", default: raw-margin.at("y", default: fallback)),
            bottom: raw-margin.at("bottom", default: raw-margin.at("y", default: fallback)),
            left: raw-margin.at("left", default: raw-margin.at("x", default: fallback)),
            right: raw-margin.at("right", default: raw-margin.at("x", default: fallback)),
          )
        } else { raw-margin }
        let page-count = enclosure.at("pages", default: 1)
        {
          set page(margin: margin)
          for i in range(1, page-count + 1) {
            image(file, page: i, width: 100%)
            if i < page-count { pagebreak() }
          }
        }
      }
    }
  }
}


/// Constructs a centred footer grid with styled URL and email hyperlinks.
///
/// Each footer element is rendered in a single-row grid with equal column
/// widths separated by a fixed gutter. URL and email entries are rendered as
/// clickable hyperlinks in `link-color`; all other entries are rendered as
/// plain text. Passing `none` or an empty array returns an empty grid
/// placeholder so that the footer area remains consistent.
///
/// Each footer element dictionary must contain:
/// - `footer-text` (str or content, required): The text to display.
/// - `footer-type` (str, optional): One of `"url"`, `"email"`, or
///   `"string"`. URL and email values are wrapped in a `link`. Defaults to
///   `"string"`.
///
/// - footer (none or array): One or more footer element dictionaries. A single
///   dictionary is accepted and normalized to a one-element array internally.
/// - footer-font (str): Font family applied to all footer text.
/// - footer-font-size (length): Font size applied to all footer text.
/// - link-color (color): Fill color applied to hyperlinked footer entries.
/// -> content
#let construct-custom-footer(
  footer: none,
  footer-font: "DejaVu Sans Mono",
  footer-font-size: 9pt,
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

/// Constructs a page number display shown from the second page onwards.
///
/// When `number-pages` is `true`, the current page number is rendered using
/// the default Arabic numeral style on every page after the first. When
/// `number-pages` is `false`, an empty grid placeholder is returned so that
/// the footer layout remains consistent regardless of whether numbering is
/// enabled.
///
/// - number-pages (bool): When `true`, page numbers are displayed from the
///   second page onwards.
/// -> content
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
