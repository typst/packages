#import "@preview/typographic-resume:0.1.0": *

// To learn about theming, see https://github.com/tsnobip/typst-typographic-resume?tab=readme-ov-file#theme
// make sure you have installed the fonts you want to use
#show: resume.with(
  theme: (
    // margin: 26pt,
    // font: "Libre Baskerville",
    // font-size: 8pt,
    // font-secondary: "Roboto",
    // font-tertiary: "Montserrat",
    // text-color: rgb("#3f454d"),
    // gutter-size: 4em,
    // main-width: 6fr,
    // aside-width: 3fr,
    // profile-picture-width: 55%,
  ),
  first-name: "Paul",
  last-name: "Dupont",
  profession: "Software Engineer",
  bio: [
    Experienced software engineer with a passion for developing innovative programs that expedite the efficiency and effectiveness of organizational success.],
  // profile-picture: image("./images/profile_pic_example.jpg"), // provide a profile picture here
  aside: {
    section(
      "Contact",
      {
        set image(width: 8pt)
        contact-entry(
          github-icon,
          link("https://github.com/pauldupont/", "pauldupont"),
        )
        line(stroke: 0.1pt, length: 100%)
        contact-entry(
          phone-icon,
          link("tel:+33 6 78 90 12 34", "+33 6 78 90 12 34"),
        )
        line(stroke: 0.1pt, length: 100%)
        contact-entry(
          email-icon,
          link("mailto:pauldupont@example.com", "pauldupont@example.com"),
        )
      },
    )

    section(
      "Main public contributions",
      {
        set text(font: "Roboto", size: 8pt)
        stack(
          spacing: 8pt,
          link(
            "https://github.com/tsnobip/typst-typographic-resume",
            "tsnobip/typst-typographic-resume",
          ),
          link(
            "https://github.com/typst/typst",
            "typst/typst",
          ),
          link(
            "https://github.com/rescript-lang/rescript",
            "rescript-lang/rescript",
          ),
          link(
            "https://github.com/pauldupont/devops-toolkit",
            "pauldupont/devops-toolkit",
          ),
          link(
            "https://github.com/pauldupont/real-time-chat-app",
            "pauldupont/real-time-chat-app",
          ),
        )
      },
    )

    section(
      "Tech Stack",
      {
        set text(font: "Roboto", size: 8pt)
        stack(
          spacing: 8pt,
          "Python",
          "JavaScript",
          "ReScript",
          "React",
          "Node.js",
          "Django",
          "PostgreSQL",
          "Docker",
          "Kubernetes",
        )
      },
    )

    section(
      "Languages",
      {
        language-entry("English", "Native")
        language-entry("Spanish", "Fluent")
        language-entry("German", "Intermediate")
      },
    )

    section(
      "Interests",
      {
        set text(size: 7pt)
        stack(
          spacing: 8pt,
          "Open Source Contributions",
          "Road biking",
          "Traveling",
        )
      },
    )
  },
)


#section(
  theme: (
    space-above: 0pt,
  ),
  "Work Experiences",
  {
    work-entry(
      theme: (
        space-above: 0pt,
      ),
      timeframe: "Jan 2024 - Today",
      title: "Senior Software Engineer",
      organization: "Tech Innovators Inc.",
      location: "Lyon, FR",
      [
        Led a team of developers to design and implement scalable web applications.
        Improved system performance by 30% through code optimization.
        Mentored junior developers, fostering a culture of continuous learning.
        Spearheaded the migration of legacy systems to modern cloud-based infrastructure.
      ],
    )
    work-entry(
      timeframe: "Oct 2020 - December 2023",
      title: "Software Engineer",
      organization: "CodeCraft Solutions",
      location: "San Francisco, USA",
      [
        Developed and maintained RESTful APIs for client applications.
        Collaborated with cross-functional teams to deliver high-quality software.
        Implemented CI/CD pipelines, reducing deployment times by 40%.
        Conducted code reviews to ensure adherence to best practices and coding standards.
      ],
    )
    work-entry(
      timeframe: "Jul 2019 - Oct 2020",
      title: "Junior Software Engineer",
      organization: "NextGen Tech",
      location: "Tbilisi, GE",
      [
        Assisted in the development of e-commerce platforms.
        Wrote unit tests to ensure code reliability and maintainability.
        Participated in agile ceremonies, contributing to sprint planning and retrospectives.
        Researched and implemented new tools to improve development workflows.
      ],
    )
    work-entry(
      timeframe: "Nov 2018 - Jun 2019",
      title: "Intern",
      organization: "Startup Hub",
      location: "Paris, FR",
      [
        Supported the development team in debugging and testing applications.
        Gained hands-on experience with modern web technologies.
        Created technical documentation for internal tools and processes.
        Assisted in the deployment of a new customer-facing web application.
      ],
    )
    work-entry(
      timeframe: "Jun 2017 - Oct 2018",
      title: "Freelance Developer",
      organization: "Self-Employed",
      location: "Remote",
      [
        Designed and developed custom websites for small businesses.
        Provided technical support and maintenance for client projects.
        Built responsive and user-friendly interfaces using modern web technologies.
        Managed multiple projects simultaneously, ensuring timely delivery.
      ],
    )
    work-entry(
      timeframe: "Jan 2016 - May 2017",
      title: "Research Assistant",
      organization: "École des Mines de St-Étienne",
      location: "St-Étienne, France",
      [
        Conducted research on algorithms for optimizing large-scale systems.
        Published findings in peer-reviewed journals and presented at conferences.
        Developed prototypes to validate research concepts.
        Collaborated with a multidisciplinary team to achieve project goals.
      ],
    )
  },
)

#section(
  "Education",
  grid(
    columns: 2,
    column-gutter: default-theme.margin,
    education-entry(
      title: "MSc in Computer Science",
      institution: "École des Mines de St-Étienne, FR",
      timeframe: "2014 - 2017",
      [Focused on software engineering, algorithms, and data structures.],
    ),
    education-entry(
      title: "PhD in Artificial Intelligence",
      institution: "Seoul National University, KR",
      timeframe: "2017 - 2021",
      [Specialized in machine learning and natural language processing.],
    ),
  ),
)
