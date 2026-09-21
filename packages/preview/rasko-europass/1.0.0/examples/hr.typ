// Europass CV example — Croatian (hr).
// Persona of Hrvat nationality.  Demonstrates lang="hr" end to end.
// Gender option used here: "male"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "hr",
  title: "Curriculum Vitae — Ivan Horvat",
  author: "Ivan Horvat",

  name: "Ivan Horvat",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("hr").at("photo-alt"),
  address: "Example Street 1",
  city: "Zagreb",
  phone: "+00 000 000 000",
  email: "hr@europass.example",
  nationality: "Hrvat",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Viši softverski inženjer",
      organization: "European Tech Solutions",
      location: "Zagreb",
      description: [- Vodio je tim od šest inženjera na cloud-native uslugama.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Magistar informatike",
      organization: "Sveučilište u Zagrebu",
      location: "Zagreb",
    ),
  ),

  mother-tongue: "Hrvatski",
  other-languages: (
    (lang: "Engleski", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Zagreb",
  signature-date: "2025",
)
