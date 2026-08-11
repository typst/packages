#import "@preview/hei-synd-thesis:0.4.0": *
#import "@preview/hei-synd-report:0.3.0": *

//-------------------------------------
// Document options
//
#let option = (
  type : sys.inputs.at("type", default:"draft"),    // [draft|final]
  lang : sys.inputs.at("lang", default:"en"),       // [en|fr|de]
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.3.2":*  // only for the generated images
#let titlepage_logo= dragon-curve(
  12,
  step-size: 4,
  stroke: stroke(
    paint: gradient.radial(..color.map.rocket),
    thickness: 1pt, join: "round"
  ),
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
    tp_topleft  : image("resources/img/synd-it.svg", height: 1.3cm),
    tp_topright : image("resources/img/hei.svg", height: 1.3cm),
    tp_main     : titlepage_logo,
    header      : image("resources/img/project-logo.svg", width: 2.0cm),
  ),
  authors: (
    (
      name        : "Silvan Zahno",
      abbr        : "ZaS",
      email       : "silvan.zahno@hevs.ch",
    ),
    (
      name        : "Axel Amand",
      abbr        : "AmA",
      email       : "axel.amand@hevs.ch",
    ),
    (
      name        : "Rémi Heredero",
      abbr        : "HeR",
      email       : "remi.heredero@hevs.ch",
    ),
  ),
  school: (
    name            : "HES-SO Valais//Wallis",
    url             : "https://hevs.ch",
    major           : "Systems Engineering",
    major_url       : "https://synd.hevs.io",
    orientation     : "Infotronics",
    orientation_url : "https://synd.hevs.io/education/infotronics.html",
  ),
  course: (
    name     : "Digital Design",
    url      : "https://github.com/hei-synd-did",
    prof     : "Silvan Zahno",
    email    : "silvan.zahno@hevs.ch",
    class    : [S1f$alpha$],
    semester : "Spring Semester 2026",
  ),
  keywords : ("Typst", "Template", "Report", "HEI-Vs", "Systems Engineering", "Infotronics"),
  version  : "v0.1.0",
)

#let date= datetime.today()

//-------------------------------------
// Settings
//
#let display = (
  gradient: false,
)

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

#let fonts = (
  text: "Libertinus Serif",
  mono: "DejaVu Sans Mono",
  math: "New Computer Modern Math",
)
