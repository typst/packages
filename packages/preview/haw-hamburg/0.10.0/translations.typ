#let value(en: "", de: "") = {
  context {
    if text.lang == "en" {
      return en
    }

    if text.lang == "de" {
      return de
    }

    return "Unknown language"
  }
}

#let month-names-de = (
  "Januar",
  "Februar",
  "März",
  "April",
  "Mai",
  "Juni",
  "Juli",
  "August",
  "September",
  "Oktober",
  "November",
  "Dezember",
)

#let translations = (
  submission-date-format: date => value(
    en: date.display("[month repr:long] [day], [year]"),
    de: date.display("[day]. ") + month-names-de.at(date.month() - 1) + date.display(" [year]"),
  ),
  bachelor-thesis: value(
    en: "Bachelor thesis",
    de: "Bachelorarbeit",
  ),
  master-thesis: value(
    en: "Master thesis",
    de: "Masterarbeit",
  ),
  expose: value(
    en: "Proposal",
    de: "Exposé",
  ),
  keywords: value(
    en: "Keywords",
    de: "Stichworte",
  ),
  faculty-of: value(
    en: "Faculty of",
    de: "Fakultät",
  ),
  bachelor-thesis-submitted-for-examination-in-bachelors-degree: value(
    en: "Bachelor thesis submitted for examination in Bachelor's degree",
    de: "Bachelorarbeit eingereicht im Rahmen der Bachelorprüfung",
  ),
  master-thesis-submitted-for-examination-in-masters-degree: value(
    en: "Master thesis submitted for examination in Master's degree",
    de: "Masterarbeit eingereicht im Rahmen der Masterprüfung",
  ),
  in-the-study-course: value(
    en: "in the study course",
    de: "im Studiengang",
  ),
  at-the-faculty-of: value(
    en: "at the Faculty of",
    de: "der Fakultät",
  ),
  at-university-of-applied-science-hamburg: value(
    en: "at University of Applied Science Hamburg",
    de: "der Hochschule für Angewandte Wissenschaften Hamburg",
  ),
  supervising-examiner: value(
    en: "Supervising examiner",
    de: "Betreuender Prüfer",
  ),
  second-examiner: value(
    en: "Second examiner",
    de: "Zweitgutachter",
  ),
  submitted-on: value(
    en: "Submitted on",
    de: "Eingereicht am",
  ),
  list-of-figures: value(
    en: "List of Figures",
    de: "Abbildungsverzeichnis",
  ),
  list-of-tables: value(
    en: "List of Tables",
    de: "Tabellenverzeichnis",
  ),
  listings: value(
    en: "Listings",
    de: "Listings",
  ),
  declaration-of-independent-processing: value(
    en: "Declaration of Independent Processing",
    de: "Erklärung zur selbstständigen Bearbeitung",
  ),
  declaration-of-independent-processing-content: value(
    en: "I hereby declare that I have written this work independently in all its parts and have used no sources or aids other than those stated in the work. I have declared the AI-based tools used in my work (including product names where applicable).

I accept full responsibility for the use of any machine-generated passages included by me, and I bear responsibility for any erroneous or distorted content, incorrect references, breaches of data protection or copyright law, or plagiarism produced by the AI.

I am aware that untruthful statements may be treated as an attempt at deception.",
    de: "Hiermit versichere ich, dass ich die vorliegende Arbeit in allen Teilen selbstständig angefertigt und keine anderen als die in der Arbeit angegebenen Quellen und Hilfsmittel
benutzt habe. Die in meiner Arbeit verwendeten KI-basierten Hilfsmittel habe ich (ggf.
mit Produktnamen) angegeben.

Ich verantworte die Übernahme jeglicher von mir verwendeter maschinell generierter
Passagen vollumfänglich selbst und trage die Verantwortung für eventuell durch die KI
generierte fehlerhafte oder verzerrte Inhalte, fehlerhafte Referenzen, Verstöße gegen das
Datenschutz- und Urheberrecht oder Plagiate.

Mir ist bewusst, dass wahrheitswidrige Angaben als Täuschungsversuch behandelt werden können.",
  ),
  place: value(
    en: "Place",
    de: "Ort",
  ),
  date: value(
    en: "Date",
    de: "Datum",
  ),
  signature: value(
    en: "Original Signature",
    de: "Unterschrift im Original",
  ),
)
