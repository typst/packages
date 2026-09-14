#import "@preview/linked-cv:0.0.1": *

#show: linked-cv.with(
  firstname: "Your",
  lastname: "Name",
  socials: (
    email: "hello@example.com",
    mobile: "01234 567890",
    github: "your-github-username",
    linkedin: "your-linkedin-username",
  ),
)

#set text(size: 8pt, hyphenate: false)
#set par(justify: true, leading: 0.52em)

#typography.summary[
  #lorem(30)
]

#components.section("Experience")

#components.employer-info(
  logo: "example/img/openai.svg",
  name: "OpenAI",
  duration: ("02-2024", "current"),
)

#frame.connected-frames(
  "github",
  (
    title: [International Startups Lead],
    duration: ("05-2025", "current"),
    body: [
      #components.workstream(
        title: "Sora",
        tech-stack: ("python", "fastapi", "typescript", "tailwind", "svelte", "mapbox", "postgresql", "drizzle", "gcp", "terraform", "docker")
      )
      - Deployed global scale infrastructure and services to teams across the world build the apps of the future.
      - Presented technical proposals to executive leadership, securing \$5M budget approval for infrastructure modernization initiative spanning two fiscal years.
    ]
  ),
  (
    title: [Software Engineering Lead],
    duration: ("01-2025", "05-2025"),
    body: [
      #components.workstream(
        title: "GPT-4",
        tech-stack: ("python", "fastapi", "typescript", "postgresql", "gcp", "terraform", "docker")
      )

      - Developed automated testing framework using Python and Selenium, reducing manual testing time by 60% and improving code coverage across three major product releases while mentoring two junior engineers on best practices.
      - Led cross-functional team of 8 engineers to deliver cloud migration project two weeks ahead of schedule, resulting in 40% reduction in infrastructure costs.
      - Implemented machine learning algorithm for predictive maintenance that decreased equipment downtime by 35% and saved approximately \$200,000 annually in operational expenses.
    ]
  ),
  (
    title: [Senior Software Engineer],
    duration: ("02-2024", "01-2025"),
    body: [
      #components.workstream(
        title: "GPT-4",
        tech-stack: ("typescript", "react", "gcp", "docker")
      )

      - Designed and deployed microservices architecture using Docker and Kubernetes, improving system scalability and reducing deployment time from hours to minutes.
      - Collaborated with product managers to define technical requirements for new mobile application, successfully launching to 50,000 users within first month.
      - Optimized database queries and indexing strategies, resulting in 70% improvement in application response time and enhanced user experience across platform.
      - Spearheaded adoption of CI/CD pipeline using Jenkins and GitLab, automating build and deployment processes for 15 repositories.
    ]
  ),
)



#components.employer-info(
  logo: "example/img/palantir.svg",
  name: "Palantir",
  duration: ("09-2023", "02-2024"),
)

#frame.connected-frames(
  "palantir",
  (
    title: [Forward Deployed Engineer],
    duration: ("09-2023", "02-2024"),
    body: [
      #components.workstream(
        title: "Palantir",
        tech-stack: ("rust", "typescript", "react", "sass", "gcp")
      )
      - Built data visualization dashboards using Tableau and PowerBI, enabling stakeholders to make data-driven decisions and track key performance indicators.
      - Researched emerging technologies and presented findings to leadership team, influencing technology stack decisions for next-generation product development roadmap.
    ]
  )
)



#components.employer-info(
  logo: "example/img/github.svg",
  name: "GitHub",
  duration: ("08-2022", "09-2023"),
)

#frame.connected-frames(
  "github",
  (
    title: [Full Stack Software Engineer],
    duration: ("03-2023", "09-2023"),
    body: [
      #components.workstream(
        title: "GitHub Copilot",
        tech-stack: ("python", "fastapi", "typescript", "postgresql", "gcp", "terraform", "docker")
      )

      - Developed automated testing framework using Python and Selenium, reducing manual testing time by 60% and improving code coverage across three major product releases while mentoring two junior engineers on best practices.
      - Led cross-functional team of 8 engineers to deliver cloud migration project two weeks ahead of schedule, resulting in 40% reduction in infrastructure costs.
      - Implemented machine learning algorithm for predictive maintenance that decreased equipment downtime by 35% and saved approximately \$200,000 annually in operational expenses.
      - Implemented security best practices including encryption, authentication protocols, and vulnerability scanning, achieving SOC 2 compliance for organization.
      - Automated deployment processes using Terraform and Ansible, reducing configuration errors by 80% and improving infrastructure consistency.
    ]
  ),
  (
    title: [Engineering Intern],
    duration: ("08-2022", "03-2023"),
    body: [
      #components.workstream(
        title: "GitHub Codespaces",
        tech-stack: ("typescript", "react", "gcp", "docker")
      )

      - Designed and deployed microservices architecture using Docker and Kubernetes, improving system scalability and reducing deployment time from hours to minutes.
      - Collaborated with product managers to define technical requirements for new mobile application, successfully launching to 50,000 users within first month.
      - Optimized database queries and indexing strategies, resulting in 70% improvement in application response time and enhanced user experience across platform.
      - Spearheaded adoption of CI/CD pipeline using Jenkins and GitLab, automating build and deployment processes for 15 repositories.
    ]
  ),
)

#components.section("Qualifications")

#align(center)[
  #table(
    columns: (30%, 15%, 15%, 40%),
    align: (left, left, left, right),
    stroke: none,

    ..(("Qualification", "Grade", "Date", "Institution").map(typography.table-header)),

    table.hline(stroke: 0.5pt + colors.gray.lighten(60%)),

    ..(for item in (
      ("Mathematics", "1st", "—", "University of Exeter"),
      ("Machine Learning", "—", "09-2023", "Microsoft Azure"),
      ("Artificial Intelligence", "1st", "02-2025", "OpenAI"),
    ) {
      components.qualification(..item)
    })
  )
]
