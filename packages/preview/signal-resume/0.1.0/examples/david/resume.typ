#import "../../template/resume.typ": resume

#show: resume.with(
  name: "David Sasson",
  body_font: "Arial",
  headline: "Backend-Focused Full-Stack & Platform Engineer",
  list_spacing: 0.90em,
  contact: (
    "Jerusalem, Israel",
    link("tel:+972522626684")[+972 52 262 6684],
    link("mailto:davids2289@gmail.com")[davids2289\@gmail.com],
    link("https://www.linkedin.com/in/david-sasson-developer/")[linkedin.com/in/david-sasson-developer],
  ),
  summary: [
    Self-taught, backend-focused full-stack engineer with a track record of joining new product areas early, turning ambiguous requirements into production systems, building shared foundations that help products and teams grow, and earning trust across Engineering, Product, QA, and Design.
  ],
  skills: (
    (label: "Languages & Frameworks", items: ("TypeScript", "JavaScript", "Node.js", "NestJS", "React")),
    (label: "Backend", items: ("REST APIs", "Microservices", "Kafka", "RabbitMQ", "Mongoose", "SDK development")),
    (label: "Data", items: ("PostgreSQL", "MongoDB", "Redis", "TypeORM", "Data modeling")),
    (label: "Engineering", items: ("System design", "Platform engineering", "Performance optimization", "Testing")),
  ),
  experience: (
    (
      company: "Cyera",
      role: "Software Engineer",
      location: "Tel Aviv, Israel",
      dates: "Jun 2025–Present",
      description: none,
      bullets: (
        [Served for seven months as AI Assets' only full-stack engineer, partnering with multiple backend engineers and Product, QA, and Design as the product grew into a standalone group.],
        [Built AI Assets' product pages and reusable full-stack foundations supporting multiple asset types.],
        [Shipped Scan Windows and Scan Control end to end across database schema and migrations, backend-for-frontend APIs, evaluation logic, settings UI, filters, and row actions.],
        [Resolved high-impact on-call incidents across the platform, including tracing a production OOM to database query fan-out and restoring baseline latency.],
        [Built reusable SDKs for other teams and served as a key contributor to the Platform group's Claude Code skills and plugins.],
      ),
    ),
    (
      company: "Panorays",
      role: "Full-Stack Developer",
      location: "Tel Aviv, Israel",
      dates: "Oct 2021–May 2025",
      description: none,
      bullets: (
        [Spent two years on one of Panorays' two platform teams, building data integrations and full-stack product flows while improving server performance and data models.],
        [Then joined a newly formed cyber-posture assessment team as its first developer, owning core features including a risk policy tool and workflow automation.],
        [Helped standardize reusable UI patterns through the internal component-library task force.],
      ),
    ),
  ),
  featured_sections: (),
  education: (),
  sections: (
    (
      title: "Education",
      kind: "labeled",
      items: (
        (label: "Freie Universität Berlin", value: "M.A., Near and Middle Eastern Studies, 2016–2018"),
        (label: "Ben-Gurion University", value: "B.A., Psychology and Near and Middle Eastern Studies, 2013–2016"),
      ),
    ),
  ),
)
