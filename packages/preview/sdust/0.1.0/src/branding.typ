// ══════════════════════════════════════════════════════
// SDU BRANDING & SHARED DEFAULTS
// ══════════════════════════════════════════════════════

// SDU visual identity — primary "SDU red".
#let sdu-red = rgb("#C40418")
#let sdu-university = "University of Southern Denmark"

// Departments of SDU's Faculty of Science — pass one as `department:`.
#let imada   = "Department of Mathematics and Computer Science"
#let bmb     = "Department of Biochemistry and Molecular Biology"
#let biology = "Department of Biology"
#let fkf     = "Department of Physics, Chemistry and Pharmacy"

// The SDU logo is a controlled brand asset and is NOT bundled with this
// package. SDU students: download it from SDUnet and pass it yourself, e.g.
//   #show: thesis.with(logo: image("sdu-logo.png", width: 12em), ...)
// Templates render no logo unless you pass one (`logo: none` by default).

// Defaults used by every template when an argument is omitted.
#let default-title  = "Untitled Document"
#let default-course = sdu-university
#let default-author = "Firstname Lastname"
#let default-date   = datetime.today().display("[day]/[month]/[year]")
