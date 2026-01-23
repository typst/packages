#import "@preview/tieflang:0.1.0": configure-translations, pop-lang, push-lang, tr
#import "utils.typ": title-case

#let translations = (
  de: (
    abstract: [Zusammenfassung],
    title: [Titel],
    author: [Autor],
    authors: [Autoren],
    supervisor: [Betreuer],
    supervisors: [Betreuer],
    co_supervisors: [Mitbetreuer],
    acknowledgements: (
      title: [Danksagung],
      text: (plural, supervisor-count, supervisors) => context {
        let p = (tr().pronoun)(plural)
        let verb = if plural { "danken" } else { "danke" }
        let possessive = if supervisor-count > 1 { "ihre" } else { "seine/ihre" }
        let was = if supervisor-count > 1 { "waren" } else { "war" }

        [#title-case(p) #verb #supervisors herzlich für #possessive Expertise und kontinuierliche Beratung. #possessive Führung und Unterstützung #was von unschätzbarem Wert für den erfolgreichen Abschluss dieses Projekts.]
      },
    ),
    "and": [und],
    pronoun: plural => if plural { "wir" } else { "ich" },
    have: plural => if plural { "haben" } else { "habe" },
    be: plural => if plural { "sind" } else { "bin" },
    verb_suffix_first: plural => if plural { "en" } else { "e" },
    declaration_of_originality: (
      title: [Eidesstattliche Erklärung],
      text: plural => {
        let student = if plural { "die Studierenden" } else { "der/die Studierende" }
        let pronoun = if plural { "sie" } else { "er/sie" }
        let versichert = if plural { "versichern" } else { "versichert" }
        let hat = if plural { "haben" } else { "hat" }
        let erklaert = if plural { "erklären" } else { "erklärt" }

        [
          Mit der Abgabe dieser Projektarbeit #versichert #student, dass #pronoun die Arbeit selbständig und ohne fremde Hilfe verfasst #hat. (Bei Gruppenarbeiten gelten die Leistungen der übrigen Gruppenmitglieder nicht als fremde Hilfe.)

          Der/die unterzeichnende Studierende #erklaert, dass alle zitierten Quellen (auch Internetseiten) im Text oder Anhang korrekt nachgewiesen sind, d.h. dass die Projektarbeit keine Plagiate enthält, also keine Teile, die teilweise oder vollständig aus einem fremden Text oder einer fremden Arbeit unter Vorgabe der eigenen Urheberschaft bzw. ohne Quellenangabe übernommen worden sind.

          KI-Systeme wurden im Rahmen dieser Arbeit wie in @ai angegeben verwendet.

          Bei Verfehlungen aller Art treten die Paragraphen 39 und 40 (Unredlichkeit und Verfahren bei Unredlichkeit) der ZHAW Prüfungsordnung sowie die Bestimmungen der Disziplinarmassnahmen der Hochschulordnung in Kraft.
        ]
      },
    ),
    location: [Ort],
    date: [Datum],
    institution: [Institution],
    institution_name: [ZHAW Zürcher Hochschule für Angewandte Wissenschaften],
    keywords: [Schlüsselwörter],
    submitted_on: [Eingereicht am],
    school_of: [School of],
    insitute_of: [Institut für],
    table_of_contents: [Inhaltsverzeichnis],
    glossary: [Glossar],
    code_snippet: [Code-Snippet],
    chapter: [Kapitel],
    appendix: [Anhang],
  ),
  en: (
    abstract: [Abstract],
    title: [Title],
    author: [Author],
    authors: [Authors],
    supervisor: [Supervisor],
    supervisors: [Supervisors],
    co_supervisors: [Co-Supervisors],
    acknowledgements: (
      title: [Acknowledgements],
      text: (plural, supervisor-count, supervisors) => context {
        let p = (tr().pronoun)(plural)
        let possessive = if supervisor-count > 1 { "their" } else { "his/her" }
        let was = if supervisor-count > 1 { "were" } else { "was" }

        [#title-case(p) sincerely thank #supervisors for #possessive expertise and continuous advice. #possessive guidance and support #was invaluable to the successful completion of this project.]
      },
    ),
    "and": [and],
    pronoun: plural => if plural { "we" } else { "I" },
    have: plural => if plural { "have" } else { "have" },
    be: plural => if plural { "are" } else { "am" },
    verb_suffix_first: plural => if plural { "" } else { "s" },
    declaration_of_originality: (
      title: [Declaration of Originality],
      text: plural => {
        let student = if plural { "students" } else { "student" }
        let confirm = if plural { "confirm" } else { "confirms" }
        let their = if plural { "their" } else { "his/her" }
        let declare = if plural { "declare" } else { "declares" }

        [
          By submitting this project work, the undersigned #student #confirm that this work is #their own work and was written without the help of a third party. (Group works: the performance of the other group members are not considered as third party).

          The #student #declare that all sources in the text (including Internet pages) and appendices have been correctly disclosed. This means that there has been no plagiarism, i.e. no sections of the project work have been partially or wholly taken from other texts and represented as the student's own work or included without being correctly referenced.

          AI systems were used in the process of this work, as specified in @appendix:ai.

          Any misconduct will be dealt with according to paragraphs 39 and 40 of the General Academic Regulations for Bachelor's and Master's Degree courses at the Zurich University of Applied Sciences (Rahmenprüfungsordnung ZHAW (RPO)) and subject to the provisions for disciplinary action stipulated in the University regulations.
        ]
      },
    ),
    location: [Location],
    date: [Date],
    institution: [Institution],
    institution_name: [ZHAW University of Applied Sciences],
    keywords: [Keywords],
    submitted_on: [Submitted on],
    school_of: [School of],
    insitute_of: [Institute of],
    table_of_contents: [Table of Contents],
    glossary: [Glossary],
    code_snippet: [Code Snippet],
    chapter: [Chapter],
    appendix: [Appendix],
  ),
)

#let languages = (
  de: "de",
  en: "en",
)

#let setup-language(lang, doc) = {
  configure-translations(translations)
  push-lang(lang)

  set text(
    lang: lang,
    region: if lang == "en" { "gb" } else { "ch" },
  )

  doc
}
