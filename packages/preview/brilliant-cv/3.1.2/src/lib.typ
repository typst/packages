/*
* Entry point for the package
*/

/* Packages */
#import "./cv.typ": *
#import "./letter.typ": *
#import "./utils/lang.typ": *
#import "./utils/styles.typ": *

/* Layout */
#let cv(
  metadata,
  doc,
  // New parameter names (recommended)
  profile-photo: image("../template/assets/avatar.png"),
  // Old parameter names (deprecated, for backward compatibility)
  profilePhoto: image("../template/assets/avatar.png"),
) = {
  // Backward compatibility logic (remove this block when deprecating)
  let profile-photo = if profile-photo != image("../template/assets/avatar.png") { 
    profile-photo 
  } else { 
    // TODO: Add deprecation warning in future version
    profilePhoto 
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
    fonts.insert(2, nonLatinFont)
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

  _cv-header(metadata, profile-photo, header-font, _regular-colors, _awesome-colors)
  doc
}

#let letter(
  metadata,
  doc,
  // New parameter names (recommended)
  sender-address: "Your Address Here",
  recipient-name: "Company Name Here", 
  recipient-address: "Company Address Here",
  // Old parameter names (deprecated, for backward compatibility)
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
) = {
  // Backward compatibility logic (remove this block when deprecating)
  let sender-address = if sender-address != "Your Address Here" { sender-address } else { myAddress }
  let recipient-name = if recipient-name != "Company Name Here" { recipient-name } else { recipientName }
  let recipient-address = if recipient-address != "Company Address Here" { recipient-address } else { recipientAddress }
  // Non Latin Logic
  let lang = metadata.language
  let fonts = _latin-font-list
  let font-config = overwrite-fonts(metadata, _latin-font-list, _latin-header-font)
  fonts = font-config.regular-fonts
  if _is-non-latin(lang) {
    let non-latin-font = metadata.lang.non_latin.font
    fonts.insert(2, non-latin-font)
  }

  // Page layout
  set text(font: fonts, weight: "regular", size: 9pt, fill: _regular-colors.lightgray)
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
    )
  doc

  if signature != "" {
    _letter-signature(signature)
  }
}
