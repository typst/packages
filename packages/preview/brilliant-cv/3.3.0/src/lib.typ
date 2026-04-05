/*
* Entry point for the package
*/

/* Packages */
#import "./cv.typ": *
#import "./letter.typ": *
#import "./utils/lang.typ": *
#import "./utils/styles.typ": *

/* Layout */

/// Render a CV document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the CV (typically the imported modules).
/// - profile-photo (image): The profile photo to display in the header. Pass `none` to hide.
/// - custom-icons (dictionary): Custom icons to override or extend the default icon set.
/// -> content
#let cv(
  metadata,
  doc,
  profile-photo: image("../template/assets/avatar.png"),
  custom-icons: (:),
  // Deprecated parameter (will be removed in v4.0)
  profilePhoto: none,
) = {
  if profilePhoto != none {
    panic("'profilePhoto' has been renamed and will be removed in v4.0. Use 'profile-photo' instead.")
  }

  // Update metadata state
  cv-metadata.update(metadata)

  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let header-font = _latin-header-font

  let font-config = overwrite-fonts(metadata, _latin-font-list, _latin-header-font)
  fonts = font-config.regular-fonts
  header-font = font-config.header-font
  
  if _is-non-latin(lang) {
    let nonLatinFont = metadata.lang.non_latin.font
    fonts.insert(calc.min(2, fonts.len()), nonLatinFont)
    header-font = nonLatinFont
  }

  let font_size = eval(
    metadata.layout.at("font_size", default: "9pt")
  )
  // Page layout
  set text(font: fonts, weight: "regular", size: font_size, fill: _regular-colors.lightgray)
  set align(left)
  let paper_size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: {paper_size},
    margin: {
      if paper_size == "us-letter" {
        (left: 2cm, right: 1.4cm, top: 1.2cm, bottom: 1.2cm)
        } else {
        (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
      }
    },
    footer: context _cv-footer(metadata),
  )

  _cv-header(metadata, profile-photo, header-font, _regular-colors, _awesome-colors, custom-icons)
  doc
}

/// Render a cover letter document with header, footer, and page layout applied.
///
/// - metadata (dictionary): The metadata dictionary read from `metadata.toml`.
/// - doc (content): The body content of the letter.
/// - sender-address (str | auto): The sender's mailing address. Defaults to `auto`, which reads from `metadata.personal.address` (falls back to `"Your Address Here"` if unset). Pass a string or content to override.
/// - recipient-name (str): The recipient's name or company displayed in the header.
/// - recipient-address (str): The recipient's mailing address displayed in the header. Supports multiline content.
/// - date (str): The date displayed in the letter header. Defaults to today's date.
/// - subject (str): The subject line of the letter.
/// - signature (str | content): (optional) path to a signature image, or content to display as signature.
/// - address-style (str): Address rendering style. `"smallcaps"` (default) or `"normal"`.
/// -> content
#let letter(
  metadata,
  doc,
  sender-address: auto,
  recipient-name: "Company Name Here",
  recipient-address: "Company Address Here",
  // Deprecated parameters (will be removed in v4.0)
  myAddress: none,
  recipientName: none,
  recipientAddress: none,
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
  address-style: "smallcaps",
) = {
  if myAddress != none {
    panic("'myAddress' has been renamed and will be removed in v4.0. Use 'sender-address' instead.")
  }
  if recipientName != none {
    panic("'recipientName' has been renamed and will be removed in v4.0. Use 'recipient-name' instead.")
  }
  if recipientAddress != none {
    panic("'recipientAddress' has been renamed and will be removed in v4.0. Use 'recipient-address' instead.")
  }

  // Resolve sender-address: auto reads from metadata, explicit value overrides
  let sender-address = if sender-address == auto {
    metadata.personal.at("address", default: "Your Address Here")
  } else {
    sender-address
  }

  // Backward compatibility: panic if old inject fields are detected
  if metadata.inject.at("inject_ai_prompt", default: none) != none {
    panic("'inject_ai_prompt' has been removed and will be fully deprecated in v4.0. Use 'custom_ai_prompt_text' in [inject] instead.")
  }
  if metadata.inject.at("inject_keywords", default: none) != none {
    panic("'inject_keywords' has been removed and will be fully deprecated in v4.0. Use 'injected_keywords_list' directly instead — if the list is present, keywords will be injected. To disable injection, remove 'injected_keywords_list'.")
  }

  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let header-font = _latin-header-font
  let font-config = overwrite-fonts(metadata, _latin-font-list, _latin-header-font)
  fonts = font-config.regular-fonts
  header-font = font-config.header-font
  if _is-non-latin(lang) {
    let non-latin-font = metadata.lang.non_latin.font
    fonts.insert(calc.min(2, fonts.len()), non-latin-font)
    header-font = non-latin-font
  }

  // Font size from metadata (consistent with CV)
  let font-size = eval(
    metadata.layout.at("font_size", default: "9pt")
  )

  // Page layout
  set text(font: fonts, weight: "regular", size: font-size, fill: _regular-colors.lightgray)
  set align(left)
  let paper-size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: {paper-size},
    margin: {
      if paper-size == "us-letter" {
        (left: 2cm, right: 2cm, top: 1.2cm, bottom: 1.2cm)
        } else {
        (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
      }
    },
    footer: _letter-footer(metadata),
  )
  set text(size: 12pt)

  _letter-header(
      sender-address: sender-address,
      recipient-name: recipient-name,
      recipient-address: recipient-address,
      date: date,
      subject: subject,
      metadata: metadata,
      awesome-colors: _awesome-colors,
      address-style: address-style,
    )
  doc

  if signature != "" {
    _letter-signature(signature)
  }
}
