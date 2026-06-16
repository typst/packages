// Showcase of the file-based labels workflow. Demonstrates that a
// caller can supply a complete translation as a separate TOML file
// and have it picked up by the template via `labels: toml(...)`.
//
// Body content is in Irish too so the rendered document reads
// end-to-end; the labels file (`labels-ga.toml`) supplies section
// headings, the "I láthair" suffix for open-ended date ranges, and
// abbreviated Irish month names.
//
// Build locally with:
//   typst compile --root .. example_ga.typ example_ga.pdf

#import "../lib.typ": alta

#let cv = (
  basics: (
    name: "Caoimhe Ní Bhriain",
    label: "Innealtóir Bogearraí Sinsearach",
    summary: [
      Innealtóir bogearraí le taithí ar chórais dáilte agus ríomhaireacht
      neamh-fheidhmeach. Saineolas i Scala, Kafka, agus Kubernetes.
    ],
    email: "caoimhe@example.com",
    phone: "+353 1 555 0100",
    location: "Dún Laoghaire, Éire",
    profiles: (
      (network: "GitHub",   username: "caoimhe", url: "https://github.com/caoimhe"),
      (network: "LinkedIn", username: "caoimhe", url: "https://linkedin.com/in/caoimhe"),
    ),
  ),

  focusAreas: (
    [Córais dáilte agus ríomhaireacht neamh-fheidhmeach.],
  ),

  work: (
    (
      name: "Áras Bogearraí Teo.",
      position: "Príomh-innealtóir",
      location: "Baile Átha Cliath, Éire",
      startDate: "2022-01",
      // endDate omitted → renders as "I láthair" from labels-ga.toml
      highlights: (
        [Dhear córas Kafka don eagraíocht agus laghdaigh moill p99 faoi leath.],
        [Threoraigh foireann ardáin trí cheithre tháirge a sheoladh.],
      ),
    ),
    (
      name: "Saotharlanna Life",
      position: "Innealtóir Bogearraí",
      location: "Cian, Éire",
      startDate: "2019-06",
      endDate: "2021-12",
      highlights: (
        [Sheol an chéad leagan de tháirge SaaS le foireann beirte.],
      ),
    ),
  ),

  skills: (
    (name: "Teangacha", keywords: ("Scala", "Haskell", "Go")),
    (name: "Bonneagar", keywords: ("Kafka", "AWS", "Kubernetes")),
  ),

  languages: (
    (language: "Gaeilge",  fluency: "Native"),
    (language: "Béarla",   fluency: "Native"),
    (language: "Français", rating: 3),
  ),

  education: (
    (
      institution: "Ollscoil Bhaile Átha Cliath",
      studyType: "M.Sc. san Eolaíocht Ríomhaireachta",
      startDate: "2017",
      endDate: "2019",
    ),
  ),

  certificates: (
    (
      name: "Certified Kubernetes Administrator",
      issuer: "CNCF",
      date: "2023-06",
    ),
  ),
)

#alta(cv, labels: toml("labels-ga.toml"))
