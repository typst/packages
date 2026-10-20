// template/main.typ — Beispiel-Dokument für das HWR Berlin Typst Template
// Ersetze alle Beispieldaten durch deine eigenen Angaben.
//
// Alle Formatierung erfolgt automatisch. Du arbeitest nur in dieser Datei
// und in deinen Kapiteldateien unter kapitel/.
//
// WICHTIG: Der #show:-Block muss der erste Aufruf in dieser Datei sein.
// Schreibe keinen Text und kein zweites #show: davor — sonst wird
// die Formatierung nicht korrekt angewendet.

// Für Nutzer (nach typst init @preview/easy-wi-hwr:0.1.2):
#import "@preview/easy-wi-hwr:0.1.2": hwr, abk, gls, glspl
// Für lokale Entwicklung:
// #import "../lib.typ": hwr, abk, gls, glspl

#show: hwr.with(
  // === PFLICHTFELDER ===
  doc-type: "ptb-1",
  // Erlaubte Werte: "ptb-1" | "ptb-2" | "ptb-3" |
  //                "hausarbeit" | "studienarbeit" | "bachelorarbeit"

  title: "Digitale Transformation im Mittelstand: Chancen und Herausforderungen",

  // Einzelperson — einfachste Variante (top-level Felder):
  name:     "Max Mustermann",
  matrikel: "12345678",
  // Mit digitaler Unterschrift (optional):
  // signature: image("images/signature_example.svg"),

  // Alternativ als dict (gleicher Effekt):
  // authors: (name: "Max Mustermann", matrikel: "12345678"),
  // authors: (name: "Max Mustermann", matrikel: "12345678", signature: image("images/signature_example.svg")),

  // Gruppenarbeit — Array (ersetzt name:/matrikel: hier drüber):
  // authors: (
  //   (name: "Max Mustermann",  matrikel: "12345678"),
  //   (name: "Lisa Müller",     matrikel: "87654321"),
  // ),

  // === BEDINGT PFLICHT ===
  // Für ptb-*/hausarbeit/studienarbeit:
  supervisor: "Prof. Dr. Anna Muster",
  company:    "Muster GmbH",

  // Für bachelorarbeit (auskommentieren wenn nicht benötigt):
  // first-examiner:  "Prof. Dr. Anna Muster",
  // second-examiner: "Prof. Dr. Ben Beispiel",

  // === OPTIONALE FELDER ===
  lang: "de",                          // "de" (default) | "en"
  field-of-study: "Wirtschaftsinformatik",
  cohort:   "2024",                    // Studienjahrgang
  semester: "3",                       // Studienhalbjahr

  date: auto,                          // auto = heutiges Datum | "15. März 2026" = manuell

  // === GESTALTUNG ===
  // style: "compliant",               // "compliant" (default) = HWR-konform
                                       // "pretty" = dekoratives Deckblatt + Logo-Header
                                       // ⚠ "pretty" ist NICHT in den Richtlinien — mit Betreuer/in absprechen!
  // Granulare Overrides (haben Vorrang vor style: wenn gesetzt):
  // school-logo: image("images/hwr-logo.png"),    // Logo links im Seitenkopf
  // company-logo: image("images/firma-logo.png"), // Logo rechts im Seitenkopf
  // pretty-title: true,               // dekoratives Deckblatt mit Zierlinien und großem Titel

  // Abstract (optional — auskommentieren wenn nicht benötigt):
  abstract: [
    Diese Arbeit untersucht die digitale Transformation im deutschen Mittelstand.
    Im Fokus stehen die zentralen Herausforderungen bei der Einführung von
    ERP-Systemen sowie die Erfolgsfaktoren für eine nachhaltige Digitalisierungsstrategie.
  ],

  // Sperrvermerk (auskommentieren wenn nicht benötigt):
  // confidential: none,                            // kein Sperrvermerk (default)
  // confidential: true,                            // gesamte Arbeit gesperrt
  // confidential: (                                // bestimmte Kapitel gesperrt:
  //   chapters: (
  //     (number: "3", title: "Methodik"),
  //     (number: "4", title: "Ergebnisse"),
  //   ),
  //   filename: "PTB_Mustermann_public.pdf",       // optional
  // ),

  // Abkürzungen (werden nur angezeigt wenn im Text mit #abk() verwendet):
  abbreviations: (
    "HWR":  "Hochschule für Wirtschaft und Recht Berlin",
    "KI":   "Künstliche Intelligenz",
    "ERP":  "Enterprise Resource Planning",
    "API":  "Application Programming Interface",
    "PTB":  "Praxistransferbericht",
  ),

  // Glossar (für erklärungsbedürftige Fachbegriffe ohne eigene Abkürzung):
  //
  // Im Text verwenden (in kapitel/*.typ):
  //   #gls("stakeholder")    → gibt "Stakeholder" aus + Glossar-Link
  //   #glspl("stakeholder")  → Pluralform
  //
  // Das Glossar erscheint automatisch nach dem Haupttext (vor dem Literaturverzeichnis).
  glossary: (
    (key: "stakeholder", short: "Stakeholder", long: "Stakeholder",
     description: "Interessengruppen, die direkt oder indirekt von einem Projekt betroffen sind."),
    // Weitere Einträge nach Bedarf:
    // (key: "scrum", short: "Scrum", long: "Scrum",
    //  description: "Agiles Rahmenwerk für die iterative Produktentwicklung in kurzen Zyklen (Sprints)."),
  ),

  // KI-Verzeichnis (Pflicht wenn KI-Tools verwendet, §3.8):
  // Prompts müssen gesichert und mit der Arbeit eingereicht werden.
  // Verweis auf das Prompt-Protokoll im Anhang (Nummer muss zur Reihenfolge passen).
  // ai-tools: (),                                  // leer = kein KI-Verzeichnis (default)
  ai-tools: (
    (
      tool:        "ChatGPT 4o",
      usage:       "Textvorschläge für Einleitung, im Text gekennzeichnet",
      chapters:    "Kapitel 1, S. 3",
      remarks:     "Prompts: ",
      remarks-ref: "Prompt-Protokoll",   // → Hyperlink auf den Anhang mit diesem Titel
    ),
    (
      tool:     "DeepL Translator",
      usage:    "Übersetzung englischer Quellabschnitte",
      chapters: "Gesamte Arbeit",
    ),
  ),

  // Kapitel in der gewünschten Reihenfolge:
  // include() wird hier (in main.typ) aufgerufen, daher sind Pfade relativ zu main.typ.
  // Jedes Kapitel beginnt automatisch auf einer neuen Seite.
  chapters: (
    include("kapitel/01_einleitung.typ"),
    include("kapitel/02_grundlagen.typ"),
    include("kapitel/03_methodik.typ"),
    include("kapitel/04_ergebnisse.typ"),
    include("kapitel/05_fazit.typ"),
  ),

  // Anhang (optional — auskommentieren wenn nicht benötigt):
  appendix: (
    (title: "Interviewleitfaden",     content: include("anhang/a_interviewleitfaden.typ")),
    (title: "Rohdaten Umfrage",       content: include("anhang/b_rohdaten.typ")),
    (title: "Screenshot Dashboard",   content: include("anhang/c_abbildung.typ")),
    (title: "Prompt-Protokoll",       content: include("anhang/d_prompt_protokoll.typ")),
    (title: "Interview-Transkript",   content: include("anhang/e_interview_transkript.typ")),
    (title: "Code-Listing",           content: include("anhang/f_code_listing.typ")),
    (title: "Mermaid-Diagramm",       content: include("anhang/g_mermaid_diagramm.typ")),
  ),

  // Bibliographie:
  // Der Titel wird automatisch gesetzt (DE: "Literaturverzeichnis", EN: "References").
  bibliography: bibliography("refs.bib"),
  citation-style: "auto",
  // Zitierstile: "auto" (default, folgt der Sprache: DE → APA, EN → Harvard)
  //             | "apa" | "harvard-anglia-ruskin-university" (EN, §6)
  // Eigene CSL-Datei: citation-style: read("mein-stil.csl")
  //   → read() wird hier in main.typ aufgelöst, daher Pfad relativ zu main.typ

  // Weitere Einstellungen:
  heading-depth: 4,         // TOC-Tiefe: 1–4 (default: 4)
  declaration-lang: auto,   // auto = folgt lang | "de" = immer Deutsch (rechtssicher)
  city: "Berlin",           // Ort für Unterschriftsfeld (default: "Berlin")
  show-appendix-toc: false, // true = optionales Anhangsverzeichnis vor Anhang-Einträgen einfügen
                            // (HWR §3.10: "ist es möglich" — nicht Pflicht)
  // warnings: true,        // false = gelbe Hinweisboxen im PDF unterdrücken
                            // (z.B. Pretty-Mode-Hinweis, nach Absprache mit Prüfer)
  // group-signature: auto, // auto/true = alle Autoren unterschreiben (default)
                            // false = nur erster Autor unterschreibt (bei Gruppenarbeit)
                            // HINWEIS bei false: Bitte mit dem Prüfer abklären, ob eine
                            // stellvertretende Unterschrift akzeptiert wird.
)

// HINWEIS: Deine Kapitel werden über die chapters:-Liste oben eingebunden.
// Jedes Kapitel startet dort automatisch auf einer neuen Seite.
//
// ALTERNATIVE: Du kannst auch alles direkt hier schreiben, ohne separate
// Kapitel-Dateien. Dafür chapters: () leer lassen (oder die Zeile löschen)
// und deinen Text einfach hier drunter schreiben.
// Zwischen Kapiteln #pagebreak() einfügen, damit jedes auf einer neuen Seite beginnt:
//
//   = Einleitung
//   Hier beginnt mein erster Absatz...
//
//   #pagebreak()
//   = Grundlagen
//   Weiterer Text...
