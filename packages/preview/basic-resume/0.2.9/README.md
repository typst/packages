# Basic Resume

<div align="center">Version 0.2.9</div>

This is a template for a simple resume. It is intended to be used as a good starting point for quickly crafting a standard resume that will properly be parsed by ATS systems. Inspiration is taken from [Jake's Resume](https://github.com/jakegut/resume) and [guided-resume-starter-cgc](https://typst.app/universe/package/guided-resume-starter-cgc/). I'm currently a college student and was unable to find a Typst resume template that fit my needs, so I wrote my own. I hope this template can be useful to others as well.

## Sample Resume

![example resume](https://raw.githubusercontent.com/stuxf/basic-typst-resume-template/main/example-resume.png)

## Quick Start

A barebones resume looks like this, which you can use to get started.

```typst
#import "@preview/basic-resume:0.2.9": *

// Put your personal information here, replacing mine
#let name = "Stephen Xu"
#let location = "San Diego, CA"
#let email = "stxu@hmc.edu"
#let github = "github.com/stuxf"
#let linkedin = "linkedin.com/in/stuxf"
#let phone = "+1 (xxx) xxx-xxxx"
#let personal-site = "stuxf.dev"

#show: resume.with(
  author: name,
  // All the lines below are optional. 
  // For example, if you want to to hide your phone number:
  // feel free to comment those lines out and they will not show.
  location: location,
  email: email,
  github: github,
  linkedin: linkedin,
  phone: phone,
  personal-site: personal-site,
  accent-color: "#26428b",
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: left,
  personal-info-position: left,
)

/*
* Lines that start with == are formatted into section headings
* You can use the specific formatting functions if needed
* The following formatting functions are listed below
* #edu(dates: "", degree: "", gpa: "", institution: "", location: "")
* #work(company: "", dates: "", location: "", title: "")
* #project(dates: "", name: "", role: "", url: "")
* #extracurriculars(activity: "", dates: "")
* There are also the following generic functions that don't apply any formatting
* #generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "")
* #generic-one-by-two(left: "", right: "")
*/
== Education

#edu(
  institution: "Harvey Mudd College",
  location: "Claremont, CA",
  dates: dates-helper(start-date: "Aug 2023", end-date: "May 2027"),
  degree: "Bachelor's of Science, Computer Science and Mathematics",
)
- Cumulative GPA: 4.0\/4.0 | Dean's List, Harvey S. Mudd Merit Scholarship, National Merit Scholarship
- Relevant Coursework: Data Structures, Program Development, Microprocessors, Abstract Algebra I: Groups and Rings, Linear Algebra, Discrete Mathematics, Multivariable & Single Variable Calculus, Principles and Practice of Comp Sci

== Work Experience

#work(
  title: "Subatomic Shepherd and Caffeine Connoisseur",
  location: "Atomville, CA",
  company: "Microscopic Circus, Schrodinger's University",
  dates: dates-helper(start-date: "May 2024", end-date: "Present"),
)
- more bullet points go here

// ... more headers and stuff below
```
