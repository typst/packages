#import "/lib/import.typ": *
#import "/lib/base.typ": *

#let paper(
  //Settings der Template
  language: "de",
  sans-font: "Noto Sans",
  serif-font: "Times New Roman",
  title: "",
  authors: (),
  keywords: (),
  description: "",
  date: "",
  logo: none,
  module: [Theorie-Praxis-Anwendung II],
  show-list-of-figures: true,
  show-list-of-tables: true,
  show-list-of-code: true,
  acronyms: (:),
  appendix: none,
  glossary: (:),
  bibliography: none,
  //Vorgeschriebene
  restriction-notice: [Die vorliegende Seminararbeit beinhaltet interne vertrauliche Informationen der DB Systel GmbH. Die Weitergabe des Inhaltes dieser Arbeit und eventuell beiliegender Zeichnungen und Daten im Gesamten oder in Teilen ist grundsätzlich untersagt. Es dürfen keinerlei Kopien oder Abschriften, auch nicht in digitaler Form, gefertigt werden. Ausnahmen bedürfen der schriftlichen Genehmigung durch die DB Systel GmbH.],
  foreword: [],
  gendering-note: [Zur besseren Lesbarkeit wird in dieser Ausarbeitung auf die gleichzeitige Verwendung geschlechtsspezifischer Sprachformen verzichtet. Sämtliche personenbezogenen Bezeichnungen gelten daher im Sinne der Gleichbehandlung für alle Geschlechter. Diese Vereinfachung dient ausschließlich der sprachlichen Klarheit und ist in keiner Weise als Wertung zu verstehen.],
  body,
) = {
  base-project(
    type: "paper",
    language: language,
    sans-font: sans-font,
    serif-font: serif-font,
    title: title,
    authors: authors,
    keywords: keywords,
    description: description,
    submission-date: date,
    university-logo: logo,
    module: module,
    show-list-of-figures: show-list-of-figures,
    show-list-of-tables: show-list-of-tables,
    show-list-of-code: show-list-of-code,
    acronyms: acronyms,
    appendix: appendix,
    glossary: glossary,
    bibliography: bibliography,
    restriction-notice: restriction-notice,
    foreword: foreword,
    gendering-note: gendering-note,
    {
      // Title page.
      v(0.6fr)
      // Titel
      align(center, text(2em, weight: 700, title))
      v(1.2em, weak: true)
      if logo != none {
        align(center, logo)
      }
      v(2.6fr)

      // Authoren.
      align(center, text(1.1em, weight: "bold", transl("GroupMembers")))
      pad(
        top: 0.7em,
        grid(
          columns: (1fr,),
          gutter: 1em,
          ..authors.map(author => align(center)[
            *#author.name* - #author.student-id
          ]),
        ),
      )
      v(1.5fr)

      //Beschreibung
      align(
        center,
        transl("Practicalpaper"),
      )
      align(center, text(module, weight: "bold"))
      v(1.5fr)

      //Datum
      align(center, text(1.1em, date))
      v(2.4fr)
    },
    body,
  )
}
