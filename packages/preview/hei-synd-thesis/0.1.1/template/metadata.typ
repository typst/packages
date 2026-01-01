//-------------------------------------
// Document options
//
#let option = (
  //type : "final",
  type : "draft",
  lang : "en",
  //lang : "de",
  //lang : "fr",
  template    : "thesis",
  //template    : "midterm"
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.1.1":*
#let project-logo= dragon-curve(
  12,
  step-size: 10,
  stroke-style: stroke(
    paint: gradient.radial(..color.map.rocket),
    thickness: 3pt, join: "round"
  ),
  height: 5cm,
  fit: "contain",
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : "Thesis Template",
  subtitle : "Longer Subtitle",
  author: (
    name        : "Firstname Lastname",
    email       : "firstname.lastname@hevs.ch",
    degree      : "Bachelor",
    affiliation : "HEI-Vs",
    place       : "Sion",
    url         : "https://synd.hevs.io",
    signature   : image("/resources/img/signature.svg", width:3cm),
  ),
  keywords : ("HEI-Vs", "Systems Engineering", "Infotronics", "Thesis", "Template"),
  version  : "v0.1.0",
)

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
  address: [HES-SO Valais Wallis • rue de l'Industrie 23 • 1950 Sion \ +41 58 606 85 11 • #link("mailto"+"info@hevs.ch")[info\@hevs.ch] • #link("www.hevs.ch")[www.hevs.ch]]
)

#let professor= (
  affiliation: "HEI-Vs",
  name: "Prof. Silvan Zahno",
  email: "silvan.zahno@hevs.ch",
)
#let expert= (
  affiliation: "Company",
  name: "Expert Name",
  email: "expert@domain.ch",
)
#let school= (
  name: none,
  orientation: none,
  specialisation: none,
)
#if option.lang == "de" {
  school.name = "Hochschule für Ingenieurwissenschaften Wallis, HES-SO"
  school.orientation = "Systemtechnik"
  school.specialisation = "Infotronics"
} else if option.lang == "fr" {
  school.name = "Haute École d'Ingénierie du Valais, HES-SO"
  school.shortname = "HEI-Vs"
  school.orientation = "Systèmes industriels"
  school.specialisation = "Infotronics"
} else {
  school.name = "University of Applied Sciences Western Switzerland, HES-SO Valais Wallis"
  school.shortname = "HEI-Vs"
  school.orientation = "Systems Engineering"
  school.specialisation = "Infotronics"
}

#let date = (
  submission: datetime(year: 2025, month: 8, day: 14),
  mid-term-submission: datetime(year: 2025, month: 5, day: 2),
  today: datetime.today(),
)

#let logos = (
  main: project-logo,
  topleft: if option.lang == "fr" or option.lang == "de" {
    image("/resources/img/logos/hei-defr.svg", width: 6cm)
  } else {
    image("/resources/img/logos/hei-en.svg", width: 6cm)
  },
  topright: image("/resources/img/logos/hesso-logo.svg", width: 4cm),
  bottomleft: image("/resources/img/logos/hevs-pictogram.svg", width: 4cm),
  bottomright: image("/resources/img/logos/swiss_universities-valais-excellence-logo.svg", width: 5cm),
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
