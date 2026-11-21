#let i18n = (
  en: (
    date: "Date",
    eval: "Evaluation",
    exam: "Exam",
    exercises: "Exercises",
    fig: "Fig.",
    ho: "handed out by",
    item: "Item",
    lab: "Lab",
    lc: "version of",
    mark: "Mark",
    of: "of",
    on: "on",
    page: "Page",
    poi: "Points",
    sol: "solution",
    subtask: "subtask",
    tab: "Tab.",
    task: "Task",
    with: "with",
    regards: "Best regards,",
    chap: "Chapter",
    appendix: "Appendix",
    abstract: "Abstract",
    toc: "Contents",
    lof: "List of Figures",
    lot: "List of Tables",
    lol: "Listings",
    thanks: "Acknowledgements",
    solution: "Solution",
    solutions: "Solutions",
    solution-to: "Solution to",
    solution-on: "Solution on",
    summer-term: "Summer term",
    winter-term: "Winter term",
    lecture-notes: "Lecture notes for the course",
    workbook: "Exercises for the course",
    name: "Name",
    student-id: "Student ID",
    student-id-short: "Student ID",
    points-short: "pts.",
    hints: "Notes",
    exam-hints: (count, time, points) => [
      - The exam consists of *#count* #if count == 1 [task] else [tasks], the working time is *#time*.
      - A total of *#points* #if points == 1 [point] else [points] can be achieved.
      - Permitted aids:
        - *One handwritten* A4 sheet, which must be *handed in* at the end of the exam.
      - *Not permitted* aids:
        - Any other documents
        - Electronic devices
      - Write *legibly* and show your *solution steps* in full.
      - Do *not* write in pencil or in red ink.
    ],
    // thesis
    bachelor-thesis: "Bachelor’s Thesis",
    master-thesis: "Master’s Thesis",
    assessor: "Assessor",
    supervisor: "Supervisor",
    co-supervisor: "Co-supervisor",
    lfui-faculty-logo: [Faculty of\ Engineering Science],
    umit-department: [Department for Biomedical Informatics and Mechatronics],
    thesis-joint: (program) => [
      written as part of a joint #if program == "Bachelor" [Bachelor's] else [Master's]
      degree programme of LFUI and UMIT TIROL -- Joint Degree Programme
    ],
    thesis-submitted: (university) => [
      submitted to #if university == "LFUI" [
        the University of Innsbruck, Faculty of Engineering Sciences,
      ] else [
        UMIT TIROL – Private University for Health Sciences and Health Technology,
        Department for Biomedical Informatics and Mechatronics,
      ]
      in partial fulfilment of the requirements for the academic degree of
    ],
    declaration-title: [Statutory Declaration],
    declaration: [
      I hereby declare in lieu of an oath, by my own signature, that I have
      written the present thesis independently and have not used any sources
      or aids other than those indicated. All passages taken literally or in
      substance from the indicated sources have been marked as such.

      The present thesis has not been submitted in the same or a similar form
      as an academic thesis before.
    ],
    signed-at: (city) => [#city,],
  ),
  de: (
    date: "Datum",
    eval: "Bewertung",
    exam: "Klausur",
    exercises: "Übungsaufgaben",
    fig: "Abb.",
    ho: "ausgegeben von",
    item: "Element",
    lab: "Labor",
    lc: "in der Fassung vom",
    mark: "Note",
    of: "von",
    on: "am",
    page: "Seite",
    poi: "Punkte",
    sol: "Lösung",
    subtask: "Aufgabe",
    tab: "Tab.",
    task: "Aufgabe",
    with: "mit",
    regards: "Mit freundlichen Grüßen",
    chap: "Kapitel",
    appendix: "Anhang",
    abstract: "Abstract",
    toc: "Inhaltsverzeichnis",
    lof: "Abbildungsverzeichnis",
    lot: "Tabellenverzeichnis",
    lol: "Quellcodeverzeichnis",
    thanks: "Danksagung",
    solution: "Lösung",
    solutions: "Lösungen",
    solution-to: "Lösung zu",
    solution-on: "Lösung auf",
    summer-term: "Sommersemester",
    winter-term: "Wintersemester",
    lecture-notes: "Skriptum zur Lehrveranstaltung",
    workbook: "Übungsaufgaben zur Lehrveranstaltung",
    name: "Name",
    student-id: "Matrikelnummer",
    student-id-short: "Matrikelnr",
    points-short: "P.",
    hints: "Hinweise",
    exam-hints: (count, time, points) => [
      - Die Prüfung umfasst *#count* #if count == 1 [Aufgabe] else [Aufgaben], die Bearbeitungszeit beträgt *#time*.
      - Es #if points == 1 [kann] else [können] insgesamt *#points* #if points == 1 [Punkt] else [Punkte] erreicht werden.
      - Zugelassene Hilfsmittel:
        - *Ein handschriftlich* beschriebener A4 Zettel, am Ende der Klausur *abzugeben*.
      - *Nicht zugelassene* Hilfsmittel:
        - Jegliche Unterlagen
        - Elektronische Geräte
      - Schreiben Sie *leserlich* und geben Sie den *Lösungsweg* vollständig an.
      - Schreiben Sie *nicht* mit Bleistift und *nicht* mit Rotstift.
    ],
    // thesis
    bachelor-thesis: "Bachelorarbeit",
    master-thesis: "Masterarbeit",
    assessor: "Beurteiler",
    supervisor: "Betreuer",
    co-supervisor: "Mitbetreuer",
    lfui-faculty-logo: [Fakultät für Technische\ Wissenschaften],
    umit-department: [Department für Biomedizinische Informatik und Mechatronik],
    thesis-joint: (program) => [
      verfasst im Rahmen eines gemeinsamen #if program == "Bachelor" [
        Bachelorstudienprogramms
      ] else [
        Masterstudienprogramms
      ]
      von LFUI und UMIT TIROL -- Joint Degree Programme
    ],
    thesis-submitted: (university) => [
      eingereicht an der
      #if university == "LFUI" [
        Leopold-Franzens-Universität Innsbruck,
        Fakultät für Technische Wissenschaften
      ] else [
        UMIT TIROL – Privatuniversität für Gesundheitswissenschaften und -technologie,
        Department für Biomedizinische Informatik und Mechatronik
      ]
      zur Erlangung
      des akademischen Grades
    ],
    declaration-title: [Verpflichtungs- und\ Einverständniserklärung],
    declaration: [
      Ich erkläre hiermit an Eides statt durch meine eigenhändige Unterschrift,
      dass ich die vorliegende Arbeit selbständig verfasst und keine anderen als
      die angegebenen Quellen und Hilfsmittel verwendet habe. Alle Stellen, die
      wörtlich oder inhaltlich den angegebenen Quellen entnommen wurden, sind
      als solche kenntlich gemacht.

      Die vorliegende Arbeit wurde bisher in gleicher oder ähnlicher Form noch
      nicht als wissenschaftliche Arbeit eingereicht.
    ],
    signed-at: (city) => [#city am],
  )
)

// Institutes for the option 'institute': name per language, the white logo in
// the assets folder and optionally
// - scale: of the logo, if it appears larger or smaller than the others at the
//   same height
// - dy: vertical shift of the logo, relative to its height (positive: down),
//   if it sits higher or lower than the others
// scale and dy are a single value for all places of the logo, or a dictionary
// per place (see institute-places) with `rest` for the places not given.
// A further institute only needs a further entry here.
// Places of the institute logo
#let institute-places = (
  "header", // header of exam, exercise, report, workbook
  "slides-header", // header of the slides
  "title-slide", // title slide of the slides
  "title-page", // title page of lecture and workbook
)

#let institutes = (
  iace: (
    name: (
      de: "Institut für Automatisierungs- und Regelungstechnik",
      en: "Institute of Automation and Control Engineering",
    ),
    logo: "logo_iace_white.svg",
  ),
  ims: (
    name: (
      de: "Institut für Mess- und Sensortechnik",
      en: "Institute of Measurement and Sensor Technology",
    ),
    logo: "logo_ims_white.svg",
    scale: 85%,
    dy: (slides-header: 20%, title-slide: 30%, rest: -5%), // positive: down
  ),
)

// Supported values of the thesis options 'program' and 'university'
#let thesis-programs = ("Bachelor", "Master")
#let universities = ("LFUI", "UMIT")

#let months = (
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
