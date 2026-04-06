#let value(en: none, de: none) = {
  context {
    if text.lang == "en" {
      return en
    }

    if text.lang == "de" {
      return de
    }

    return "unknown"
  }
}

#let translations = (
  hm: value(
    de: "Hochschule München",
    en: "Munich University of Applied Sciences",
  ),
  for-the-degree-of: value(
    de: "zur Erlangung des akademischen Grades",
    en: "presented for the degree of",
  ),
  student-id: value(
    de: "Matrikelnummer",
    en: "Student ID",
  ),
  study-program: value(
    de: "Studiengang",
    en: "Study program"
  ),
  examiners: value(
    de: "Prüfer",
    en: "Examiners"
  ),
  abbreviations: value(
    de: "Abkürzungsverzeichnis",
    en: "Abbreviations",
  ),
  list-of-figures: value(
    de: "Abbildungsverzeichnis",
    en: "List of Figures",
  ),
  list-of-listings: value(
    de: "Listings",
    en: "List of Listings",
  ),
  list-of-tables: value(
    de: "Tabellenverzeichnis",
    en: "List of Tables",
  ),
  born: value(
    de: "geb.",
    en: "born",
  ),
  draft: value(
    de: "ENTWURF",
    en: "DRAFT"
  ),
  as-of: value(
    de: "Stand",
    en: "As of"
  ),
  place-time: value(
    de: "München, den",
    en: "Munich,"
  ),
  title: value(
    de: "Titel",
    en: "Title"
  ),
  bibliography: value(
    de: "Literaturverzeichnis",
    en: "Bibliography"
  ),
  chapter: value(
    de: "Kapitel",
    en: "Chapter"
  ),
  appendix: value(
    de: "Anhang",
    en: "Appendix"
  )
)

#let author-translation(gender: none) = value(
  de: if gender == "m" {
    "Autor"
  } else if gender == "w" {
    "Autorin"
  } else {
    "Verfassende Person"
  },
  en: "Author"
)

#let examiner-translation(gender: none) = value(
  de: if gender == "m" {
    "Prüfer"
  } else if gender == "w" {
    "Prüferin"
  } else {
    "Prüfende Person"
  },
  en: "Examiner",
)

#let declaration-of-independent-writing-translation(thesis-type: none) = value(
  de: [
    Hiermit erkläre ich, dass ich die #thesis-type selbständig verfasst, noch nicht anderweitig für Prüfungszwecke vorgelegt, keine anderen als die angegebenen Quellen oder Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate als solche gekennzeichnet habe.
  ],
  en: [
    I hereby declare that I have written this #thesis-type independently, have not submitted it elsewhere for examination purposes, have used no sources or aids other than those stated, and have marked all direct and paraphrased quotations as such.
  ]
)

#let blocking-notice(thesis-type: none, gender: none) = value(
  de: [
    #let author = if gender == "w" [der Verfasserin] else if gender == "m" [des Verfassers] else [des Verfassenden]

    Die vorliegende #thesis-type beinhaltet vertrauliche Informationen und darf durch Dritte, mit Ausnahme der Gutachter und berechtigten Beteiligten im Prüfungsverfahren, ohne ausdrückliche schriftliche Zustimmung #author nicht eingesehen werden.
    
    Insbesondere ist eine Vervielfältigung, weitere Verwendung und eine Veröffentlichung der #thesis-type ohne ausdrückliche schriftliche Genehmigung #author, auch auszugsweise, untersagt.
  ],
  en: [
    The present #thesis-type contains confidential information and may not be accessed by third parties, with the exception of the examiners and authorized participants in the examination process, without the express written consent of the author.
    
    In particular, any reproduction, further use, or publication of the #thesis-type, in whole or in part, is prohibited without the express written permission of the author.
  ]
)