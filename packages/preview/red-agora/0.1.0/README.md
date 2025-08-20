# ENSIAS Report Typst Template

A Typst template to quickly make reports for projects at ENSIAS. This template was created based on our reports that we also made for our projects.

## What does it provide?

For now, it provides a first page style that matches the common reports style used and encouraged at ENSIAS.

It also provides a style for first level headings to act as chapters.

More improvements will come soon.

## Usage

```typ
#import "@preview/red-agora:0.1.0": project

#show: project.with(
  title: "Injecting a backdoor in the xz library and taking over NASA and SpaceX spaceship tracking servers (for education purposes only)",
  subtitle: "Second year internship report",
  authors: (
    "Amine Hadnane",
    "Mehdi Essalehi"
  ),
  school-logo: "images/ENSIAS.svg",
  company-logo: "images/company.svg",
  mentors: (
    "Pr. John Smith (Internal)",
    "Jane Doe (External)"
  ),
  jury: (
    "Pr. John Smith",
    "Pr. Jane Doe"
  ),
  branch: "Software Engineering",
  academic-year: "2077-2078",
  french: false // Use french instead of english
)

// Put then your content here
```
