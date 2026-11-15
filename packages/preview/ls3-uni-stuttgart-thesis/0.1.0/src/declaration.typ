// declaration.typ
//
// Selbständigkeitserklärung with AI-tools confirmation tables.
// Bilingual (DE/EN).

// Localized text blocks.
#let _texts(language) = {
  if language == "german" {
    (
      title: "Selbstständigkeitserklärung",
      paragraph-1: [
        Hiermit versichere ich, dass ich diese Arbeit selbstständig verfasst und keine
        anderen als die angegeben Hilfsmittel benutzt habe. Alle Stellen dieser Arbeit,
        die dem Wortlaut, dem Sinn oder der Argumentation nach anderen Werken entnommen
        sind, habe ich unter Angabe der Quellen vollständig kenntlich gemacht.
      ],
      paragraph-2: [
        Die Arbeit wurde in dieser oder ähnlicher Form keiner anderen Prüfungsbehörde
        als Prüfungsleistung vorgelegt.
      ],
      paragraph-3: [
        Die abgegebene elektronische Fassung ist identisch mit der gedruckten Fassung
        der Arbeit.
      ],
      ai-tools-header-1: "Verantwortungsvoller Umgang mit generativen KI-Tools (Large Language Models)",
      ai-tools-header-2: "Detaillierte Tätigkeiten, für die generative KI-Tools (Large Language Models) genutzt wurden",
      ai-statements-col: "Aussagen",
      ai-confirmation-col: "Bestätigung",
      ai-activity-col: "Aktivität",
      ai-description-col: "Beschreibung",
      date-label: "Datum",
      signature-label: "Unterschrift",
    )
  } else {
    (
      title: "Author declaration",
      paragraph-1: [
        I declare that I have developed and written the enclosed thesis completely by
        myself and that I have not used sources or means without declaration in the
        text. Any thoughts from others or literal quotations are clearly marked.
      ],
      paragraph-2: [
        The thesis was not used in the same or in a similar version to achieve an
        academic grading or is being published elsewhere.
      ],
      paragraph-3: [
        The enclosed electronic version is identical to the printed versions.
      ],
      ai-tools-header-1: "Responsible use of AI Tools (Large Language Models)",
      ai-tools-header-2: "Detailed activities for which generative AI tools (Large Language Models) were used",
      ai-statements-col: "Statements",
      ai-confirmation-col: "Confirmation",
      ai-activity-col: "Activity",
      ai-description-col: "Description",
      date-label: "Date",
      signature-label: "Signature",
    )
  }
}

// Render an empty or filled checkbox.
#let _box(marked) = if marked { $checkmark$ } else { $square$ }

// Statement and activity row contents per language.
#let _statements(language) = {
  if language == "german" {
    (
      informed: "Ich bin mir über die Möglichkeiten und Grenzen der von mir verwendeten generativen KI-Tools informiert.",
      verified: "Ich habe mich vergewissert, dass die von den generativen KI-Tools gelieferten Ergebnisse korrekt sind, oder dass ich sie korrigiert habe.",
      responsible: "Ich erkenne an, dass die Verantwortung für die Arbeit bei dem/der Autor:in liegt, nicht bei den generativen KI-Tools oder einer anderen Person.",
    )
  } else {
    (
      informed: "I am informed about the possibilities and limitations of the generative AI tools I used.",
      verified: "I have ensured that the results provided by the generative AI tools are correct, or that I have corrected them.",
      responsible: "I acknowledge that the responsibility for the work lies with the author, not with the generative AI tools or any other person.",
    )
  }
}

#let _activities(language) = {
  if language == "german" {
    (
      ideation: (
        title: "Ideenfindung, Konzeptualisierung, Methodik",
        bullets: (
          "Entwicklung von Ideen, Forschungszielen, Zielsetzungen und Forschungsfragen",
          "Identifikation und Definieren relevanter Konzepte",
          "Suche nach einer geeigneten Methodik",
          "Entwicklung und Anpassung der Methodik an die Forschungsfrage(n)",
        ),
      ),
      literature: (
        title: "Literatur",
        bullets: (
          "Suche nach relevanter Literatur",
          "Überprüfung von potenziell relevanter Literatur",
          "Zusammenfassungen von relevanter Literatur",
        ),
      ),
      coding: (
        title: "Coding",
        bullets: (
          "Erstellen und Dokumentieren von Code, Algorithmen, Software",
          "Testen und Debuggen von bestehendem Code, Algorithmen, Software",
          "Verständnis von bestehendem Code, Algorithmen, Software",
          "Datenerhebung und -analyse",
        ),
      ),
      interpretation: (
        title: "Interpretation",
        bullets: (
          "Interpretation der Ergebnisse",
          "Ableitung von Implikationen für Forschung und Praxis",
          "Überprüfung der allgemeinen Replikation/Reproduzierbarkeit der Ergebnisse und anderer Forschungsergebnisse",
        ),
      ),
      writing: (
        title: "Schreiben",
        bullets: (
          "Gliederung der Arbeit",
          "Generierung von Text zu verschiedenen Themen in verschiedenen Abschnitten der Arbeit",
          "Kritische Überprüfung, Feedback oder Überarbeitung des Inhalts, der Organisation oder der Grammatik der Arbeit",
          "Korrekturlesen",
          "Umformulierung oder Paraphrasierung von Text",
          "Kürzung/Erweiterung des Textes",
        ),
      ),
      presentation: (
        title: "Präsentation",
        bullets: (
          "Strukturierung einer Präsentation über die Arbeit",
          "Füllen einer Präsentation über die Arbeit mit Inhalt",
          "Kritische Überprüfung, Feedback oder Überarbeitung des Inhalts, der Organisation der Präsentation",
        ),
      ),
    )
  } else {
    (
      ideation: (
        title: "Idea, Conceptualization, Methodology",
        bullets: (
          "Development of ideas, research goals, objectives and research questions",
          "Identification and definition of relevant concepts",
          "Search for a suitable methodology",
          "Development and adaptation of the methodology to the research question(s)",
        ),
      ),
      literature: (
        title: "Literature",
        bullets: (
          "Search for relevant literature",
          "Review of potentially relevant literature",
          "Summaries of relevant literature",
        ),
      ),
      coding: (
        title: "Coding",
        bullets: (
          "Creation and documentation of code, algorithms, software",
          "Testing and debugging of existing code, algorithms, software",
          "Understanding of existing code, algorithms, software",
          "Data collection and analysis",
        ),
      ),
      interpretation: (
        title: "Interpretation",
        bullets: (
          "Interpretation of the results",
          "Derivation of implications for research and practice",
          "Review of the general replication/reproducibility of the results and other research results",
        ),
      ),
      writing: (
        title: "Writing",
        bullets: (
          "Structuring of the thesis",
          "Generation of text on various topics in different sections of the thesis",
          "Critical review, feedback or revision of the content, organization or grammar of the thesis",
          "Proofreading",
          "Rewording or paraphrasing of text",
          "Shortening/expanding of the text",
        ),
      ),
      presentation: (
        title: "Presentation",
        bullets: (
          "Structuring a presentation about the thesis",
          "Filling a presentation about the thesis with content",
          "Critical review, feedback or revision of the content, organization of the presentation",
        ),
      ),
    )
  }
}

// Resolve a single mark from the `ai-tools` parameter, defaulting to false.
#let _resolve-mark(ai-tools, group, key) = {
  if ai-tools == none { return false }
  if group not in ai-tools { return false }
  let dict = ai-tools.at(group)
  if key not in dict { return false }
  dict.at(key)
}

// Author declaration chapter with AI-tools tables.
//
// Parameters.
//   language    "english" or "german"
//   ai-tools    none, or a dictionary of the form
//               (statements: (informed: bool, verified: bool, responsible: bool),
//                activities: (ideation: bool, literature: bool, coding: bool,
//                             interpretation: bool, writing: bool, presentation: bool))
#let declaration(language: "english", ai-tools: none) = {
  let t = _texts(language)
  let stmts = _statements(language)
  let acts = _activities(language)

  heading(level: 1, numbering: none, outlined: false)[#t.title]
  t.paragraph-1
  parbreak()
  t.paragraph-2
  parbreak()
  t.paragraph-3

  v(8mm)

  // Section 1. Responsible use of AI tools (3-row statements table).
  text(weight: "bold")[#t.ai-tools-header-1]
  v(2mm)
  table(
    columns: (1fr, 2cm),
    align: (left, center),
    stroke: 0.5pt,
    inset: 6pt,
    table.header(
      text(weight: "bold")[#t.ai-statements-col],
      text(weight: "bold")[#t.ai-confirmation-col],
    ),
    stmts.informed, _box(_resolve-mark(ai-tools, "statements", "informed")),
    stmts.verified, _box(_resolve-mark(ai-tools, "statements", "verified")),
    stmts.responsible, _box(_resolve-mark(ai-tools, "statements", "responsible")),
  )

  v(4mm)

  // Section 2. Detailed activities (6-row activities table).
  text(weight: "bold")[#t.ai-tools-header-2]
  v(2mm)

  let activity-row(key) = {
    let act = acts.at(key)
    let bullets = act.bullets.map(b => [• #b]).join(linebreak())
    (
      text(weight: "bold")[#act.title],
      bullets,
      _box(_resolve-mark(ai-tools, "activities", key)),
    )
  }

  table(
    columns: (3.5cm, 1fr, 2cm),
    align: (left, left, center),
    stroke: 0.5pt,
    inset: 6pt,
    table.header(
      text(weight: "bold")[#t.ai-activity-col],
      text(weight: "bold")[#t.ai-description-col],
      text(weight: "bold")[#t.ai-confirmation-col],
    ),
    ..activity-row("ideation"),
    ..activity-row("literature"),
    ..activity-row("coding"),
    ..activity-row("interpretation"),
    ..activity-row("writing"),
    ..activity-row("presentation"),
  )

  v(2cm)

  // Signature line.
  grid(
    columns: (1fr, 1cm, 1fr),
    align: (center, center, center),
    [#line(length: 80%, stroke: 0.5pt) \ #t.date-label],
    [],
    [#line(length: 80%, stroke: 0.5pt) \ #t.signature-label],
  )
}
