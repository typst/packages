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
  set page(
    paper: "a4",
    margin: (left: 1.4cm, right: 1.4cm, top: .8cm, bottom: .4cm),
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
  set page(
    paper: "a4",
    margin: (left: 1.4cm, right: 1.4cm, top: .8cm, bottom: .4cm),
    footer: letterHeader(
      myAddress: myAddress,
      recipientName: recipientName,
      recipientAddress: recipientAddress,
      date: date,
      subject: subject,
      metadata: metadata,
      awesomeColors: awesomeColors,
    ),
  )
  set text(size: 12pt)

  doc

  if signature != "" {
    letterSignature(signature)
  }
}
