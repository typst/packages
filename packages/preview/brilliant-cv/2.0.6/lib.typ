/*
* Entry point for the package
*/

/* Packages */
#import "./cv.typ": *
#import "./letter.typ": *
#import "./utils/lang.typ": isNonLatin
#import "./utils/styles.typ": overwriteFonts

/* Layout */
#let cv(
  metadata,
  profilePhoto: image("./template/src/avatar.png"),
  doc,
) = {
  // Non Latin Logic
  let lang = metadata.language
  let fontList = latinFontList
  let headerFont = latinHeaderFont
  fontList = overwriteFonts(metadata, latinFontList, latinHeaderFont).regularFonts
  headerFont = overwriteFonts(metadata, latinFontList, latinHeaderFont).headerFont
  if isNonLatin(lang) {
    let nonLatinFont = metadata.lang.non_latin.font
    fontList.insert(2, nonLatinFont)
    headerFont = nonLatinFont
  }

  // Page layout
  set text(font: fontList, weight: "regular", size: 9pt)
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
    footer: _cvFooter(metadata),
  )

  _cvHeader(metadata, profilePhoto, headerFont, regularColors, awesomeColors)
  doc
}

#let letter(
  metadata,
  doc,
  myAddress: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: datetime.today().display(),
  subject: "Subject: Hey!",
  signature: "",
) = {
  // Non Latin Logic
  let lang = metadata.language
  let fontList = latinFontList
  fontList = overwriteFonts(metadata, latinFontList, latinHeaderFont).regularFonts
  if isNonLatin(lang) {
    let nonLatinFont = metadata.lang.non_latin.font
    fontList.insert(2, nonLatinFont)
  }

  // Page layout
  set text(font: fontList, weight: "regular", size: 9pt)
  set align(left)
  let paper_size = metadata.layout.at("paper_size", default: "a4")
  set page(
    paper: {paper_size},
    margin: {
      if paper_size == "us-letter" {
        (left: 2cm, right: 2cm, top: 1.2cm, bottom: 1.2cm)
        } else {
        (left: 1.4cm, right: 1.4cm, top: 1cm, bottom: 1cm)
      }
    },
    footer: _letterFooter(metadata),
  )
  set text(size: 12pt)

  _letterHeader(
      myAddress: myAddress,
      recipientName: recipientName,
      recipientAddress: recipientAddress,
      date: date,
      subject: subject,
      metadata: metadata,
      awesomeColors: awesomeColors,
    )
  doc

  if signature != "" {
    _letterSignature(signature)
  }
}
