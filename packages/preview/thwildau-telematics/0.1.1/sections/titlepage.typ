#import "../utils/translation.typ": translation
#import "../utils/user_input.typ": user-input

#let make-titlepage-internship(
  title: none,
  student: none,
  supervisor: none,
  internship: none,
) = {
  // check user input
  user-input(title, "title", "My thesis")
  user-input(student, "student", (
    name: "Clara Fall",
    matrnr: "12345678",
    subject: "Telematics",
    seminar-group: "T23",
    semester: "4",
  ))
  user-input(supervisor, "supervisor", (
    name: "Frau Dr. Lieschen Müller",
    mail: "mueller@example.com",
  ))
  user-input(internship, "internship", (
    type: "3rd Internship",
    partner: [Beispiel AG \ Straßenweg 1 \ 12345 Musterstadt \ #link("https://example.com")],
    period: "16.06.2025 to 25.07.2025",
  ))

  // header
  grid(
    columns: (1fr, 5cm),

    align(left)[#text(12pt, translation("Wildau Technical University of Applied Sciences") + linebreak() + student.subject)],
    align(right)[#image("../assets/TH-Wildau-Logo_rgb.png", width: 5cm)],
  )
  v(2cm)

  // title
  align(center, text(title, size: 28pt, weight: "medium"))
  v(1.5cm)

  // content
  text(
    14pt,
    grid(
      columns: (1fr, 1fr),
      column-gutter: 1.4em,
      row-gutter: 1.6em,

      translation("Created by") + ":", student.name + linebreak() + student.matrnr,
      translation("Seminar group") + ":", student.seminar-group,
      translation("Semester") + ":", student.semester,
      translation("Type of internship") + ":", internship.type,
      translation("Company") + ":", internship.partner,
      translation("Supervisor") + ":", supervisor.name + linebreak() + link("mailto:" + supervisor.mail),
      translation("Internship period") + ":", internship.period,
    ),
  )
}

#let make-titlepage-content(
  page-content: none,
) = {
  user-input(page-content, "titlepage.content", "[My Titlepage]")
  page-content
}
