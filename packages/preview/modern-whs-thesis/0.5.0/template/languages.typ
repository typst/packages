#let de = (
  table-of-contents: "Inhaltsverzeichnis",
  list-of-figures: "Abbildungsverzeichnis",
  list-of-tables: "Tabellenverzeichnis",
  list-of-code: "Quelltextverzeichnis",
  bibliography: "Literaturverzeichnis",
  abbreviations: "Abkürzungsverzeichnis",
  section: "Abschnitt",
  affidavit: "Eidesstattliche Versicherung",
  title-of-thesis: "Titel der Arbeit // Title of Thesis",
  degree: "Akademischer Abschlussgrad: Grad, Fachrichtung (Abkürzung) // Degree",
  name-place-of-birth: "Autorenname, Geburtsort // Name, Place of Birth",
  course-of-study: "Studiengang // Course of Study",
  department: "Fachbereich // Department",
  first-examiner: "Erstprüferin/Erstprüfer // First Examiner",
  second-examiner: "Zweitprüferin/Zweitprüfer // Second Examiner",
  date-of-submission: "Abgabedatum // Date of Submission",
  name-first-name: "Name, Vorname // Name, First Name",
  affidavit-text: "Ich versichere hiermit an Eides statt, dass ich die vorliegende Abschlussarbeit mit dem Titel",
  affidavit-declaration: "selbstständig und ohne unzulässige fremde Hilfe erbracht habe. Ich habe keine anderen als die angegebenen Quellen und Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate kenntlich gemacht. Die Arbeit hat in gleicher oder ähnlicher Form noch keine Prüfungsbehörde vorgelegen. Die als \"pdf\" eingereichte elektronische Form ist inhaltlich identisch mit der gebundenen Ausfertigung.",
  place-date-signature: "Ort, Datum, Unterschrift // Place, Date, Signature",
)

#let en = (
  table-of-contents: "Table of Contents",
  list-of-figures: "List of Figures",
  list-of-tables: "List of Tables",
  list-of-code: "List of Code",
  bibliography: "References",
  abbreviations: "List of Abbreviations",
  section: "Section",
  affidavit: "Affidavit",
  title-of-thesis: "Title of Thesis",
  degree: "Degree",
  name-place-of-birth: "Name, Place of Birth",
  course-of-study: "Course of Study",
  department: "Department",
  first-examiner: "First Examiner",
  second-examiner: "Second Examiner",
  date-of-submission: "Date of Submission",
  name-first-name: "Name, First Name",
  affidavit-text: "I hereby declare under oath that I have completed the present thesis with the title",
  affidavit-declaration: "independently and without unauthorized external help. I have not used any sources or aids other than those indicated and have marked both literal and analogous quotations. The work has not been submitted to any examination authority in the same or similar form. The electronic version submitted as \"pdf\" is identical in content to the bound version.",
  place-date-signature: "Place, Date, Signature",
)

#let get-text(key, lang) = {
  if (lang == "en") {
    en.at(key)
  } else {
    de.at(key)
  }
}
