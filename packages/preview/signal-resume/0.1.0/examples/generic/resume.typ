#import "../../template/resume.typ": resume

#show: resume.with(
  name: "Jordan Lee",
  body_font: "Arial",
  headline: "Senior Software Engineer | Backend & Platform Systems",
  contact: (
    "Tel Aviv, Israel",
    link("tel:+972505550142")[+972 50 555 0142],
    link("mailto:jordan.lee@example.com")[jordan.lee\@example.com],
    link("https://linkedin.com/in/jordanlee")[linkedin.com/in/jordanlee],
    link("https://github.com/jordanlee")[github.com/jordanlee],
  ),
  summary: [
    Senior software engineer with 11+ years building backend, platform, and cybersecurity products across cloud and distributed systems. Leads architecture from high-level design through delivery, translating product requirements into reliable services and data models. Known for cross-team technical direction, mentoring engineers, and improving performance, operational resilience, and delivery speed.
  ],
  skills: (
    (label: "Languages", items: ("TypeScript", "JavaScript", "SQL", "Python")),
    (label: "Backend", items: ("Node.js", "NestJS", "REST APIs", "Kafka", "Microservices")),
    (label: "Data", items: ("PostgreSQL", "ClickHouse", "Redis", "TypeORM", "Data modeling")),
    (label: "Cloud & Infrastructure", items: ("AWS", "Docker", "Kubernetes", "CI/CD", "Observability")),
    (label: "Architecture", items: ("Distributed systems", "Event-driven systems", "System design", "Cybersecurity products")),
  ),
  experience: (
    (
      company: "Northstar Security",
      role: "Senior Software Engineer",
      location: "Tel Aviv, Israel",
      dates: "Jul 2021–Present",
      description: none,
      bullets: (
        [Designed and led a backend-controlled configuration architecture for heterogeneous AI assets, enabling new asset types to reuse shared page and card infrastructure with minimal frontend changes.],
        [Owned high-level design and delivery of an event-driven ingestion platform processing more than 40 million security events per day across Kafka, Node.js, PostgreSQL, and ClickHouse.],
        [Redesigned query paths and data models for a high-volume investigation workflow, reducing p95 response time by 63% while preserving tenant isolation and auditability.],
        [Coordinated delivery across backend, frontend, product, architecture, and UI/UX partners, turning ambiguous requirements into sequenced technical milestones for a strategic product launch.],
        [Mentored six engineers through design reviews, onboarding, and incident follow-ups, establishing reusable patterns for observability, testing, and operational ownership.],
      ),
    ),
    (
      company: "Example Cloud Systems",
      role: "Software Engineer",
      location: "Remote",
      dates: "Jan 2017–Jun 2021",
      description: none,
      bullets: (
        [Built multi-tenant backend services in TypeScript and NestJS that supported more than 200 enterprise customers and sustained 99.95% availability.],
        [Led migration of synchronous workflows to event-driven processing, improving failure isolation and cutting peak request latency by 45%.],
        [Introduced automated deployment checks, service-level dashboards, and structured incident reviews, reducing repeat production incidents by 30%.],
      ),
    ),
    (
      company: "Sample Digital",
      role: "Full-Stack Developer",
      location: "Haifa, Israel",
      dates: "Jul 2013–Dec 2016",
      description: none,
      bullets: (
        [Delivered customer-facing web applications and Node.js APIs from discovery through production, with ownership spanning data modeling, testing, and deployment.],
        [Created shared application components and engineering documentation that shortened onboarding and reduced duplicated implementation across three product teams.],
      ),
    ),
  ),
  featured_sections: (
    (
      title: "Selected Engineering Highlights",
      kind: "bullets",
      items: (
        [Created an open-source TypeScript toolkit for validating event schemas and generating typed consumers, adopted by multiple engineering teams and used in production services.],
        [Designed a reference architecture for secure AI-assisted workflows on AWS, covering model access, data boundaries, audit events, and failure handling.],
      ),
    ),
  ),
  education: (
    (institution: "Example University", credential: "B.Sc. in Computer Science", dates: "2009–2013"),
  ),
  sections: (
    (
      title: "Certifications",
      kind: "labeled",
      items: (
        (label: "AWS", value: "Certified Solutions Architect – Associate, 2024"),
        (label: "Security", value: "Cloud Security Professional Certification, 2023"),
      ),
    ),
    (
      title: "Additional Information",
      kind: "labeled",
      items: (
        (label: "Languages", value: "Hebrew (native), English (professional)"),
        (label: "Community", value: "Volunteer mentor for early-career software engineers"),
      ),
    ),
  ),
)
