// title-page.typ
//
// Dissertation title page per Anlage 1 of the Promotionsordnung der
// Universität Stuttgart, 01.03.2019. The Anlage is "inhaltlich
// verbindlich": title, awarding phrase, Vorgelegt von with birthplace,
// Hauptberichter/Mitberichter, Tag der mündlichen Prüfung, institute,
// year. Always German, no logos, all black.
//
// Before acceptance the awarding phrase must read "Bei der Fakultät ...
// eingereichte Abhandlung" (status: "submitted"), in the approved print
// version "Von der Fakultät ... genehmigte Abhandlung" (status:
// "accepted"). Ported from diss_template/DISS_Vorlage.tex and checked
// against the Fakultät 2 title page template
// F02_Muster-Titelblatt_Promotionen.doc. The submitted version leaves
// out the date of the oral exam, as the faculty asks.

#import "common.typ": fonts

// Title-page-local sizes per paper format.
#let _tp-metrics(paper) = {
  if paper == "a5" {
    (
      margin: (x: 18mm, y: 18mm),
      title-size: 12pt,
      author-size: 12pt,
      body-size: 10pt,
      committee-size: 9pt,
      label-width: 44mm,
      top: 12mm,
      bottom: 22mm,
    )
  } else {
    (
      // Sizes and positions follow the title pages of the IWS Hefte,
      // e.g. Hefte 300 and 305.
      margin: (x: 25mm, y: 25mm),
      title-size: 17.28pt,
      author-size: 17.28pt,
      body-size: 14.4pt,
      committee-size: 12pt,
      label-width: 62mm,
      top: 17mm,
      bottom: 32mm,
    )
  }
}

// Degree presets in the Fakultät 2 wording, one male and one female
// form per degree. The phrase slots into "zur Erlangung der Würde
// [phrase] genehmigte Abhandlung". "dr-ing" and "dr-rer-nat" without
// suffix stay accepted as the male form for documents from before 0.4.0.
#let degree-phrases = (
  "dr-ing-male": [eines Doktor-Ingenieurs (Dr.-Ing.)],
  "dr-ing-female": [einer Doktor-Ingenieurin (Dr.-Ing.)],
  "dr-rer-nat-male": [eines Doktors der Naturwissenschaften (Dr.~rer.~nat.)],
  "dr-rer-nat-female": [einer Doktorin der Naturwissenschaften (Dr.~rer.~nat.)],
  "dr-ing": [eines Doktor-Ingenieurs (Dr.-Ing.)],
  "dr-rer-nat": [eines Doktors der Naturwissenschaften (Dr.~rer.~nat.)],
)

#let degree-message = "degree must be 'dr-ing-male', 'dr-ing-female', 'dr-rer-nat-male', or 'dr-rer-nat-female', or pass degree-phrase"

#let title-page(
  title: [],
  author: "",
  birthplace: "",
  status: "submitted",
  faculty: "Bau- und Umweltingenieurwissenschaften",
  degree: "dr-ing-male",
  degree-phrase: auto,
  awarded-by: auto,
  simtech: false,
  hauptberichter: "",
  mitberichter: (),
  exam-date: "",
  institute: "",
  year: "",
  paper: "a4",
) = {
  assert(status == "submitted" or status == "accepted", message: "status must be 'submitted' or 'accepted'")
  assert(
    degree-phrase != auto or degree in degree-phrases,
    message: degree-message,
  )
  let m = _tp-metrics(paper)
  set page(
    paper: paper,
    margin: m.margin,
    header: none,
    footer: none,
    numbering: none,
  )
  set text(font: fonts.sans, fill: black, size: m.body-size)
  set par(leading: 0.55em, justify: false)

  // Boxed so a line never breaks inside "Doktor-Ingenieurin" or
  // "(Dr. rer. nat.)".
  let phrase = box(if degree-phrase == auto { degree-phrases.at(degree) } else { degree-phrase })
  // Promotions through SC SimTech name the Stuttgart Center for
  // Simulation Science next to the faculty, as about a third of the
  // recent IWS Hefte do.
  // Line breaks as in the Hefte: after the faculty, and with SimTech
  // after the Center, the rest wraps naturally.
  let university = if simtech {
    [der Universität Stuttgart und dem Stuttgart Center for Simulation Science \ ]
  } else {
    [der Universität Stuttgart ]
  }
  let awarding = if awarded-by != auto {
    awarded-by
  } else if status == "submitted" {
    // Wording from the old LaTeX template. The Fakultät 2 title page
    // template only shows "genehmigte Abhandlung".
    [Bei der Fakultät #faculty \
      #university;zur Erlangung der Würde #phrase eingereichte Abhandlung]
  } else {
    [Von der Fakultät #faculty \
      #university;zur Erlangung der Würde #phrase genehmigte Abhandlung]
  }

  // Committee rows. All Mitberichter stand below one "Mitberichter:"
  // label, as in the recent IWS Hefte. The exam date row only appears
  // once status is "accepted".
  let committee-rows = (
    ([Hauptberichter:], [#hauptberichter]),
  )
  for (i, name) in mitberichter.enumerate() {
    let label = if i == 0 { [Mitberichter:] } else { [] }
    committee-rows.push((label, [#name]))
  }

  // Centered column with the committee table set flush left, as in the
  // Hefte. "vorgelegt von" in lower case and the name in bold, also as
  // in the Hefte. The faculty template capitalizes "Vorgelegt von".
  align(center)[
    #v(m.top)
    #text(size: m.title-size, weight: "bold", hyphenate: false)[#title]
    #v(6mm)
    #awarding
    #v(1fr)
    vorgelegt von \
    #text(size: m.author-size, weight: "bold")[#author]
    #if birthplace != "" [\ aus #birthplace]
    #v(1fr)
    #align(left, text(size: m.committee-size, grid(
      columns: (m.label-width, auto),
      align: (left, left),
      row-gutter: 3mm,
      ..committee-rows.flatten(),
      ..if status == "accepted" {
        ([], [#v(2.5em)], [Tag der mündlichen Prüfung:], [#exam-date])
      },
    )))
    #v(1fr)
    #institute \
    der Universität Stuttgart \
    #year
    #v(m.bottom)
  ]
}
