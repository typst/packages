#import "@preview/community-ostfalia-thesis:0.1.0": *

//-------------------------------------
// Document options
//
#let option = (
  type : sys.inputs.at("type", default:"draft"),    // [draft|final]
  lang : sys.inputs.at("lang", default:"de"),       // [en|fr|de]
  template    : "thesis",   // [thesis/practical-project]
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.3.2":*
#let project-logo= dragon-curve(
  12,
  step-size: 1.6,
  stroke: stroke(
    paint: gradient.radial(..color.map.rocket),
    thickness: 0.5pt, join: "round"
  )
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : "Thesis Template",
  subtitle : "Longer Subtitle",
  author: (
    gender      : "inclusive",  // ["masculin"|"feminin"|"inclusive"]
    name        : "Firstname Lastname",
    email       : "f.lastname@ostfalia.de",
    degree      : "Bachelor",
    affiliation : "Ostfalia",
    place       : "Wolfenbüttel",
    url         : "https://www.ostfalia.de/hochschule/fakultaeten/fakultaet-informatik",
    signature   : image("/resources/img/signature.svg", width:3cm),
    matrikelnummer: "12341234"
  ),
  keywords : ("Ostfalia", "Software Engineering", "Informatics", "Thesis", "Template"),
  version  : "v0.1.0",
)

#let data-page = read("/resources/thesis-data.pdf", encoding: none) // [bytes|none]

#let summary-page = (
  logo: project-logo,
  //one sentence with max. 240 characters, with spaces.
  objective: [
    The objective of this thesis is to analyze and improve the performance of a predictive maintenance system in industrial IoT environments by implementing advanced data processing algorithms and evaluating their effectiveness through case studies.
  ],
  //summary max. 1200 characters, with spaces.
  content: [
   This bachelor thesis focuses on the optimization of predictive maintenance systems within industrial IoT environments. Predictive maintenance is a key aspect of modern manufacturing, enabling the anticipation of equipment failures and reducing downtime. The research begins by outlining the theoretical foundations of predictive maintenance, including sensor data acquisition, processing, and analysis. The study then introduces advanced data processing algorithms, such as machine learning techniques, to enhance prediction accuracy and reliability. A case study approach is employed, using real-world industrial data to evaluate the system’s performance. The results demonstrate significant improvements in fault detection rates and decision-making efficiency. The thesis concludes by discussing the implications for industry and providing recommendations for future development. This work aims to contribute to the advancement of smart maintenance systems, supporting industry 4.0 transformation efforts.
  ],
  address: [Ostfalia Hochschule für angewandte Wissenschaften • Am Exer 2 • 38302 Wolfenbüttel • #link("https://www.ostfalia.de")[www.ostfalia.de]]
)

#let professor= (
  affiliation: "Ostfalia",
  name: "Prof. Firstname Lastname",
  email: "f.lastname@ostfalia.de",
)
#let expert= (
  affiliation: "Company",
  name: "Expert Name",
  email: "expert@domain.de",
)
#let school= (
  name: none,
  orientation: none,
  specialisation: none,
)
#if option.lang == "de" {
  school.name = "Ostfalia Hochschule für angewandte Wissenschaft"
  school.orientation = "Informatik"
  school.specialisation = "Informatik"
} else if option.lang == "en" {
  school.name = "Ostfalia University of Applied Sciences"
  school.orientation = "Informatics"
  school.specialisation = "Computer Science"
} else {
  school.name = "Ostfalia University of Applied Sciences"
  school.orientation = "Informatics"
  school.specialisation = "Computer Science"
}

#let date = (
  submission: datetime(year: 2025, month: 10, day: 28),
  mid-term-submission: datetime(year: 2025, month: 5, day: 2),
  today: datetime.today(),
)

#let logos = (
  main: project-logo,
    topleft: if option.lang == "de" {
        image("/resources/img/logos/logo-main.svg", width: 6cm)
    } else {
        image("/resources/img/logos/logo-main-en.svg", width: 6cm)
    },
  )
)

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
