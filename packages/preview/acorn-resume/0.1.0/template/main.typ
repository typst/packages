#import "@preview/acorn-resume:0.1.0":*

#let name = "Charlie Kelmeckis"
#let email = "wallflower24@example.com"
#let github = "https://github.com/wallflower24"
#let linkedin = "https://www.linkedin.com/in/charlie-kelmeckis"
#let personal_site = "https://wallflower.me"

#show: resume.with(
  author: name,
  margin: (
    x: 1.5cm,
    y: 1.5cm,
  ),
  font: "Calibri",
  font_size: 11pt,
  link_style: (
    underline: true,
    color: black,
  )
)

#header(
  name: name,
  contacts: (
   ("mailto:" + email, email),
   (github, "github.com/wallflower24"),
   (linkedin, "linkedin.com/in/charlie-kelmeckis"),
   (personal_site, "wallflower.me"),
  )
)

== Experience
#exp(
  role: "Software Engineer",
  date: "Jun 2025 - Present",
  organization: "Stripe",
  location: "San Francisco, CA",
  details: [
    - Led migration of legacy authentication system to OAuth 2.0, improving security for 2M+ merchants
    - Reduced API latency by 25% through implementing Redis caching layer and query optimization
    - Mentored 2 new engineers and conducted technical interviews for backend engineering candidates
  ]
)

#exp(
  role: "Software Engineering Intern",
  date: "Jun 2024 - Aug 2024",
  organization: "Meta",
  location: "Menlo Park, CA",
  details: [
    - Developed real-time notification system serving 50M+ daily active users using React and GraphQL
    - Optimized database queries reducing average response time by 40% through indexing and caching strategies
    - Collaborated with cross-functional team of 8 engineers to ship 3 major features to production
  ],
)

#exp(
  role: "Research Assistant",
  date: "Jan 2024 - Present",
  organization: "Stanford AI Lab",
  location: "Stanford, CA",
  details: [
    - Conducted research on large language model efficiency under Prof. Jane Smith
    - Implemented novel pruning techniques reducing model size by 30% while maintaining 95% accuracy
    - Co-authored paper submitted to NeurIPS 2025 on attention mechanism optimization
  ],
)

#exp(
  role: "Software Engineering Intern",
  date: "May 2022 - Aug 2022",
  organization: "Amazon",
  location: "Seattle, WA",
  details: [
    - Built internal dashboard for monitoring AWS Lambda performance metrics using TypeScript and React
    - Integrated with CloudWatch API to provide real-time insights for 200+ microservices
    - Reduced manual monitoring time by 60% through automated alerting system
  ],
)

== Skills
#pad(
  top: 0.15em,
  [
    *Languages:* Python, JavaScript/TypeScript, Java, C++, SQL, Go \
    *Frameworks/Libraries:* React, Node.js, Express, Django, Flask, TensorFlow, PyTorch, pandas \
    *Tools/Databases/Platforms:* Git, Docker, Kubernetes, AWS, MongoDB, PostgreSQL, Redis, GraphQL \
  ]
)

== Projects
#project(
  name: "CodeCollab",
  technologies: ("React", "Node.js", "WebSocket", "MongoDB"),
  liveUrl: "https://codecollab-demo.com",
  repoUrl: "https://github.com/wallflower24/codecollab",
  details: [
    - Real-time collaborative code editor with syntax highlighting and live cursor tracking
    - Supports 10+ programming languages with integrated code execution sandbox
    - Handles 1000+ concurrent users with optimized WebSocket architecture
  ],
)

#project(
  name: "ML Pipeline Optimizer",
  technologies: ("Python", "TensorFlow", "Docker", "Kubernetes"),
  repoUrl: "https://github.com/wallflower24/ml-optimizer",
  details: [
    - Automated hyperparameter tuning framework reducing model training time by 45%
    - Containerized deployment pipeline supporting distributed training across GPU clusters
    - Open-sourced with 500+ stars and adopted by 3 research labs
  ],
)

== Education
#edu(
  degree: "Master of Science in Computer Science",
  date: "Sep 2023 - May 2025",
  institution: "Stanford University",
  gpa: "3.85",
  location: "Stanford, CA",
)

#edu(
  degree: "Bachelor of Science in Computer Science",
  date: "Aug 2019 - May 2023",
  institution: "University of California, Berkeley",
  gpa: "3.72",
  location: "Berkeley, CA",
)
