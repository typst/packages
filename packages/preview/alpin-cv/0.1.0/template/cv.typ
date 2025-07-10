#import "../package.typ": *
#import "../common.typ": *

#show: cv.with(
  theme: theme,
  photo: "photo.png",

  contact: 
  [
    = JOHN DOE
    == Developer, developer, developer
    *
    #grid(
      columns: (1em, 1fr), gutter: 0.5em, align: (center, left),
      [_🎂_],[31.12.1999 #h(1fr) _🌍_ Nationality],
      [_🏠_],[123 Maint Street, NY 10001 #h(1fr) _📞_  +852 1234 5678],
      [_✉️_],[contact\@me.com #h(1fr) _#link[X]_ john-doe-000000 #h(1fr) #link("in") John_Doe]
    )
    *
  ],

  aside: [
    #show heading.where(level: 2): set text(fill: theme.icon-color)

    = EDUCATION
    == #lorem(3)
    #cal[08.2367 - 01.2370] \
    School of #lorem(2)

    = TECH. STACK
    #tags[
      - ASM
      - C/C++
      - Fortran
      - Lisp
      
      #v(theme.tag-separator)
      - Node.JS
      - Laravel
      - Spring Boot
      - GTK
    ]
    #v(theme.section-separator)
    = TOOLS
    #tags[
      - Git
      - Github
      - Docker
      - Kubernetes
      #v(theme.tag-separator)
      - PostgreSQL
      - MySQL
      - Oracle
      #v(theme.tag-separator)
      - IntelliJ
      - VSCode
      - Eclipse

    ]
   #v(theme.section-separator)


    = LANGUAGES
    #table(
      [English],[Fluent],
      [German],[Proficient],
      [Mandarin],[proficient],
      [Japanese],[Basic]
    )<langs>
    #v(theme.section-separator)


    = HOBBIES
    #tags[
      - Traveling
      - Photography
      - Cinephile
      - Theater
    ]
    
    = REFERENCES
    == Marie Sue
    #lorem(2) \
    #lorem(1) \
    #lorem(3) 
    #v(theme.section-separator)
    
    = FORMATIONS
    == Oracle
    #calloc([01.2100],[Moon])
    Oracle Certified Professional \
    Java SE 5300 Programmer \
    #v(theme.section-separator)

  ]
)

= ABOUT ME
==
_#lorem(30)_

= PROFESSIONAL EXPERIENCE
#set line(length:100%, stroke: (paint: theme.body-color, thickness:0.5pt))

== Software Engineer #h(1fr) _Microsoft_
#calloc([09.2020 -- now],[Cyberport, HK])
#tags[
  - C\#
  - .NET
  - ASP
  - Azure
]
#lorem(30)
- #lorem(10)
- #lorem(18)
- #lorem(12)
- #lorem(5)

#line()

== Co-Founder,CTO #h(1fr) _Supersoft #lorem(6)_
#cal[2018 -- 2020] #h(1fr) _*#lorem(4)*_ #h(1.5em) #loc[Seatle, US]
#lorem(35)

#lorem(20)

#line()

== Software Engineer #h(1fr) _Google_
#calloc([07.2013 -- 04.2018],[Paris, FR])
#tags[
  - Java
  - Spring Boot
  - Kotlin
  - PostgreSQL
]

#lorem(20)
- #lorem(11)
- #lorem(8)
- #lorem(15)
- #lorem(30)
- #lorem(21)
