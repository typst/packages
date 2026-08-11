#import "@preview/lavandula:0.1.0": *

#show: lavandula-theme

#set text(lang: "en")
#set document(
  title: "John Doe (CV)",
  author: "John Doe",
  date: none,
)

#cv(
  sidebar-position: "left",
  sidebar: [
    = John Doe
    ==== Software Engineer

    #contact-list((
      (icon: "at", icon-solid: true, text: link("mailto:john@doe.com")[john\@doe.com]),
      (icon: "linkedin", text: link("https://linkedin.com/in/john-doe-818817")[linkedin.com/in/john-doe-818817]),
      (icon: "pencil", text: link("https://blog.johndoe.com/")),
      (icon: "phone", text: "(123) 456-789"),
    ))

    #sidebar-section(title: "About me")[
      #set par(justify: true)
      #show par: it => block(width: 100%, it)

      Creative and detail-oriented Software Engineer with over #highlight[5 years of experience] building responsive web applications and dynamic backend services. 
      
      Passionate about #highlight[clean code], #highlight[user-first design], and #highlight[scalable solutions]. I thrive in fast-paced environments and love collaborating across teams to bring ideas to life.
    ]

    #sidebar-section(title: "Technical skills")[
      #skill-group(
        name: "Frontend Development",
        icon: "chrome",
        skills: (
          "HTML5",
          "CSS3",
          "JavaScript (ES6+)",
          "TypeScript",
          "React",
          "Vue.js",
        )
      )

      #skill-group(
        name: "Backend Development",
        icon: "python",
        skills: (
          "Node.js",
          "Express.js",
          "Python",
          "PHP",
          "Django",
          "FastAPI",
          "REST",
          "GraphQL",
        )
      )

      #skill-group(
        name: "Databases",
        icon: "database",
        skills: (
          "MySQL",
          "SQLite",
          "MongoDB",
          "Redis",
          "PostgreSQL",
          "Sequelize",
          "TypeORM",
          "Database design",
          "Normalization",
        )
      )

      #skill-group(
        name: "DevOps & Cloud",
        icon: "cloud",
        icon-solid: true,
        skills: (
          "GitLab CI/CD",
          "AWS",
          "EC2",
          "Lambda",
          "S3",
          "CloudWatch",
          "Nginx",
          "Bash",
        )
      )

      #skill-group(
        name: "Tools",
        icon: "tools",
        skills: (
          "Git",
          "Docker",
          "Figma",
          "Jira",
          "Typst",
        )
      )
    ]
    
    #sidebar-section(title: "Languages")[
      #skill-levels((
        // Example flag icons from https://github.com/gosquared/flags/tree/master/flags/flags-iso/shiny/64 (under MIT license)
        (icon: image("assets/flags/gb.png"), text: "English", level: 100%),
        (icon: image("assets/flags/fr.png"), text: "French", level: 60%),
      ))
    ]
  ],
  main-content: [
    #section(title: "Experience")[
      #section-element(
        title: "Senior Full Stack Developer @ Web World Digital",
        info: [_2021 --- Current_],
        [
          Part of the Core Web Applications team, leading development efforts on a customer-facing SaaS platform and collaborating closely with UI/UX designers. 
          #set text(size: sizes.text-s2)
          #icon-list((
            (icon: "wrench", text: [Led migration of legacy Angular frontend to modern React stack.]),
            (icon: "rocket", text: [Architected scalable REST API used by over #highlight[150K monthly active users].]),
            (icon: "graduation-cap", text: [Mentored junior developers and introduced weekly code review practices.]),
          ))
        ],
      )

      #section-element(
        title: "Web Developer @ Ultimate Tech Solutions",
        info: [_2018 --- 2021_],
        [
          Joined a startup building HIPAA-compliant medical scheduling software.
          #set text(size: sizes.text-s2)
          #icon-list((
            (icon: "scroll", text: [Wrote Python scripts to automate test coverage reports and API contract checks.]),
            (icon: "react", text: [Built UI components using React and Redux, including calendar widgets and modals.]),
            (icon: "shield-halved", text: [Gained exposure to secure coding practices and healthcare data privacy standards.]),
          ))
        ],
      )

      #section-element(
        title: "Software Engineering Intern @ Mad Tech",
        info: [_2017_],
        lorem(20),
      )

    ]

    #section(title: "Achievements")[
      #section-element(title: "Awards")[
        #set text(size: sizes.text-s2)
        #icon-list((
          (icon: "trophy", text: [#highlight[Winner of Crazy Hackathon (2023)]: built a smart application to form campus study groups based on subject, schedule and location.]),
          (icon: "medal", text: [#highlight[OpenAI Hackathon finalist (2022)]: team project using AI for real-time code documentation generation. Helped a nonprofit increase organic traffic by 180% via Next.js SSR tweaks.]),
        ))
      ]

      #section-element(title: "Projects")[
        #set text(size: sizes.text-s2)
        #icon-list((
          (icon: "pepper-hot", text: [MyMealz: a React Native app to plan, share and rate meals (#highlight[10K+ downloads]).]),
          (icon: "star", icon-solid: true, text: [AI-Powered Portfolio Analyzer: built a tool using GPT-4 API to give feedback on resumes.]),
        ))
      ]

      #section-element(title: "Contributions")[
        #set text(size: sizes.text-s2)
        #icon-list((
          (icon: "github", text: [Regular contributor to `react-hook-form` and `is-even` on GitHub.]),
          (icon: "gitlab", text: [Submitted over 40 PRs across 10+ public repositories.]),
        ))
      ]
    ]

    #section(title: "Education")[
      #section-element-advanced(
        title: "Hope's Peak Academy",
        info-top-left: "2018",
        info-top-right: "Paris, France",
        icon: fa-icon("circle-half-stroke"),
        [
          #set text(size: sizes.text-s2)
          _B.S. in Computer Science_ (#highlight[GPA 4.0])
          #icon-list((
            (icon: "graduation-cap", text: [Relevant courses: Data Structures, Algorithms, Web Application Development, Computer Networks, Operating Systems, Databases & Information Systems]),
            (icon: "futbol", text: [Activities: Coding Club (President), Ice Skating, Teaching Assistant]),
          ))
        ],
      )

      #section-element-advanced(
        title: "Certificate in Cloud Architecture",
        info-top-left: "2022",
        [
          #set text(size: sizes.text-s2)
          _Google Cloud Professional Track_
        ],
      )
    ]
  ],
)
