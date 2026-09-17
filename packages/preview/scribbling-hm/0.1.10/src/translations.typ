#let translations-data = (
  hm: (
    de: "Hochschule München",
    en: "Munich University of Applied Sciences",
  ),
  for-the-degree-of: (
    de: "zur Erlangung des akademischen Grades",
    en: "presented for the degree of",
  ),
  student-id: (
    de: "Matrikelnummer",
    en: "Student ID",
  ),
  study-program: (
    de: "Studiengang",
    en: "Study program",
  ),
  examiners: (
    de: "Prüfer",
    en: "Examiners",
  ),
  abbreviations: (
    de: "Abkürzungsverzeichnis",
    en: "Abbreviations",
  ),
  list-of-figures: (
    de: "Abbildungsverzeichnis",
    en: "List of Figures",
  ),
  list-of-listings: (
    de: "Listings",
    en: "List of Listings",
  ),
  list-of-tables: (
    de: "Tabellenverzeichnis",
    en: "List of Tables",
  ),
  born: (
    de: "geb.",
    en: "born",
  ),
  draft: (
    de: "ENTWURF",
    en: "DRAFT",
  ),
  as-of: (
    de: "Stand",
    en: "As of",
  ),
  place-time: (
    de: "München, den",
    en: "Munich,",
  ),
  title: (
    de: "Titel",
    en: "Title",
  ),
  bibliography: (
    de: "Literaturverzeichnis",
    en: "Bibliography",
  ),
  chapter: (
    de: "Kapitel",
    en: "Chapter",
  ),
  appendix: (
    de: "Anhang",
    en: "Appendix",
  ),
  submission-date: (
    de: "Abgabetermin",
    en: "Submission date",
  ),
)

#let create-translations(lang) = {
  let t = (:)
  for (k, v) in translations-data {
    t.insert(k, if lang == "de" { v.de } else { v.en })
  }

  t.author = (gender: none) => {
    if lang == "de" {
      if gender == "m" {
        "Autor"
      } else if gender == "w" {
        "Autorin"
      } else {
        "Verfassende Person"
      }
    } else {
      "Author"
    }
  }

  t.examiner = (gender: none) => {
    if lang == "de" {
      if gender == "m" {
        "Prüfer"
      } else if gender == "w" {
        "Prüferin"
      } else {
        "Prüfende Person"
      }
    } else {
      "Examiner"
    }
  }

  t.declaration-of-independent-writing = (thesis-type: none) => {
    if lang == "de" {
      [
        Hiermit erkläre ich, dass ich die #thesis-type selbständig verfasst, noch nicht anderweitig für Prüfungszwecke vorgelegt, keine anderen als die angegebenen Quellen oder Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate als solche gekennzeichnet habe.
      ]
    } else {
      [
        I hereby declare that I have written this #thesis-type independently, have not submitted it elsewhere for examination purposes, have used no sources or aids other than those stated, and have marked all direct and paraphrased quotations as such.
      ]
    }
  }

  t.blocking-notice = (thesis-type: none, gender: none) => {
    if lang == "de" {
      let author = if gender == "w" [der Verfasserin] else if gender == "m" [des Verfassers] else [des Verfassenden]
      [
        Die vorliegende #thesis-type beinhaltet vertrauliche Informationen und darf durch Dritte, mit Ausnahme der Gutachter und berechtigten Beteiligten im Prüfungsverfahren, ohne ausdrückliche schriftliche Zustimmung #author nicht eingesehen werden.

        Insbesondere ist eine Vervielfältigung, weitere Verwendung und eine Veröffentlichung der #thesis-type ohne ausdrückliche schriftliche Genehmigung #author, auch auszugsweise, untersagt.
      ]
    } else {
      [
        The present #thesis-type contains confidential information and may not be accessed by third parties, with the exception of the examiners and authorized participants in the examination process, without the express written consent of the author.

        In particular, any reproduction, further use, or publication of the #thesis-type, in whole or in part, is prohibited without the express written permission of the author.
      ]
    }
  }

  return t
}
