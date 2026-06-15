// Starter CV produced by `typst init @preview/altacv`. Edit in place.
//
// The full data schema is documented in the package README:
//   https://github.com/smur89/alta-typst#data-schema
//
// Every field below is optional except `basics.name`. Sections with
// empty input are skipped, so deleting an entry is enough to hide it.
//
// This file is also the canonical demo for the project — what
// renders as `examples/cv.png` (README static preview) and as
// `thumbnail.png` (Typst Universe package card).

#import "@preview/altacv:1.2.0": alta, avatar-placeholder // x-release-please-version

#let cv = (
  basics: (
    name: "Seán Ó Murchú",
    label: "Senior Software Engineer",
    summary: [
      Backend engineer with eight years of experience designing
      distributed, event-driven systems. Specialises in functional
      programming, observability, and developer experience.
    ],
    email: "sean@example.com",
    phone: "+353 1 555 0100",
    location: "Tallaght, Dublin",
    url: "https://seanomurchu.dev",
    // Drop or replace with your own image. `none` removes the
    // portrait; `read("your-photo.png", encoding: none)` embeds
    // bytes from a local file. `avatar-placeholder` is the
    // package's built-in silhouette.
    image: avatar-placeholder,
    profiles: (
      (network: "GitHub", username: "seanomurchu", url: "https://github.com/seanomurchu"),
      (network: "LinkedIn", username: "seanomurchu", url: "https://linkedin.com/in/seanomurchu"),
    ),
  ),

  focusAreas: (
    [Distributed systems and functional programming.],
  ),

  work: (
    (
      name: "Acme Corp",
      url: "https://acme.example.com",
      position: "Senior Software Engineer",
      location: "Dublin, Ireland",
      startDate: "2022-01",
      summary: [Platform team lead. Owns the event-sourcing stack.],
      highlights: (
        [Migrated a customer-facing monolith to event-driven services, halving p99 latency.],
        [Rolled out an event-sourcing platform now used by four product teams.],
      ),
    ),
    (
      name: "Liffey Labs",
      position: "Software Engineer",
      location: "Remote",
      startDate: "2019-06",
      endDate: "2022-01",
      highlights: (
        [Shipped the first version of a SaaS product alongside a two-person team.],
        [Built the CI/CD pipeline that scaled the engineering org from 3 to 15.],
      ),
    ),
    (
      name: "Grand Canal Systems",
      position: "Software Engineer",
      location: "Dublin, Ireland",
      startDate: "2017-09",
      endDate: "2019-06",
      highlights: (
        [Led the migration of services from VMs to Kubernetes.],
      ),
    ),
  ),

  skills: (
    (name: "Languages", keywords: ("Scala", "Haskell", "Go")),
    (name: "Infra",     keywords: ("Kafka", "AWS", "Kubernetes")),
  ),

  languages: (
    (language: "English", fluency: "Native"),
    (language: "Irish",   fluency: "Professional Working"),
  ),

  education: (
    (
      institution: "Tallaght Institute of Technology",
      url: "https://example.edu/tit",
      studyType: "M.Sc. in Computer Science",
      startDate: "2015",
      endDate: "2017",
    ),
  ),

  certificates: (
    (
      name: "Certified Kubernetes Administrator",
      issuer: "CNCF",
      date: "2023-09",
      url: "https://www.cncf.io/training/certification/cka/",
    ),
    (
      name: "Certified Kubernetes Application Developer",
      issuer: "CNCF",
      date: "2024-04",
      url: "https://www.cncf.io/training/certification/ckad/",
    ),
  ),

  awards: (
    (
      title: "Best Paper — Distributed Systems Track",
      awarder: "EuroSys",
      date: "2024-09",
      url: "https://example.com/eurosys",
    ),
  ),

  publications: (
    (
      name: "Event Sourcing in Practice",
      publisher: "Personal Blog",
      releaseDate: "2024-06-15",
      url: "https://example.com/posts/event-sourcing",
    ),
  ),

  projects: (
    (
      name: "open-source: kafka-idempotent",
      url: "https://example.com/projects/kafka-idempotent",
      description: "Small Scala library for idempotent consumers.",
      startDate: "2023-04",
      keywords: ("Scala", "Kafka", "OSS"),
      highlights: (
        [Underpins the awarded EuroSys paper above.],
      ),
    ),
  ),

  volunteer: (
    (
      organization: "CoderDojo Dublin",
      position: "Mentor",
      startDate: "2020-09",
      highlights: (
        [Weekly mentoring sessions for 10–14 year-olds learning to code.],
      ),
    ),
  ),

  interests: (
    (name: "Music", keywords: ("Trad", "Jazz")),
    (name: "Sport", keywords: ("Hurling", "Climbing")),
  ),
)

// Visual preferences for this starter. The portrait stacks above a
// centred header; the rest takes the template's shipped defaults
// (teal accent, two-column layout, long-form dates). Edit any
// preference you like — `alta(cv, preferences: (...))` accepts any
// subset, with unknown keys panicking so typos surface immediately.
#let preferences = (
  imagePosition: "center",
  imageStackOrder: "above",
  headerTextAlign: "center",
)

#alta(cv, preferences: preferences)
