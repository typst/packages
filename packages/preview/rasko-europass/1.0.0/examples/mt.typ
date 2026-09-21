// Europass CV example — Maltese (mt).
// Persona of Maltija nationality.  Demonstrates lang="mt" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "mt",
  title: "Curriculum Vitae — Marija Borg",
  author: "Marija Borg",

  name: "Marija Borg",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("mt").at("photo-alt"),
  address: "Example Street 1",
  city: "Valletta",
  phone: "+00 000 000 000",
  email: "mt@europass.example",
  nationality: "Maltija",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Inġiniera tas-softwer senjor",
      organization: "European Tech Solutions",
      location: "Valletta",
      description: [- Mexxet tim ta' sitt inġiniera fuq servizzi cloud-native.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Master fl-Informatika",
      organization: "Università ta' Malta",
      location: "Valletta",
    ),
  ),

  mother-tongue: "Malti",
  other-languages: (
    (lang: "Ingliż", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Valletta",
  signature-date: "2025",
)
