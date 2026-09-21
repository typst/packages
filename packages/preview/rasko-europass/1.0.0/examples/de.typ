// Europass CV example — German (de).
// Persona of Deutsch nationality.  Demonstrates lang="de" end to end.
// Gender option used here: "male"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "de",
  title: "Curriculum Vitae — Lukas Müller",
  author: "Lukas Müller",

  name: "Lukas Müller",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("de").at("photo-alt"),
  address: "Example Street 1",
  city: "Berlin",
  phone: "+00 000 000 000",
  email: "de@europass.example",
  nationality: "Deutsch",
  date-of-birth: "01/01/1990",
  gender: "male",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Senior-Softwareentwickler",
      organization: "European Tech Solutions",
      location: "Berlin",
      description: [- Leitete ein Team von sechs Ingenieuren für cloud-native Dienste.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Master in Informatik",
      organization: "TU Berlin",
      location: "Berlin",
    ),
  ),

  mother-tongue: "Deutsch",
  other-languages: (
    (lang: "Englisch", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Berlin",
  signature-date: "2025",
)
