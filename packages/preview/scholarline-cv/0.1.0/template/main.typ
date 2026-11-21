// Anonymous sample CV. Replace every placeholder with your own information.
// Fonts: for the intended look, add Inter (https://rsms.me/inter/) to your project or system,
// including InterDisplay-Bold.ttf for the name. Without it, Noto Sans CJK SC is used.
#import "@preview/scholarline-cv:0.1.0": *

#show: cv.with(
  name: "Your Name",
  subtitle: "Computer Science Researcher · Example University",
  contacts: (
    contact("Google Scholar", "https://scholar.google.com", icon: "scholar"),
    contact("GitHub", "https://github.com", icon: "github"),
    contact("Homepage", "https://example.com", icon: "web"),
    contact("Email", "mailto:you@example.com", icon: "email"),
  ),
)

#section("Education")[
  #education(
    institution: "Example University",
    degree: "B.S. in Computer Science",
    dates: "2023 – 2027",
    location: "City, Country",
    details: "GPA: 3.90/4.00 · Dean's List",
    body: [- Selected coursework: Machine Learning, Algorithms, Computer Vision],
  )
]

#section("Publications")[
  #publication(
    title: "Adaptive Planning for Multimodal Research Agents",
    authors: [Your Name, Alex Researcher, Jamie Example],
    venue: "Preprint, 2026",
    links: ((label: "paper", url: "https://example.com/paper"), (label: "code", url: "https://github.com")),
  )
]

#section("Research Experience")[
  #experience(
    institution: "Laboratory for Intelligent Systems",
    role: "Research Intern",
    advisor: "Prof. Example Advisor",
    dates: "May 2026 – Present",
    body: [
      - Designed a modular evaluation framework for multimodal agents.
      - Analyzed efficiency–accuracy trade-offs across tasks.
    ],
  )
]

#section("Selected Projects")[
  #project(
    name: "Open Research Toolkit",
    role: "Maintainer",
    tech: "Python, PyTorch",
    dates: "2025 – Present",
    links: ((label: "link", url: "https://github.com"),),
  )
]

#section("Awards & Honors")[
  #award(name: "Undergraduate Research Fellowship", date: "2026")
  #award(name: "University Merit Scholarship", date: "2025")
]

#section("Skills")[
  #skill-line(label: "Programming", items: [Python, Java, C++])
  #skill-line(label: "Frameworks & Tools", items: [PyTorch, Transformers, Git, Linux, Typst])
  #skill-line(label: "Languages", items: [English, Mandarin])
]
