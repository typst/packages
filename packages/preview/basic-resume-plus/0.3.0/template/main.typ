#import "@preview/basic-resume-plus:0.3.0": *

// Replace these sample values with your own.
#let name = "Stephen Xu"
#let phone = "+1 (xxx) xxx-xxxx"
#let email = "stxu@hmc.edu"
#let location = "San Diego, CA"
#let personal-site = "stuxf.dev"

#show: resume.with(
  author: name,
  accent-color: blue.darken(30%), // #005197
  font: "New Computer Modern",
  paper: "a4",
  author-position: center,
)

#contact-section(
  // Contact details are optional; remove any items or rows you don't need.
  values: (
    (
      tel-link(phone),
      mail-link(email),
      location,
      web-link(personal-site),
    ),
    (), // Add optional social links here.
  ),
  position: center,
)

/*
 * Lines that start with == are formatted into section headings
 * You can use the specific formatting functions if needed
 * The following formatting functions are listed below
 * #edu(degree: "", dates: "", institution: "", location: "", institution-top: false, location-top: false)
 * #work(title: "", dates: "", company: "", location: "")
 * #project(name: "", role: "", url: "", dates: "")
 * #certificate(name: "", issuer: "", url: "", date: "")
 * #extracurricular(activity: "", dates: "")
 * #extracurricular-list(data: ())
 * #skills-table(data: (:))
 * There are also the following generic functions that don't apply any formatting
 * #generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "")
 * #generic-one-by-two(left: "", right: "")
 */

== Personal Profile

Undergraduate student in Computer Science at Harvey Mudd College with a strong foundation in
computer science and mathematics. Combining rigorous academic training with hands-on experience in
software engineering, systems security, and open-source development, I am passionate about building
reliable, well-documented software. I am seeking opportunities in software engineering and security
where I can leverage my analytical mindset and technical versatility to build robust, scalable
systems.

== Education

#edu(
  institution: "Harvey Mudd College",
  location: "Claremont, CA",
  dates: dates-helper("Aug 2023", "May 2027"),
  degree: "Bachelor of Science, Computer Science and Mathematics",
)
- Cumulative GPA: 4.0\/4.0 | Dean's List, Harvey S. Mudd Merit Scholarship, National Merit
  Scholarship
- Relevant Coursework: Data Structures, Program Development, Microprocessors, Abstract Algebra:
  Groups and Rings, Linear Algebra, Discrete Mathematics, Multivariable & Single Variable Calculus,
  Principles and Practice of Comp Sci

== Work Experience

#work(
  title: "Subatomic Shepherd and Caffeine Connoisseur",
  location: "Atomville, CA",
  company: "Microscopic Circus, Schrodinger's University",
  dates: dates-helper("May 2024", "Present"),
)
- Played God with tiny molecules, making them dance to uncover the secrets of the universe
- Convinced high-performance computers to work overtime without unions, reducing simulation time by
  50%
- Wowed a room full of nerds with pretty pictures of invisible things and imaginary findings

#work(
  title: "AI Wrangler and Code Ninja",
  location: "Silicon Mirage, CA",
  company: "Organic Stupidity Startup",
  dates: dates-helper("Dec 2023", "Mar 2024"),
)
- Taught robots to predict when (and how much!) humans will empty their wallets at the doctor's
  office
- Developed HIPAA-compliant digital signatures, because doctors' handwriting wasn't illegible enough
  already
- Turned spaghetti code into a gourmet dish, making other interns drool with envy

#work(
  title: "Code Conjurer Intern",
  location: "Silicon Suburb, CA",
  company: "Bits & Bytes Consulting",
  dates: dates-helper("Jun 2022", "Aug 2022"),
)
- Developed a cross-platform mobile app that turned every user into a potential paparazzi
- Led a security overhaul, heroically saving the company from the menace of "password123"

== Projects

#project(
  name: "Hyperschedule",
  role: "Maintainer",
  dates: dates-helper("Nov 2023", "Present"),
  url: "hyperschedule.io",
)
- Maintain open-source scheduler used by 7000+ users at Claremont Consortium with TypeScript, React
  and MongoDB
  - Manage PR reviews, bug fixes, and coordinate with college for releasing scheduling data
- Ensure 99.99% uptime during peak loads of 1M daily requests during course registration through
  redundant servers

== Skills
#skills-table(
  data: (
    "Programming Languages": [JavaScript, Python, C/C++, HTML/CSS, Java, Bash, R, Flutter, Dart],
    "Frameworks": [React, Astro, Svelte, Tailwind CSS],
    "Developer Tools": [Git, UNIX, Docker, Caddy, NGINX],
    "Cloud Platforms": [Google Cloud Platform, Kubernetes, CI/CD],
  ),
)

== Extracurricular Activities
#extracurricular-list(
  data: (
    (
      "Founder of Les Amateurs, ranked fourth in the US and thirty-third globally on CTFTime",
      dates-helper("Jan 2021", "Present"),
    ),
    (
      "Organized AmateursCTF, with over 1,000 teams participating and more than 2,000 USD in prizes",
      "2023, 2024",
    ),
    (
      "Qualified for DEF CON CTF 32 and CSAW CTF, two leading international cybersecurity competitions",
      "Sep 2023",
    ),
    (
      "Volunteer test writer for Science Olympiad tournaments, including LA Regionals and SoCal State",
      dates-helper("2023"),
    ),
  ),
)
