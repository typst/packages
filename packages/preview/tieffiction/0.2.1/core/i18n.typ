#import "@preview/tieflang:0.1.0": configure-translations
#import "isbn.typ": render-isbn
#import "@preview/ccicons:1.0.1": cc-url, ccicon

#let languages = (
  english-us: "en-us",
  english-uk: "en-uk",
  deutsch-de: "de-de",
  portuguese-br: "pt-br"
)

#let ordinal-en = number => {
  let mod10 = calc.rem(number, 10)
  let mod100 = calc.rem(number, 100)
  let suffix = if mod100 == 11 or mod100 == 12 or mod100 == 13 {
    "th"
  } else if mod10 == 1 {
    "st"
  } else if mod10 == 2 {
    "nd"
  } else if mod10 == 3 {
    "rd"
  } else {
    "th"
  }
  [#number#suffix]
}

#let ordinal-de = number => [#number.]

#let ordinal-br = number => [#number.]

#let copyright-line = (holder, year) => {
  if holder != none and year != none {
    [Copyright (c) #year #holder]
  } else if holder != none {
    [Copyright (c) #holder]
  } else if year != none {
    [Copyright (c) #year]
  } else {
    none
  }
}

#let i18n-en-us = (
  copyright-page: (holder, publisher, year, isbn, edition, license, extra) => (
    copyright-line(holder, year),
    if edition != none {
      [#ordinal-en(edition) edition]
    },
    if publisher != none and year != none {
      [Published #year, by #publisher.]
    } else if publisher != none {
      [Published by #publisher.]
    } else if year != none {
      [Published #year.]
    } else {
      none
    },
    [All rights reserved.],
    ..extra,
    ..if license != none {
      (
        v(20pt),
        [This work is licensed under a #link(cc-url(license + "/de/4.0"), [Creative Commons '#license' license]).\
          #ccicon(license + "-badge", scale: 3)],
        v(20pt),
      )
    },
    if isbn != none {
      [ISBN: #isbn\
        #render-isbn(isbn)]
    },
  ),
  chapter: chapter-number => [Chapter #chapter-number],
  table-of-content: [Table of Content],
  ordinal: ordinal-en,
)

#let i18n-en-uk = (
  copyright-page: (holder, publisher, year, isbn, edition, license, extra) => (
    copyright-line(holder, year),
    [The moral right of the author has been asserted.],
    if edition != none {
      [#ordinal-en(edition) edition]
    },
    if publisher != none and year != none {
      [Published #year, by #publisher.]
    } else if publisher != none {
      [Published by #publisher.]
    } else if year != none {
      [Published #year.]
    } else {
      none
    },
    [All rights reserved.],
    ..extra,
    ..if license != none {
      (
        v(20pt),
        [This work is licensed under a #link(cc-url(license), [Creative Commons '#license' license]).\
          #ccicon(license + "-badge", scale: 3)],
        v(20pt),
      )
    },
    if isbn != none {
      [ISBN: #isbn\
        #render-isbn(isbn)]
    },
  ),
  chapter: chapter-number => [Chapter #chapter-number],
  table-of-content: [Table of Content],
  ordinal: ordinal-en,
)

#let i18n-de-de = (
  copyright-page: (holder, publisher, year, isbn, edition, license, extra) => (
    copyright-line(holder, year),
    if edition != none {
      [#ordinal-de(edition) Auflage]
    },
    if publisher != none and year != none {
      [Herausgegeben von #publisher im Jahr #year.]
    } else if publisher != none {
      [Herausgegeben von #publisher.]
    } else if year != none {
      [Herausgegeben im Jahr #year.]
    } else {
      none
    },
    [Alle Rechte vorbehalten.],
    ..extra,
    ..if license != none {
      (
        v(20pt),
        [Dieses Werk wird unter einer #link(cc-url(license + "/de/4.0"), [Creative Commons '#license' Lizenz]) zur Verfügung gestellt.\
          #ccicon(license + "-badge", scale: 3)],
        v(20pt),
      )
    },
    if isbn != none {
      [ISBN: #isbn\
        #render-isbn(isbn)]
    },
  ),
  chapter: chapter-number => [Kapitel #chapter-number],
  table-of-content: [Inhaltsverzeichnis],
  ordinal: ordinal-de,
)

#let i18n-pt-br = (
  copyright-page: (holder, publisher, year, isbn, edition, license, extra) => (
    copyright-line(holder, year),
    if edition != none {
      [Edição #ordinal-br(edition)]
    },
    if publisher != none and year != none {
      [Publicado por #publisher em #year.]
    } else if publisher != none {
      [Publicado por #publisher.]
    } else if year != none {
      [Publicado em #year.]
    } else {
      none
    },
    [Todos os direitos reservados.],
    ..extra,
    ..if license != none {
      (
        v(20pt),
        [Esta obra é licenciada sob uma #link(cc-url(license), [licença Creative Commons '#license']).\
          #ccicon(license + "-badge", scale: 3)],
        v(20pt),
      )
    },
    if isbn != none {
      [ISBN: #isbn\
        #render-isbn(isbn)]
    },
  ),
  chapter: chapter-number => [Capítulo #chapter-number],
  table-of-content: [Sumário],
  ordinal: ordinal-br,
)

#let setup-i18n = () => configure-translations(
  (
    en-us: i18n-en-us,
    en-uk: i18n-en-uk,
    de-de: i18n-de-de,
    pt-br: i18n-pt-br,
  ),
  strict: true,
  default: "en-us",
)
