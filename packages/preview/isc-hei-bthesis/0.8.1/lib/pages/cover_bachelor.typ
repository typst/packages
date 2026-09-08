#import "../includes.typ" as inc
#import "../overflow.typ" as overflow
#import "/isc_templates.typ" as isc

// Adapted from https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main

#let cover_page(
  supervisors: none,
  expert: none,
  font: "",
  title: "",
  subtitle: none,
  semester: "",
  academic-year: "",
  school: "",
  programme: "",
  major: "",
  authors: "",
  thesis-id: none,
  submission-date: "",
  revision: none,
  logo: none,
  language: "",
  hide-completeness-warning: false,
) = {
  let thesis-id = if thesis-id == none { "" } else { thesis-id }
  let i18n = isc.i18n.with(extra-i18n: none, language)
  let hei-purple = inc.hei-purple
  let right-margin = 12mm
  let left-margin = 30mm

  // Set the document's basic properties.
  set page(margin: (left: 0mm, right: right-margin, top: 0mm, bottom: 0mm), numbering: none, number-align: center)

  // ── Completeness check (drafting aid) ───────────────────────────────────────
  // The sentinels mirror the placeholder values shipped in src/bachelor_thesis.typ.
  // While EVERY field still carries its shipped placeholder we assume the student
  // hasn't started and stay silent; as soon as ANY field is touched (differs from
  // its shipped placeholder — including being emptied) we flag every required
  // field still left empty or at its shipped placeholder value.
  let sample-author    = "Margaret Hamilton"
  let sample-thesis-id = "ISC-ID-26-1"
  let sample-repo      = "https://github.com/ISC-HEI/isc-hei-typst-templates"
  let sample-keywords  = ("engineering", "data", "machine learning", "meteorology")
  // Expected reference format: ISC-XX-YY-N (XX = two letters, YY = two-digit
  // year, N = one or more digits), e.g. ISC-SE-26-3.
  let id-pattern       = regex("^ISC-[A-Za-z]{2}-[0-9]{2}-[0-9]+$")
  let fr = language == "fr"

  // Returns the list of still-incomplete required fields. Must be called from a
  // context block (it reads document state). Returns () while the document is
  // still fully pristine (every field at its shipped placeholder).
  let compute-issues() = {
    let repo      = inc.global-project-repos.get()
    let keywords  = inc.global-keywords.get()
    let signature = inc.global-thesis-meta.get().at("signature", default: none)
    // An image element exposes its path via `.source`; we use it to tell whether
    // the student is still pointing at the shipped placeholder signature file.
    let sig-src   = if signature != none and "source" in signature.fields() { signature.fields().at("source") } else { none }

    // "started" = at least one field diverges from its exact shipped placeholder.
    // Note this is stricter than the per-field "incomplete" tests below: emptying
    // the repo to "" differs from the shipped URL, so it counts as touched even
    // though "" is also an incomplete value.
    let at-default = (
      str(authors) == sample-author
        and thesis-id == sample-thesis-id
        and repo == sample-repo
        and keywords == sample-keywords
        and (signature != none and type(sig-src) == str and sig-src.contains("signature_placeholder"))
    )

    let issues = ()
    if not at-default {
      if thesis-id in (none, "", sample-thesis-id) {
        issues.push(if fr [La référence du travail (`thesis-id`) n'a pas été mise à jour.] else [The thesis reference (`thesis-id`) has not been updated.])
      } else if str(thesis-id).match(id-pattern) == none {
        issues.push(if fr [Le format de la référence (`thesis-id`) est invalide — attendu p. ex. `ISC-SE-26-3`.] else [The thesis reference (`thesis-id`) format is invalid — expected e.g. `ISC-SE-26-3`.])
      }
      if signature == none {
        issues.push(if fr [L'image de la signature (`signature`) est manquante.] else [The signature image (`signature`) is missing.])
      } else if type(sig-src) == str and sig-src.contains("signature_placeholder") {
        issues.push(if fr [L'image de la signature (`signature`) doit être remplacée par la vôtre.] else [The signature image (`signature`) must be replaced with your own.])
      }
      if repo in (none, "", sample-repo) {
        issues.push(if fr [Le lien du dépôt Git (`project-repos`) n'a pas été mis à jour.] else [The Git repository link (project-repos) has not been updated.])
      }
      if keywords == () or keywords == sample-keywords {
        issues.push(if fr [Les mots-clés (keywords) n'ont pas été modifiés.] else [The keywords (keywords) have not been changed.])
      }
    }

    // Title / subtitle overflow — checked unconditionally (a layout problem,
    // independent of whether the metadata fields are still at their placeholders).
    // The thesis IS the reference cover the verdict is measured against, so this is
    // exact here and identical on every other document type.
    issues += overflow.title-overflow-issues(title, subtitle: subtitle)

    issues
  }

  // Drafting warning box. Sits in the empty band below the author block so it
  // never overlaps the title header. Suppressed when the author opts out via
  // `hide-completeness-warning` (a discreet marker then goes on the 2nd page).
  context {
    let issues = compute-issues()
    if not hide-completeness-warning and issues.len() > 0 {
      place(top + left, dx: left-margin, dy: 64mm, box(
        width: 210mm - left-margin - right-margin - 10mm,
        fill: rgb("#ffe3e3"),
        stroke: 2.5pt + rgb("#c1121f"),
        radius: 4pt,
        inset: 10pt,
        {
          set text(font: font, fill: rgb("#9d0208"))
          text(weight: 900, size: 13pt, i18n("completeness-warning-header"))
          v(4pt)
          set text(size: 10pt, weight: 500)
          for it in issues {
            block(below: 5pt, [— #it])
          }
        },
      ))
    }
  }

  let title_block = if subtitle == none {
    stack(par(leading: 11pt, text(title, size: 23pt, weight: 660)), v(5mm))
  } else {
    stack(
      par(leading: 11pt, text(title, size: 24pt, weight: 660)),
      v(7mm),
      par(leading: 11pt, text(subtitle, size: 12pt)),
      v(12mm),
    )
  }

  // Title etc.
  pad(
    left: left-margin,
    top: 42mm,
    right: right-margin,
    stack(
      // Type
      let thesis-title = i18n("bachelor-thesis-title"),
      upper(text(thesis-title, size: 15pt, weight: "black")),
      v(4mm),
      // Author
      text(authors, size: 18pt),
      v(70mm),
      // Title
      title_block,
      
      v(5mm),
      
      // Decorative line: hash-encoded bit pattern (square ends + circle bits).
      // Its width matches the programme text rendered just below it, so measure
      // that line and feed the result to hash-rule as its length.
      // dy pulls the box up by half its height so the rule sits on the baseline,
      // matching the original zero-height placement.
      context {
        let prog-width = measure(text(programme, size: 14pt, weight: 650)).width
        place(dy: -4pt, isc.hash-rule(thesis-id + authors, length: prog-width))
      },
      v(5mm),
      text(programme, size: 14pt, weight: 650),
      v(3mm),
      text(i18n("thesis-id-title") + " " + thesis-id, size: 9pt),
    ),
  )

  // University identity block
  place(
    right + bottom,
    dx: -right-margin,
    dy: -24mm,
    box(
      align(
        right,
        stack(
          move(dy: -0mm, image("../assets/HES-SO_logo_CMJN.svg", width: 3.5cm)),
          // Decorative line: hei-hei-purple square on the left, line with hei-purple circles
          {
            let line-length = 3.5cm // 3.5cm + 2cm extra on left
            let line-thickness = 1.0pt
            let square-size = 5pt
            let circle-r = 2.2pt

            // The main line
            // line(start: (0pt, 0pt), length: line-length, stroke: (thickness: line-thickness, dash: "solid", paint: black))

            // hei-purple square at the far left
            //place(dx: 4.1cm, dy: -square-size / 2, rect(width: square-size, height: square-size, fill: hei-purple, stroke: none))
            // hei-purple circles at fixed positions along the line
            // for dx-val in (0.8cm, 1.6cm, 2.3cm, 3.1cm) {
            //   place(dx: dx-val, dy: -circle-r, circle(radius: circle-r, fill: hei-purple, stroke: none))
            // }
          },
          v(3mm),
          text(i18n("hes-so"), size: 9pt, weight: "bold"),
          v(2mm),
          text(i18n("faculty"), size: 9pt),
          v(2mm),
          text(school, size: 9pt),
        ),
      ),
    ),
  )

  //
  // Second cover page
  //
  isc.cleardoublepage()

  set page(margin: (left: 31.5mm, right: 32mm, top: 75mm, bottom: 25mm), numbering: none, number-align: center)

  // School logo
  place(top + center, dx: 0mm, dy: -55mm, image("../assets/isc_logo.svg", height: 1.4cm))


  stack(
    // Author
    align(center, text(authors, size: 18pt)),
    v(23mm),
  )

  align(center, par(leading: 13pt, text(title, size: 22pt, weight: 620)))
  v(8mm)

  if (subtitle != none) {
    align(center, par(leading: 13pt, text(subtitle, size: 12pt)))
  }

  // Repo block sits at the bottom-right, aligned with the last line of the
  // bottom stack ("Travail soumis le …"). place() floats outside the flow.
  place(bottom + right, isc.repo-block(language))

  // Discreet tell: when the author hid the completeness warning while fields
  // were still incomplete, record it with a tiny coloured dot in the bottom-left
  // corner of this second cover page.
  context {
    if hide-completeness-warning and compute-issues().len() > 0 {
      place(bottom + left, dx: -5mm, dy: -0.4mm, circle(radius: 2.5pt, fill: rgb("#c1121f"), stroke: none))
    }
  }

  v(1fr)

  stack(
    stack(
      spacing: 3mm,
      text(i18n("thesis-submitted")),
      text(programme + " – " + i18n("major-prefix") + isc.resolve-major(major, language) + i18n("major-suffix"), style: "italic"),
      text(school),
    ),
    v(6mm),
    line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
    v(6mm),
    let colon = if language == "fr" { " : " } else { ": " },
    if supervisors.len() > 0 {
      if type(supervisors) != array {
        text(i18n("supervising-examiner") + colon + text(upper(supervisors), weight: "bold"), size: 10pt)
      } else {
        text(i18n("supervising-examiner") + colon + text(upper(supervisors.first()), weight: "bold"), size: 10pt)

        if supervisors.len() > 1 {
          linebreak()
          text(i18n("supervising-second-examiner") + colon + text(upper(supervisors.at(1)), weight: "bold"), size: 10pt)
        }
      }
    },
    if expert != none {
      linebreak()
      text(i18n("supervising-expert") + colon + text(upper(expert), weight: "bold"), size: 10pt)
    },
    if submission-date != none {
      stack(v(6mm), line(start: (0pt, 0pt), length: 25pt, stroke: 1mm), v(6mm), text(
        i18n("submitted-on") + " " + inc.custom-date-format(submission-date, pattern: i18n("date-format") + ". " + i18n("revision") + " " + revision, lang: language),
        size: 10pt,
      ))
    }
  )
}