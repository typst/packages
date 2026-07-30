#import "@preview/signal-resume:0.1.0": resume

// Replace the fictional content below with truthful evidence from your career.
#show: resume.with(
  name: "Alex Morgan",
  headline: "Backend-Focused Full-Stack & Platform Engineer",
  list-spacing: 0.90em,
  contact: (
    "City, Country",
    link("tel:+15550100")[+1 555 0100],
    link("mailto:alex.morgan@example.com")[alex.morgan\@example.com],
    link("https://www.linkedin.com/in/alex-morgan")[linkedin.com/in/alex-morgan],
  ),
  summary: [
    Backend-focused full-stack engineer with a track record of turning ambiguous product requirements into reliable systems, reusable infrastructure, and foundations that help teams deliver faster.
  ],
  skills: (
    (label: "Languages & Frameworks", items: ("TypeScript", "JavaScript", "Node.js", "React")),
    (label: "Backend", items: ("REST APIs", "Microservices", "Event-driven systems", "SDK development")),
    (label: "Data", items: ("PostgreSQL", "Redis", "Data modeling")),
    (label: "Engineering", items: ("System design", "Platform engineering", "Performance optimization", "Testing")),
  ),
  experience: (
    (
      company: "Northstar Security",
      role: "Software Engineer",
      location: "Remote",
      dates: "Jun 2023–Present",
      description: none,
      bullets: (
        [Delivered a new security product from early requirements through production in partnership with backend, product, QA, and design peers.],
        [Built reusable backend and frontend foundations that supported multiple product workflows without one-off implementations.],
        [Resolved high-impact on-call incidents by tracing failures across services, data access, and production infrastructure.],
        [Created shared SDKs and developer tooling that helped other engineering teams adopt platform capabilities consistently.],
      ),
    ),
    (
      company: "Atlas Cloud",
      role: "Full-Stack Developer",
      location: "City, Country",
      dates: "Jan 2020–May 2023",
      description: none,
      bullets: (
        [Built data integrations, APIs, and customer-facing workflows for a growing cloud platform.],
        [Improved shared data models and UI patterns, reducing duplicated implementation across product teams.],
      ),
    ),
  ),
  featured-sections: (),
  education: (),
  sections: (
    (
      title: "Education",
      kind: "labeled",
      items: (
        (label: "Example University", value: "B.Sc., Computer Science, 2016–2020"),
      ),
    ),
  ),
)
