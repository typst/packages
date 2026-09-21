// Europass CV example — Irish (ga).
// Persona of Éireannach nationality.  Demonstrates lang="ga" end to end.
// Gender option used here: "male"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "ga",
  title: "Curriculum Vitae — Seán Ó Briain",
  author: "Seán Ó Briain",

  name: "Seán Ó Briain",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("ga").at("photo-alt"),
  address: "Example Street 1",
  city: "Baile Átha Cliath",
  phone: "+00 000 000 000",
  email: "ga@europass.example",
  nationality: "Éireannach",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Ard-innealtóir bogearraí",
      organization: "European Tech Solutions",
      location: "Baile Átha Cliath",
      description: [- Stiúir foireann sé innealtóir ar sheirbhísí cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "MSc sa Ríomheolaíocht",
      organization: "Coláiste na Tríonóide",
      location: "Baile Átha Cliath",
    ),
  ),

  mother-tongue: "Gaeilge",
  other-languages: (
    (lang: "Béarla", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Baile Átha Cliath",
  signature-date: "2025",
)
