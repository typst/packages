/*
 - SPDX-FileCopyrightText: 2025-2025 Malte Kumlehn
 - SPDX-License-Identifier: MIT
*/

#import "metadata.typ": tubs-logo, institute-logo, institute-name, institute-prof, author, phone-nr, fax-nr, email, website, institute-address-header, institute-name-en, to-address, date, subject

#import "@preview/simple-tubs-letter:0.1.1": tubs-letter

#show: tubs-letter.with(
  lang: "en",
  tubs-logo: tubs-logo,
  logo-dx: 2cm,
  logo-dy: -1cm,
  institute-logo: institute-logo,
  institute-name: institute-name,
  institute-name-en: institute-name-en,
  institute-prof: institute-prof,
  author: author,
  phone-nr: phone-nr,
  fax-nr: fax-nr,
  email: email,
  website: website,
  institute-address-header: institute-address-header,
  to-address: to-address,
  date: date,
  subject: subject,
)

To whom it may concern,
#v(1em)
#lorem(30)

#lorem(15)

#v(1em)

Sincerely

#author
