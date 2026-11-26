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
  subject: (
    de: "Fach",
    en: "Subject"
  ),
  project-documentation: (
    de: "Projektdokumentation",
    en: "Project documentation"
  ),
  seminar: (
    de: "Hauptseminar",
    en: "Graduate Seminar in"
  )
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

  t.declaration-of-independent-writing = (thesis-type: none, ai-used: false) => {
    if lang == "de" {
      if ai-used {
        [
          Hiermit versichere ich, dass ich die vorliegende #thesis-type eigenständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet habe. Alle übernommenen Inhalte sowie mit Unterstützung von KI generierten Inhalte wurden entsprechend den anerkannten wissenschaftlichen Grundsätzen oder entsprechend der Regelungen zur Kennzeichnung von KI-Inhalten kenntlich gemacht. Ausgenommen von der Kenntlichmachung sind orthografische oder grammatikalische Korrekturen, Übersetzungen sowie nicht-sinnverändernde Verbesserungen von Formulierungen. Ich bin mir bewusst, dass mit KI generierte Texte keine Garantie für die Qualität von Inhalten und Text bieten. Daher erkläre ich, dass ich KI-Werkzeuge lediglich als Hilfsmittel genutzt habe, die von KI generierten Inhalte kritisch überprüft habe und mein eigenständiger kognitiver sowie kreativer Einfluss in dieser Arbeit überwiegt. Ich versichere, dass ich die Inhalte meiner Arbeit vollständig verstanden habe und selbstständig vertreten kann. Ich versichere, dass ich ausschließlich KI-Werkzeuge verwendet habe, deren Nutzung vom Prüfer oder der Prüferin als Hilfsmittel zugelassen wurden.
        ]
      } else {
        [
          Hiermit erkläre ich, dass ich die #thesis-type selbständig verfasst, noch nicht anderweitig für Prüfungszwecke vorgelegt, keine anderen als die angegebenen Quellen oder Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate als solche gekennzeichnet habe.
        ]
      }
    } else {
      if ai-used {
        [
          I hereby certify that I have written this #thesis-type independently and have not used any sources or resources other than those cited. All content that has been incorporated, as well as content generated with the assistance of AI, has been identified in accordance with recognized academic principles or in accordance with the regulations governing the identification of AI-generated content. Excluded from this identification requirement are spelling or grammatical corrections, translations, and improvements to phrasing that do not alter the meaning. I am aware that AI-generated texts offer no guarantee of the quality of content and text. Therefore, I declare that I have used AI tools solely as aids, that I have critically reviewed the AI-generated content, and that my independent cognitive and creative influence predominates in this work. I affirm that I have fully understood the content of my work and can defend it independently. I affirm that I have used only AI tools whose use has been approved by the examiner as aids.
        ]
      } else {
        [
          I hereby declare that I have written this #thesis-type independently, have not submitted it elsewhere for examination purposes, have used no sources or aids other than those stated, and have marked all direct and paraphrased quotations as such.
        ]
      }
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
