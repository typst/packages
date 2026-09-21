// Europass CV example — Hungarian (hu).
// Persona of Magyar nationality.  Demonstrates lang="hu" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "hu",
  title: "Curriculum Vitae — Nagy Anna",
  author: "Nagy Anna",

  name: "Nagy Anna",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("hu").at("photo-alt"),
  address: "Example Street 1",
  city: "Budapest",
  phone: "+00 000 000 000",
  email: "hu@europass.example",
  nationality: "Magyar",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Vezető szoftverfejlesztő",
      organization: "European Tech Solutions",
      location: "Budapest",
      description: [- Hat fős mérnökcsapatot irányított cloud-native szolgáltatások fejlesztésében.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "MSc informatika",
      organization: "BME",
      location: "Budapest",
    ),
  ),

  mother-tongue: "Magyar",
  other-languages: (
    (lang: "Angol", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Budapest",
  signature-date: "2025",
)
