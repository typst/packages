//-------------------------------------
// Document options
//
#let option = (
  //type        : "final",
  type        : "draft",
  lang        : "en",
  //lang        : "de",
  //lang        : "fr",
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.1.0":*  // only for the generated images

#let titlepage_logo= dragon-curve(
  12,
  step-size: 10,
  stroke-style: stroke(
    //paint: gradient.linear(..color.map.rocket, angle: 135deg),
    paint: gradient.radial(..color.map.rocket),
    thickness: 3pt, join: "round"),
  height: 10cm,
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : [*Report for Systems Engineering*],
  abbr     : "Prj",
  subtitle : [_Typst Template Example_],
  url      : "https://synd.hevs.io",
  logos: (
    tp_topleft  : image("resources/img/synd.svg", height: 1.2cm),
    tp_topright : image("resources/img/hei.svg", height: 1.5cm),
    tp_main     : titlepage_logo,
    header      : image("resources/img/project-logo.svg", width: 2.5cm),
  ),
  authors: (
    (
      name        : "Silvan Zahno",
      abbr        : "ZaS",
      email       : "silvan.zahno@hevs.ch",
      url         : "https://synd.hevs.io",
    ),
    (
      name        : "Axel Amand",
      abbr        : "AmA",
      email       : "axel.amand@hevs.ch",
      url         : "https://synd.hevs.io",
    ),
    (
      name        : "Rémi Heredero",
      abbr        : "HeR",
      email       : "remi.heredero@hevs.ch",
      url         : "https://synd.hevs.io",
    ),
  ),
  school: (
    name        : "HES-SO Valais//Wallis",
    major       : "Systems Engineering",
    orientation : "Infotronics",
    url         : "https://synd.hevs.io",
  ),
  course: (
    name     : "Digital Design",
    url      : "https://course.hevs.io/did/eda-docs/",
    prof     : "Silvan Zahno",
    class    : [S1f$alpha$],
    semester : "Fall Semester 2025",
  ),
  keywords : ("Typst", "Template", "Report", "HEI-Vs", "Systems Engineering", "Infotronics"),
  version  : "v0.1.0",
)

#let date= datetime.today()

//-------------------------------------
// Settings
//
#let tableof = (
  toc: true,
  tof: false,
  tot: false,
  tol: false,
  toe: false,
  maxdepth: 3,
)

#let gloss    = true
#let appendix = false
#let bib = (
  display : true,
  path  : "/tail/bibliography.bib",
  style : "ieee", //"apa", "chicago-author-date", "chicago-notes", "mla"
)
