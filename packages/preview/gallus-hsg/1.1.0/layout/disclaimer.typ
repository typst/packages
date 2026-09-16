#let disclaimer(
  title: "",
  author: "",
  language: "en",
  submission-date: datetime,
) = {
  set page(
    margin: (left: 30mm, right: 30mm, top: 40mm, bottom: 40mm),
    numbering: none,
    number-align: center,
  )

  let body-font = "New Computer Modern"
  let sans-font = "New Computer Modern Sans"

  set text(
    font: body-font, 
    size: 10pt, 
    lang: "en"
  )

  set par(leading: 1em)

  
  // --- Disclaimer --- 
  v(10%)
  let title = (en: "Declaration of Authorship", de: "Eigenständigkeitserklärung")
  heading(title.at(language), numbering: none)
  let disclaimer = (
    en: [
«I  hereby declare,
- that I have written this thesis independently,
- that I have written the thesis using only the aids specified in the index;
- that all parts of the thesis produced with the help of aids have been declared;
- that I have handled both input and output responsibly when using AI. I confirm that I have therefore only read in public data or data released with consent and that I have checked, declared and comprehensibly referenced all results and/or other forms of AI assistance in the required form and that I am aware that I am responsible if incorrect content, violations of data protection law, copyright law or scientific misconduct (e.g. plagiarism) have also occurred unintentionally;
- that I have mentioned all sources used and cited them correctly according to established academic citation rules;
- that I have acquired all immaterial rights to any materials I may have used, such as images or graphics, or that these materials were created by me;
- that the topic, the thesis or parts of it have not already been the object of any work or examination of another course, unless this has been expressly agreed with the faculty member in advance and is stated as such in the thesis;
- that I am aware of the legal provisions regarding the publication and dissemination of parts or the entire thesis and that I comply with them accordingly;
- that I am aware that my thesis can be electronically checked for plagiarism and for third-party authorship of human or technical origin and that I hereby grant the University of St. Gallen the copyright according to the Examination Regulations as far as it is necessary for the administrative actions;
- that I am aware that the University will prosecute a violation of this Declaration of Authorship and that disciplinary as well as criminal consequences may result, which may lead to expulsion from the University or to the withdrawal of my title.»

By submitting this thesis, I confirm through my conclusive action that I am submitting the Declaration of Authorship, that I have read and understood it, and that it is true. 
    ], 
  de: [
«Ich erkläre hiermit,
- dass ich die vorliegende Arbeit eigenständig verfasst habe,
- dass ich die Arbeit nur unter Verwendung der im Verzeichnis angegebenen Hilfsmittel verfasst habe;
- dass alle mit Hilfsmitteln erbrachten Teile der Arbeit deklariert wurden;
- dass ich bei der Nutzung von KI verantwortungsvoll mit dem Input wie auch mit dem Output umgegangen bin. Ich bestätige, dass ich somit nur öffentliche oder per Einwilligung freigegebene Daten eingelesen und sämtliche Resultate und/oder andere Formen von KI-Hilfeleistungen in verlangter Form überprüft, deklariert und nachvollziehbar referenziert habe und ich mir bewusst bin, dass ich die Verantwortung trage, falls es auch unbeabsichtigt zu fehlerhaften Inhalten, zu Verstössen gegen das Datenschutzrecht, Urheberrecht oder zu wissenschaftlichem Fehlverhalten (z.B. Plagiate) gekommen ist;
- dass ich sämtliche verwendeten Quellen erwähnt und gemäss gängigen wissenschaftlichen Zitierregeln korrekt zitiert habe;
- dass ich sämtliche immateriellen Rechte an von mir allfällig verwendeten Materialien wie Bilder oder Grafiken erworben habe oder dass diese Materialien von mir selbst erstellt wurden;
- dass das Thema, die Arbeit oder Teile davon nicht bereits Gegenstand eines Leistungsnachweises einer anderen Veranstaltung oder Kurses waren, sofern dies nicht ausdrücklich mit der Referentin oder dem Referenten im Voraus vereinbart wurde und in der Arbeit ausgewiesen wird;
- dass ich mir über die rechtlichen Bestimmungen zur Publikation und Weitergabe von Teilen oder der ganzen Arbeit bewusst bin und ich diese entsprechend einhalte;
- dass ich mir bewusst bin, dass meine Arbeit elektronisch auf Plagiate und auf Drittautorschaft menschlichen oder technischen Ursprungs überprüft werden kann und ich hiermit der Universität St.Gallen laut Prüfungsordnung das Urheberrecht soweit einräume, wie es für die Verwaltungshandlungen notwendig ist;
- Dass ich mir bewusst bin, dass die Universität einen Verstoss gegen diese Eigenständigkeitserklärung verfolgt und dass daraus disziplinarische wie auch strafrechtliche Folgen resultieren können, welche zum Ausschluss von der Universität resp. zur Titelaberkennung führen können.»

Mit Einreichung der schriftlichen Arbeit stimme ich mit konkludentem Handeln zu, die Eigenständigkeitserklärung abzugeben, diese gelesen sowie verstanden zu haben und, dass sie der Wahrheit entspricht.
  ])
  text(disclaimer.at(language))

  v(15mm)
  grid(
      columns: 2,
      gutter: 1fr,
      "St. Gallen, " + submission-date.display("[day]/[month]/[year]"), author
  )
}
