// Multi-page demonstration of every documented feature surface. Free
// to spill onto a second or third page — this is the reference for a
// fully-populated CV, distinct from `template/cv.typ` (the one-page
// canonical demo that drives `examples/cv.png` and `thumbnail.png`).
//
// What this renders:
//   • Header: name (uppercase), label, summary, contact bar covering
//     every channel — email, phone, structured `basics.location`,
//     `basics.url`, and every built-in profile network.
//   • `meta` populates the PDF metadata date / keywords / description.
//   • Work: open-ended + closed roles, `summary` preamble, highlights.
//   • Volunteer: distinct organisation/position shape.
//   • Skills: two pill-tag groups, exercises tag overflow.
//   • Languages: every input form — `fluency` strings, integer
//     `rating`, fractional half-dot `rating`.
//   • Education: `studyType` + `score` + `courses` pills, plus the
//     `area` fallback for entries missing `studyType`.
//   • Certificates: multi-issuer grouping with inline date + linked
//     pill (per-cert `date` and `url`), plus an issuer-less cert that
//     pools into the trailing unlabelled group.
//   • Awards: full entry with `url`, plus a title-only minimal entry.
//   • Projects: complete + ongoing + minimal + description-only.
//   • Publications: grouped by `type` (Articles, Books, Talks,
//     Conference Papers) — each subheading carries its own
//     type-specific icon — plus an untyped entry that falls under
//     `labels.articles`.
//   • Interests: structured `{name, keywords}` form.
//   • References: a populated entry plus an anonymous (no `name`)
//     quote — exercises the divider rule and the level-3 heading
//     above the italic quote.
//   • Preferences override: bundled tweaks demonstrating accent
//     palette, ISO-date formatting, custom maps provider, page footer,
//     and a non-default `maxRating` for the language scale.

#import "../lib.typ": alta, palettes, maps-providers, avatar-placeholder
#import "_dates.typ": today, ago

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
    // Structured location dict — `city`/`region`/`countryCode` are
    // joined with ", ", the other JSON Resume keys round-trip but
    // aren't rendered (a CV header isn't a mailing label).
    location: (
      address: "1 Sample Street",
      postalCode: "D24 X123",
      city: "Tallaght",
      region: "Dublin",
      countryCode: "IE",
    ),
    url: "https://seanomurchu.dev",
    image: avatar-placeholder,
    // Every built-in profile network so the icon set gets a full
    // visual sweep. `Link` is the generic-URL fallback.
    profiles: (
      (network: "LinkedIn",      username: "seanomurchu",      url: "https://linkedin.com/in/seanomurchu"),
      (network: "GitHub",        username: "seanomurchu",      url: "https://github.com/seanomurchu"),
      (network: "GitLab",        username: "seanomurchu",      url: "https://gitlab.com/seanomurchu"),
      (network: "Bluesky",       username: "@seanomurchu",     url: "https://bsky.app/profile/seanomurchu"),
      (network: "Mastodon",      username: "@sean@fosstodon.org", url: "https://fosstodon.org/@sean"),
      (network: "Medium",        username: "@seanomurchu",     url: "https://medium.com/@seanomurchu"),
      (network: "Stackoverflow", username: "seanomurchu",      url: "https://stackoverflow.com/u/1"),
      (network: "X",             username: "@seanomurchu",     url: "https://x.com/seanomurchu"),
      (network: "Link",          username: "talk recording",   url: "https://example.com/talk"),
    ),
  ),

  // PDF document metadata. `lastModified` accepts a bare ISO date or
  // a full timestamp; only the calendar part is used for `set
  // document(date:)`. Also surfaces optionally in a page footer when
  // `preferences.lastModifiedFooter: true`.
  meta: (
    canonical: "https://example.com/cv.json",
    version: "1.0.0",
    lastModified: today.display("[year]-[month]-[day]"),
  ),

  focusAreas: (
    [Distributed systems: Kafka, CDC, idempotent consumers, event sourcing.],
    [Functional programming and type-driven design in Scala and Haskell.],
    [Developer experience: tooling, CI/CD, observability.],
    [Engineering culture: ADRs, RFCs, mentoring.],
  ),

  work: (
    (
      name: "Acme Corp",
      url: "https://acme.example.com",
      position: "Senior Software Engineer",
      location: "Dublin, Ireland",
      startDate: ago(years: 4),
      // `endDate` omitted → renders as "Present".
      summary: [Platform team lead. Owns the event-sourcing stack
        underpinning the wider product surface.],
      highlights: (
        [Led the migration of a customer-facing monolith into a set of
          event-driven microservices, halving p99 latency.],
        [Designed and rolled out an event-sourcing platform now used by
          four product teams.],
        [Mentored three engineers from mid to senior level.],
      ),
    ),
    (
      name: "Liffey Labs",
      position: "Software Engineer",
      location: "Remote",
      startDate: ago(years: 7),
      endDate: ago(years: 5),
      highlights: (
        [Built and shipped the first version of a SaaS product from
          scratch alongside a two-person team.],
        [Introduced the CI/CD pipeline and developer-onboarding flow
          that scaled the engineering org from 3 to 15.],
      ),
    ),
  ),

  volunteer: (
    (
      organization: "CoderDojo Dublin",
      position: "Mentor",
      startDate: ago(years: 6),
      highlights: (
        [Weekly mentoring sessions for 10–14 year-olds learning to code.],
        [Curate the Scala / functional-programming track.],
      ),
    ),
  ),

  skills: (
    (name: "Languages", keywords: ("Scala", "Haskell", "Python", "Go", "Rust")),
    (name: "Infra",     keywords: ("Kafka", "AWS", "Terraform", "Docker", "Kubernetes")),
  ),

  // Languages exercise every supported input: named `fluency` strings
  // and numeric `rating` (with fractional half-dot precision).
  languages: (
    (language: "English",    fluency: "Native"),
    (language: "Irish",      fluency: "Professional Working"),
    (language: "French",     rating: 4),
    (language: "Portuguese", rating: 2.5),
  ),

  education: (
    (
      // Full entry with `studyType`, `score`, and `courses` pills.
      institution: "Tallaght Institute of Technology",
      url: "https://example.edu/tit",
      studyType: "M.Sc. in Computer Science",
      startDate: ago(years: 9, precision: "year"),
      endDate: ago(years: 7, precision: "year"),
      score: "Distinction",
      courses: ("Distributed Systems", "Type Theory", "Concurrency"),
    ),
    (
      // `area` fallback used when `studyType` is absent; no score.
      institution: "Trinity College Dublin",
      area: "Computer Science",
      startDate: ago(years: 12, precision: "year"),
      endDate: ago(years: 9, precision: "year"),
    ),
  ),

  // Multi-issuer grouping: two 2-cert issuer clusters (CNCF, AWS) get
  // their own labelled dashed divider; three singleton certs from
  // distinct issuers (Hashicorp, Linux Foundation, Google Cloud) pool
  // into a trailing unlabelled group. Each entry carries `date` + `url`
  // so the inline-date pill + linked pill features render.
  certificates: (
    (
      name: "Certified Kubernetes Administrator",
      issuer: "CNCF",
      date: ago(months: 34),
      url: "https://www.cncf.io/training/certification/cka/",
    ),
    (
      name: "Certified Kubernetes Application Developer",
      issuer: "CNCF",
      date: ago(months: 29),
      url: "https://www.cncf.io/training/certification/ckad/",
    ),
    (
      name: "AWS Solutions Architect — Professional",
      issuer: "AWS",
      date: ago(months: 38),
    ),
    (
      name: "AWS DevOps Engineer — Professional",
      issuer: "AWS",
      date: ago(months: 21),
    ),
    (
      // Singleton — pools into the trailing unlabelled group.
      name: "Hashicorp Terraform Associate",
      issuer: "Hashicorp",
      date: ago(months: 43),
    ),
    (
      // Second singleton, distinct issuer — joins the same trailing
      // group, demonstrating that the pool collects across issuers.
      name: "Certified Kubernetes Security Specialist",
      issuer: "Linux Foundation",
      date: ago(months: 27),
    ),
    (
      // Third singleton.
      name: "Google Cloud Professional Architect",
      issuer: "Google Cloud",
      date: ago(months: 31),
    ),
  ),

  // Full entry with `url`, plus a title-only minimal entry to
  // demonstrate the all-optional surface.
  awards: (
    (
      title: "Best Paper Award",
      date: ago(months: 21),
      awarder: "ScalaConf",
      url: "https://example.com/awards/scalaconf",
      summary: [For _Idempotent Kafka Consumers_.],
    ),
    (
      title: "Dean's List",
    ),
  ),

  // Every documented field combination: complete + ongoing + minimal
  // + description-only.
  projects: (
    (
      name: "Hyperion",
      description: "Distributed task scheduler in Rust",
      startDate: ago(months: 29),
      endDate: ago(months: 22),
      url: "https://github.com/seanomurchu/hyperion",
      keywords: ("Rust", "Tokio", "gRPC"),
      highlights: (
        [Handled 10k tasks/s on a single node.],
        [Designed an idempotent retry protocol.],
      ),
    ),
    (
      // Ongoing — `endDate` omitted, renders as "Present".
      name: "Crucible",
      description: "Migration tool for legacy databases",
      startDate: ago(months: 21),
      highlights: ([Schema diffing across PostgreSQL and MySQL.],),
    ),
    (
      // Minimal — only the required field.
      name: "Quill",
    ),
    (
      // Description + keywords, no URL / dates / highlights.
      name: "Tinkerbell",
      description: "Tiny IRC bot",
      keywords: ("Lua",),
    ),
  ),

  // Structured `{name, keywords}` shape — same as `skills[]` but
  // semantically a personal-interests block. Coexists with the prose
  // `focusAreas` block above.
  interests: (
    (name: "Music",  keywords: ("Trad", "Jazz")),
    (name: "Sport",  keywords: ("Hurling", "Climbing")),
    (name: "Travel", keywords: ("Japan", "Iceland")),
  ),

  // Populated entry + an anonymous (no `name`) quote — exercises both
  // the named-referee path and the fallback-to-bare-quote path.
  references: (
    (
      name: "Dr Ada Lovelace",
      reference: [
        Seán is a calm, methodical engineer who left every system he
        touched in a better state than he found it. Recommended without
        reservation.
      ],
    ),
    (
      reference: "Pragmatic, curious, unfailingly kind — would hire again in a heartbeat.",
    ),
  ),

  // Four groups: explicit `Articles`, `Books`, `Talks`, `Conference
  // Papers`, plus one untyped entry that falls into the default
  // `labels.articles` group. Each rendered subheading carries its
  // type-specific icon (newspaper / book / microphone / newspaper /
  // newspaper) — see `_default_publication_icons` in lib.typ.
  publications: (
    (
      name: "Event Sourcing in Practice",
      type: "Articles",
      publisher: "Personal Blog",
      releaseDate: ago(years: 2, precision: "day"),
      url: "https://example.com/posts/event-sourcing",
      summary: [A walk-through of idempotent Kafka consumers and the
        replay strategy that ships with them.],
    ),
    (
      name: "Idempotent Kafka Consumers at Scale",
      type: "Conference Papers",
      publisher: "EuroSys",
      releaseDate: ago(months: 26),
      url: "https://example.com/eurosys",
    ),
    (
      name: "Designing for Failure",
      type: "Talks",
      publisher: "ScalaIO",
      releaseDate: ago(months: 33),
      url: "https://example.com/talks/failure",
    ),
    (
      name: "Functional Domain Modelling",
      type: "Books",
      publisher: "Self-published",
      releaseDate: ago(years: 4, precision: "year"),
    ),
    (
      // No `type` → falls into the default `labels.articles` group.
      name: "Untyped Note",
      releaseDate: ago(months: 29),
      url: "https://example.com/untyped",
    ),
  ),
)

// Preferences override exercising a meaningful slice of the API
// surface — accent palette swap, ISO-date short formatter, OSM maps
// provider, auto page footer (renders on multi-page output), and a
// non-default `maxRating: 6` for a CEFR-style language scale.
//
// `interests` is moved into the left column to fill space below the
// long-form blocks; the rest of the layout takes the shipped defaults.
#alta(cv, preferences: (
  accent: palettes.navy,
  dateFormat: "[day padding:none] [month repr:short] [year]",
  mapsProvider: maps-providers.osm,
  pageFooter: "auto",
  maxRating: 6,
  leftColumnSections: ("work", "volunteer", "projects", "publications", "interests"),
  rightColumnSections: (
    "focusAreas", "skills", "languages", "education", "certificates", "awards", "references",
  ),
))
