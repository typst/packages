// Europass CV example — Greek (el).
// Persona of Ελληνίδα nationality.  Demonstrates lang="el" end to end.
// Gender option used here: "female"
#import "../lib.typ": cv-entry, europass-cv, l

#show: europass-cv.with(
  lang: "el",
  title: "Curriculum Vitae — Μαρία Παπαδοπούλου",
  author: "Μαρία Παπαδοπούλου",

  name: "Μαρία Παπαδοπούλου",
  photo: "assets/photo-placeholder.svg",
  photo-alt: l("el").at("photo-alt"),
  address: "Example Street 1",
  city: "Αθήνα",
  phone: "+00 000 000 000",
  email: "el@europass.example",
  nationality: "Ελληνίδα",
  date-of-birth: "01/01/1990",
  gender: "female",

  work-experience: (
    cv-entry(
      date-start: "2021", date-end: "",
      title: "Ανώτερη μηχανικός λογισμικού",
      organization: "European Tech Solutions",
      location: "Αθήνα",
      description: [- Ηγήθηκε ομάδας έξι μηχανικών σε cloud-native υπηρεσίες.],
    ),
  ),
  education: (
    cv-entry(
      date-start: "2013", date-end: "2015",
      title: "Μεταπτυχιακό στην Πληροφορική",
      organization: "ΕΚΠΑ",
      location: "Αθήνα",
    ),
  ),

  mother-tongue: "Ελληνικά",
  other-languages: (
    (lang: "Αγγλικά", listening: "C1", reading: "C1",
     interaction: "B2", production: "B2", writing: "C1"),
  ),
  digital-skills: [- Python, Docker, Kubernetes, PostgreSQL],

  signature-place: "Αθήνα",
  signature-date: "2025",
)
