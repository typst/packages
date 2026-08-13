#import "@preview/heading-resume:0.1.0": (
  contact, entry, entry-section, resume, skill, skill-section,
)

// All sample content below is fictional. Replace it with your own details.
#show: resume.with(
  name: [Avery Example],
  contacts: (
    contact([Example City]),
    contact([avery\@example.com], url: "mailto:avery@example.com"),
    contact([example.com/avery], url: "https://example.com/avery"),
    contact([professional profile], url: "https://example.com/profile"),
  ),
  profile: [
    Product-minded software engineer who turns complex systems into clear, dependable tools.
    Experienced across data products, developer platforms, and collaborative technical leadership.
  ],
  main-sections: (
    entry-section(
      [Selected Projects],
      (
        entry(
          [Open Data Explorer],
          organisation: [Independent project],
          dates: [2025–Present],
          subtitle: [data systems · product engineering],
          body: (
            [Built an accessible workspace for exploring public datasets and documenting repeatable analyses.],
            [Designed a typed data pipeline with clear provenance, validation, and useful failure messages.],
            [Worked with early users to simplify onboarding and prioritize high-value workflows.],
          ),
        ),
        entry(
          [Field Notes],
          organisation: [Community technology project],
          dates: [2024–2025],
          subtitle: [offline-first tools · information design],
          body: (
            [Created a fast offline application for collecting, organizing, and sharing structured observations.],
            [Reduced sync conflicts through an explicit change model and focused usability testing.],
          ),
        ),
        entry(
          [Design System Audit],
          organisation: [Example Systems],
          dates: [2024],
          subtitle: [accessibility · interface architecture],
          body: (
            [Mapped inconsistent interface patterns and proposed a smaller set of reusable components.],
            [Paired accessibility findings with practical fixes and clear ownership.],
          ),
        ),
      ),
    ),
    skill-section(
      [Skills],
      (
        skill([Programming], [Python · Rust · TypeScript · SQL]),
        skill(
          [Methods],
          [Data modeling · API design · testing · accessibility],
        ),
        skill([Tools], [Linux · Git · containers · continuous integration]),
        skill([Languages], [English · Dutch]),
      ),
    ),
  ),
  aside-sections: (
    entry-section(
      [Education],
      (
        entry(
          [MSc Computer Science],
          organisation: [Example Institute of Technology],
          dates: [2023–2025],
          subtitle: [Example City],
          body: [*Focus:* Human-centered systems and applied machine learning.],
        ),
        entry(
          [BSc Information Science],
          organisation: [Sample University],
          dates: [2020–2023],
          subtitle: [Sample Town],
          body: [*Activities:* Student mentor and open-source contributor.],
        ),
      ),
      compact: true,
    ),
    skill-section(
      [Interests],
      (
        skill([Practice], [Open source · civic technology]),
        skill([Outside work], [Cycling · printmaking]),
      ),
    ),
    entry-section(
      [Community],
      (
        entry(
          [Volunteer mentor],
          organisation: [Example Code Club],
          dates: [2022–Present],
          body: [Monthly project feedback for early-career developers.],
        ),
      ),
      compact: true,
    ),
  ),
  full-sections: (
    entry-section(
      [Experience],
      (
        entry(
          [Software Engineer],
          organisation: [Example Systems],
          dates: [2025–Present],
          body: (
            [Shipped data-heavy product features with designers, researchers, and customer teams.],
            [Improved release confidence through focused integration tests and observable services.],
          ),
        ),
        entry(
          [Developer Intern],
          organisation: [Sample Studio],
          dates: [2023–2024],
          body: (
            [Built internal tools that shortened content review and reduced repetitive manual work.],
          ),
        ),
        entry(
          [Teaching Assistant],
          organisation: [Sample University],
          dates: [2022–2023],
          body: (
            [Guided small-group programming labs and wrote concise debugging exercises.],
          ),
        ),
      ),
      compact: true,
      inline-organisation: true,
    ),
  ),
)
