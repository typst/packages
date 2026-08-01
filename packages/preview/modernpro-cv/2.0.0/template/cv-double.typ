#import "@preview/modernpro-cv:2.0.0": *

// Edit identity and contacts here. Keeping them beside the CV content makes
// this starter a self-contained document with no application-specific imports.
#let profile = (
  name: [Your Name],
  role: [Your Current Role],
  address: [City, Country],
  contacts: (
    (text: [you\@example.edu], link: "mailto:you@example.edu"),
    (text: [your-site.example], link: "https://your-site.example"),
    (text: [ORCID~0000-0000-0000-0000], link: "https://orcid.org/0000-0000-0000-0000"),
  ),
)

// Two-column variant. Prefer cv-single.typ for a full academic CV or for ATS
// parsing; this layout suits a one-page summary.
//
// For icons beside each contact, add `#import "@preview/fontawesome:0.6.2": fa-icon`
// and give any contact in the profile above an `icon:` field.
#show: cv.with(
  profile: profile,
  columns: 2,
  left: [
    #section("Research Focus")
    #summary[
      Two or three lines naming your area and the kind of question you ask.
    ]
    #section-gap

    #section("Methods")
    #detail-line(title: "Quantitative", content: [your quantitative methods])
    #detail-line(title: "Qualitative", content: [your qualitative methods])
    #detail-line(title: "Tools", content: [Python, R, SQL, Typst])
    #section-gap

    #section("Awards")
    #award(award: "Award Name", institution: "Awarding Body", date: "2024")
    #section-gap

    #section("Teaching and Service")
    #detail-line(title: "Teaching", content: [courses and supervision])
    #detail-line(title: "Service", content: [committees and review work])
  ],
  right: [
    #section("Academic Appointments")
    #experience(
      title: "Your Position",
      institution: [Institution],
      location: "City, Country",
      date: "2023-present",
      details: [
        - One line on what you lead, build, or supervise.
      ],
    )
    #section-gap

    #section("Education")
    #education(
      institution: [University],
      major: [PhD in Your Field],
      date: "2016-2020",
      location: "City, Country",
      description: [Thesis: your thesis title.],
    )
    #section-gap

    #section("Selected Publications")
    #entry(
      title: [Paper title],
      right: "2025",
      meta: [Author list, Journal Name 8(2)],
    )
    #section-gap

    #section("Research Funding")
    #entry(
      title: [Grant title],
      right: "2024-2027",
      meta: [Funder; your role],
      location: [Amount],
    )
  ],
)
