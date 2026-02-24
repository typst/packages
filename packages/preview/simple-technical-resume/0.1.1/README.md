# Simple Technical Resume
<div align="center">Version 0.1.1</div>

A simple technical resume template designed to fit within a page and work well with ATS. Inspiration was taken from [Jake's Resume](https://github.com/jakegut/resume/) and [sb2nov's Resume](https://github.com/sb2nov/resume/).

I created this Typst template because I was maintaining 8 resumes over LaTEX and making formatting/alignment changes took forever to achieve over all the LaTEX files (over 2-3 hours of endless trial & error). It took me over 30+ hours to create a perfectly formatted resume in 1 page (in LaTEX, using MikTex), being as dense as possible, while keeping margins barely visible. I had received positive feedback about the readibility of the resume and it was ATS-friendly as well. When I found about Typst, I was tempted to create a similar resume in Typst with the added benefit of maintenance being easier and templating being possible (unlike LaTEX).


# Sample Resume

![example-resume](https://raw.githubusercontent.com/steadyfall/simple-technical-resume-template/main/example.png)


# Quickstart
A bare-bones template to start making your resume is given below:
```typst
#import "@preview/simple-technical-resume:0.1.1": *

// Put your personal information here
#let name = "Dwight Schrute"
#let phone = "+1 (123) 456-7890"
#let email = "dschrute@dundermifflin.com"
#let github = "dwight-schrute"
#let linkedin = "dwight-schrute"
#let personal-site = "dwightschrute.com"

// Since the following arguments are within the `with` block,
// you can remove/comment any argument to fallback to the preset value and/or
// remove it. 
#show: resume.with(
  top-margin: 0.45in,
  font: "New Computer Modern",
  personal-info-font-size: 9.2pt,
  author-position: center,
  personal-info-position: center,
  author-name: name,
  phone: phone,
  email: email,
  website: personal-site,
  linkedin-user-id: linkedin,
  github-username: github
)

// Use custom-title function instead of first-level headings to customize the
// size between two sections by specifying the `spacingBetween` argument.
// https://typst.app/docs/reference/layout/length/

#custom-title("Education")[
  #education-heading(
    "Scranton University",                    // institution
    "Scranton, PA",                           // location
    "Bachelor of Arts",                       // degree
    "Business Administration",                // major
    datetime(year: 1992, month: 9, day: 1),   // start-date
    datetime(year: 1998, month: 4,  day: 1)   // end-date
  )[
    - Awarded "Most Determined Student" in senior year
  ]
  // More educational qualifications ... 
]

#custom-title("Experience")[  
  #work-heading(
    "Regional Manager",                     // title
    "Dunder Mifflin",                       // company
    "Scranton, PA",                         // location
    datetime(year:2013, month:5, day:1),    // start-date
    "Present"                               // end-date
  )[
    - Led a team of 10+ employees, boosting office productivity and morale
    - Maintained the highest sales average, outperforming competitors despite market challenges
    - Implemented innovative security measures to protect the office from threats, including criminal activity and wildlife intrusions
    - Successfully negotiated client contracts, increasing annual revenue by 20%
  ]
  // More experiences ...
]

#custom-title("Projects")[
  #project-heading(
    "Schrute Farms (Bed and Breakfast)",      // name
    // "Next.js, TailwindCSS, Postgres",      // stack
    // "schrutefarms.com"                     // project_url
  )[
    - Established and managed a family-run agro-tourism business offering unique activities such as table-making workshops, beet farming tours, and hay rides
    - Increased guest bookings by 50% through effective online marketing and guest engagement
    - Maintained a 4.9/5 guest satisfaction rating on travel review platforms
  ]
  // More projects ...
]

// Use `skills` function to create list with custom rules surrounding indentation and alignment.
// It is specifically for lists directly inside the custom-title section.
#custom-title("Skills")[
  #skills()[
    - *Professional Skills:* Sales Expertise, Leadership, Conflict Resolution, Strategic Planning, Negotiation
    - *Personal Traits:* Hardworking, Alpha Male, Jackhammer, Merciless, Insatiable
    - *Specialized Talents:* Karate (Black Belt), Jujitsu, Werewolf Hunting, Table Making
  ]
]
```