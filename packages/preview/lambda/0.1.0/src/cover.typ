// ─── COVER PAGE ─────────────────────────────────────────────────────────────
#import "theme.typ": default-theme

// Visible strings — override individual keys via the `labels:` parameter for
// localisation.
#let default-cover-labels = (
  born:          "Born:",
  student-id:    "Student ID:",
  id:            "ID:",
  supervisor:    "Supervisor:",
  co-supervisor: "Co-supervisor:",
  logo:          "LOGO",
)

#let show-cover(
  title: "",
  authors: (),
  email: none,
  birthday: none,
  student-id: none,
  degree: none,
  major: none,
  department: none,
  faculty: none,
  university: none,
  location: none,
  date: none,
  submission-text: none,
  supervisor: none,
  co-supervisor: none,
  logo: none,
  theme: default-theme,
  labels: (:),
) = {
  let accent = theme.accent
  let font-sans = theme.font-sans
  let font-serif = theme.font-serif
  let lbl = default-cover-labels + labels

  // ── Resolve authors ──────────────────────────────────────────────
  let author-list = if type(authors) == array { authors } else { (authors,) }
  let single = author-list.len() == 1

  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 2.4cm, bottom: 2.4cm),
    numbering: none,
    header: none,
    footer: none,
  )

  // ── Top row: university info + logo ──────────────────────────────
  let uni-block = {
    set align(left)
    if university != none {
      text(font: font-sans, weight: "bold", size: 14pt, university)
      linebreak()
    }
    if department != none {
      text(font: font-serif, size: 14pt, department)
      linebreak()
    }
    if faculty != none {
      text(font: font-serif, style: "italic", size: 12pt, faculty)
    }
  }

  let logo-block = {
    set align(right)
    if logo != none {
      image(logo, width: 2.2cm)
    } else {
      align(right, box(
        width: 2.2cm,
        height: 2.2cm,
        stroke: 0.6pt + accent,
        inset: 0pt,
        radius: 2pt,
        align(center + horizon, text(
          font: font-sans,
          size: 8pt,
          fill: accent,
          lbl.logo,
        )),
      ))
    }
  }

  grid(
    columns: (1fr, 2.6cm),
    column-gutter: 1cm,
    uni-block,
    logo-block,
  )

  v(1fr)

  // ── Title ────────────────────────────────────────────────────────
  align(center, {
    set par(justify: false, leading: 0.5em)
    text(font: font-sans, fill: accent, weight: "bold", size: 20pt, title)
  })

  v(1fr)

  // ── Degree block ─────────────────────────────────────────────────
  align(center, {
    if submission-text != none {
      text(font: font-serif, size: 10pt, submission-text)
      v(-0.5cm)
    }
    if degree != none {
      text(font: font-sans, weight: "bold", size: 26pt, degree)
      v(-0.5cm)
    }
    if major != none {
      text(font: font-serif, size: 12pt, [in #emph(major)])
    }
  })

  v(1fr)

  // ── Bottom row ───────────────────────────────────────────────────
  let left-col = {
    set align(center)

    if single {
      // Single author: show full details
      let a = author-list.at(0)
      let name = if type(a) == str { a } else { a.name }
      text(font: font-sans, weight: "bold", size: 12pt, name)
      if email != none {
        v(0.2cm)
        text(font: font-serif, size: 10pt, if type(email) == array { email.join(", ") } else { email })
      }
      if birthday != none {
        v(0.2cm)
        text(font: font-sans, weight: "bold", lbl.born)
        linebreak()
        text(font: font-serif, style: "italic", birthday)
      }
      if student-id != none {
        v(0.2cm)
        text(font: font-sans, weight: "bold", lbl.student-id)
        linebreak()
        text(font: font-serif, style: "italic", str(student-id))
      }
    } else {
      // Multiple authors: show name + student-id if available
      for a in author-list {
        let name = if type(a) == str { a } else { a.name }
        let sid  = if type(a) == str { none } else { a.at("student-id", default: none) }
        let bd   = if type(a) == str { none } else { a.at("birthday", default: none) }
        text(font: font-sans, weight: "bold", size: 12pt, name)
        if bd != none {
          linebreak()
          text(font: font-sans, weight: "bold", lbl.born + " ")
          text(font: font-serif, style: "italic", bd)
        }
        if sid != none {
          linebreak()
          text(font: font-sans, weight: "bold", lbl.id + " ")
          text(font: font-serif, style: "italic", str(sid))
        }
        v(0.3cm)
      }
    }
  }

  let right-col = {
    set align(center)
    if supervisor != none {
      text(font: font-sans, weight: "bold", fill: accent, lbl.supervisor)
      linebreak()
      text(font: font-serif, size: 12pt, supervisor)
    }
    if co-supervisor != none {
      v(0.2cm)
      text(font: font-sans, weight: "bold", fill: accent, lbl.co-supervisor)
      linebreak()
      text(font: font-serif, size: 12pt, co-supervisor)
    }
    if location != none {
      v(0.2cm)
      text(font: font-sans, weight: "bold", location)
    }
    if date != none {
      linebreak()
      text(font: font-serif, style: "italic", date)
    }
  }

  grid(
    columns: (1fr, 1fr),
    column-gutter: 1.2cm,
    left-col,
    right-col,
  )
}
