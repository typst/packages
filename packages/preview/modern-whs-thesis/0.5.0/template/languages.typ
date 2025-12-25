#let de = (
  tableOfContents: "Inhaltsverzeichnis",
  listOfFigures: "Abbildungsverzeichnis",
  listOfTables: "Tabellenverzeichnis",
  listOfCode: "Quelltextverzeichnis",
  bibliography: "Literaturverzeichnis",
  abbreviations: "Abkürzungsverzeichnis",
  section: "Abschnitt",
  affidavit: "Eidesstattliche Versicherung",
  titleOfThesis: "Titel der Arbeit // Title of Thesis",
  degree: "Akademischer Abschlussgrad: Grad, Fachrichtung (Abkürzung) // Degree",
  namePlaceOfBirth: "Autorenname, Geburtsort // Name, Place of Birth",
  courseOfStudy: "Studiengang // Course of Study",
  department: "Fachbereich // Department",
  firstExaminer: "Erstprüferin/Erstprüfer // First Examiner",
  secondExaminer: "Zweitprüferin/Zweitprüfer // Second Examiner",
  dateOfSubmission: "Abgabedatum // Date of Submission",
  nameFirstName: "Name, Vorname // Name, First Name",
  affidavitText: "Ich versichere hiermit an Eides statt, dass ich die vorliegende Abschlussarbeit mit dem Titel",
  affidavitDeclaration: "selbstständig und ohne unzulässige fremde Hilfe erbracht habe. Ich habe keine anderen als die angegebenen Quellen und Hilfsmittel benutzt sowie wörtliche und sinngemäße Zitate kenntlich gemacht. Die Arbeit hat in gleicher oder ähnlicher Form noch keine Prüfungsbehörde vorgelegen. Die als \"pdf\" eingereichte elektronische Form ist inhaltlich identisch mit der gebundenen Ausfertigung.",
  placeDateSignature: "Ort, Datum, Unterschrift // Place, Date, Signature",
)

#let en = (
  tableOfContents: "Table of Contents",
  listOfFigures: "List of Figures",
  listOfTables: "List of Tables",
  listOfCode: "List of Code",
  bibliography: "References",
  abbreviations: "List of Abbreviations",
  section: "Section",
  affidavit: "Affidavit",
  titleOfThesis: "Title of Thesis",
  degree: "Degree",
  namePlaceOfBirth: "Name, Place of Birth",
  courseOfStudy: "Course of Study",
  department: "Department",
  firstExaminer: "First Examiner",
  secondExaminer: "Second Examiner",
  dateOfSubmission: "Date of Submission",
  nameFirstName: "Name, First Name",
  affidavitText: "I hereby declare under oath that I have completed the present thesis with the title",
  affidavitDeclaration: "independently and without unauthorized external help. I have not used any sources or aids other than those indicated and have marked both literal and analogous quotations. The work has not been submitted to any examination authority in the same or similar form. The electronic version submitted as \"pdf\" is identical in content to the bound version.",
  placeDateSignature: "Place, Date, Signature",
)

#let getText(key, lang) = {
  if (lang == "en") {
    en.at(key)
  } else {
    de.at(key)
  }
}
