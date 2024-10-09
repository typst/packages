#import "@preview/vantage-cv:1.0.0": vantage-cv, styled-link, term, skill
#let configuration = yaml("configuration.yaml")


#vantage-cv(
  name: configuration.contacts.name,
  position: configuration.position,
  links: (
    (name: "email", link: "mailto:"+ configuration.contacts.email),
    (name: "website", link: configuration.contacts.website.url, display: configuration.contacts.website.displayText),
    (name: "github", link: configuration.contacts.github.url, display: configuration.contacts.github.displayText),
    (name: "linkedin", link: configuration.contacts.linkedin.url, display: configuration.contacts.linkedin.displayText),
    (name: "location", link: "", display: configuration.contacts.address)
  ),
  tagline: (configuration.tagline),
  [

    == Experience

    #for job in configuration.jobs [
      === #job.position \
      _#link(job.company.link)[#job.company.name]_ - #styled-link(job.product.link)[#job.product.name] \
      #term[#job.from --- #job.to][#job.location]

      #for point in job.description [
        - #point
      ]
    ]
    
  ],
  [
    == Objective

    #configuration.objective


    == Education

    #for edu in configuration.education [
      === #if edu.place.link != "" [
        #link(edu.place.link)[#edu.place.name]\
      ] else [
        #edu.place.name\
      ]

      #edu.from - #edu.to #h(1fr) #edu.location

      #edu.degree in #edu.major

    ]

    == Technical Expertise

    #for expertise in configuration.technical_expertise [
      #skill(expertise.name, expertise.level)
    ]

    == Skills/Exposure

    #for skill in configuration.skills [
      • #skill
    ]

    == Methodology/Approach
    #for method in configuration.methodology [
      • #method
    ]
    
    == Tools
    #for tool in configuration.tools [
      • #tool
    ]

    == Achievements/Certifications

    #for achievement in configuration.achievements [
      === #achievement.name
      \
      #achievement.description
    ]

  ]
)
