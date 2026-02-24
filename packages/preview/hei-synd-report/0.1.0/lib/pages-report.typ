//
// Description: Title page for the script template
// Author     : Silvan Zahno
//
#import "helpers.typ": *

#let page-title-report(
  type: none,
  doc: (
    title    : none,
    abbr     : none,
    subtitle : none,
    url      : none,
    logos: (
      tp_topleft  : none,
      tp_topright : none,
      tp_main     : none,
      header      : none,
    ),
    authors: (
      (
        name        : none,
        abbr        : none,
        email       : none,
        url         : none,
      ),
    ),
    school: (
      name        : none,
      major       : none,
      orientation : none,
      url         : none,
    ),
    course: (
      name     : none,
      url      : none,
      prof     : none,
      class    : none,
      semester : none,
    ),
    keywords : ("Typst", "Template", "Report"),
    version  : "v0.1.0",
  ),
  date: datetime.today(),
) = {
  table(
    columns: (50%, 50%),
    stroke:none,
    align:(left, right),
    [
      #if doc.logos.tp_topleft != none {
        [#doc.logos.tp_topleft]
      }
    ],
    [
      #if doc.logos.tp_topright != none {
        [#doc.logos.tp_topright]
      }
    ],
  )
  v(2fr)
  if doc.title != none {
    align(center, text(size:huge, [*#doc.title*] ))
    v(0.5em)
  }
  if doc.subtitle != none {
    align(center, text(size:larger, [_ #doc.subtitle _] ))
    v(2em)
  }

  if doc.logos.tp_main != none {
    align(center, [#doc.logos.tp_main])
    v(2em)
  }

  v(1fr)

  set text(normal)
  if doc.school.name != none or doc.school.url != none {[*#safe-link(url:doc.school.url, name:doc.school.name)* \ ]}
  if doc.school.major != none {[#safe-link(url:doc.school.url, name:doc.school.major)]}
  if ((doc.school.major != none and doc.school.orientation != none) or doc.school.url != none) {" - "}
  if doc.school.orientation != none or doc.school.url!= none {[#safe-link(url:doc.school.url, name:doc.school.orientation)]}
  if (doc.school.major != none or doc.school.orientation != none) {[\ ]}

  if doc.course.name != none or doc.course.url != none {[#safe-link(url:doc.course.url, name:doc.course.name)]}
  if ((doc.course.name != none and doc.course.prof != none) or doc.course.url != none) {" - "}
  if doc.course.prof != none or doc.course.url != none {[#safe-link(url:doc.course.url, name:doc.course.prof)]}
  if (doc.course.prof != none or doc.course.url != none) {[\ ]}

  if doc.course.semester != none {[#doc.course.semester]}
  if (doc.course.semester != none and doc.course.class != none) {" - "}
  if doc.course.class != none {[#doc.course.class]}
  if (doc.course.semester != none or doc.course.class != none) {[\ ]}

  line(length: 100%, stroke: 0.5pt)

  set text(large)
  if doc.authors.first().name != none {[*#enumerating-emails(names:doc.authors.map(a => a.name), emails:doc.authors.map(a => a.email))*\ ]}

  if date != none {[#date.display("[day].[month].[year]") - ]}
  if doc.version != none {[#doc.version]}
  if (doc.version != none and type != none) {" - "}
  if type != none {[#type]}
}
