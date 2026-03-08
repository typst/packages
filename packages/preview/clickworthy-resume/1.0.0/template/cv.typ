#import "@preview/clickworthy-resume:1.0.0": *

// Personal Information
#let name = "Dr. Alex Morgan"
#let email = "alex.morgan@example.com"
#let github = "github.com/alexm-dev"
#let linkedin = "linkedin.com/in/alex-morgan"
#let contacts = (
  [#link("mailto:" + email)[#email]],
  [#link("https://" + github)[#github]],
  [#link("https://" + linkedin)[#linkedin]],
)
#let location = "San Francisco, CA"

// Professional Summary
#let summary = "Senior systems engineer and technology leader with over two decades of experience architecting large-scale embedded systems, real-time signal processing pipelines, and fault-tolerant platforms. Proven record in driving research-led innovation into production, mentoring engineering teams, and publishing peer-reviewed work in top-tier venues."

// Resume configuration
#let theme = rgb("#26428b")
#let font = "New Computer Modern"
#let fontSize = 11pt
#let lang = "en"
#let margin = (
  top: 1cm,
  bottom: 1cm,
  left: 1cm,
  right: 1cm,
)

#show: resume.with(
  author: name,
  location: location,
  contacts: contacts,
  summary: summary,
  theme-color: theme,
  font: font,
  font-size: fontSize,
  lang: lang,
  margin: margin,
)

// Skills
= Skills
#skills((
  ("Expertise", (
    [Distributed Systems],
    [Real-Time Operating Systems],
    [Signal Processing],
    [Embedded Security],
    [FPGA Architectures],
    [System-on-Chip Design],
    [Software Reliability],
    [Technical Leadership],
  )),
  ("Software", (
    [C/C++],
    [Rust],
    [SystemVerilog],
    [Matlab],
    [Linux Kernel],
    [Docker],
    [Kubernetes],
    [Jenkins],
    [gRPC],
    [Git],
    [Yocto Project],
  )),
  ("Languages", (
    [Python],
    [C/C++],
    [Rust],
    [Shell],
    [SystemVerilog],
    [VHDL],
  )),
))

// Experiences
= Experience
#exp(
  title: "Distinguished Engineer",
  organization: "Northwest Embedded Systems",
  date: "2012 - 2022",
  location: "San Jose, CA",
  details: [
    - Led architecture and design of a secure FPGA-based communications platform for aerospace clients.
    - Built a distributed sensor fusion system used in industrial robotics with >99.99% reliability.
    - Mentored a cross-functional team of 12 engineers, fostering internal leadership and publishing culture.
    - Drove internal R&D to productization cycle for real-time embedded analytics engine.
    - Co-authored 3 internal patents on low-power data routing and compression techniques.
  ]
)

#exp(
  title: "Senior Systems Engineer",
  organization: "Photonix Technologies",
  date: "2006 - 2012",
  location: "Mountain View, CA",
  details: [
    - Designed a firmware update system for remote industrial devices deployed in volatile environments.
    - Developed mixed-signal driver modules interfacing with custom ASICs and microcontrollers.
    - Improved inter-device communication protocols, reducing latency by 35% across product lines.
  ]
)

#exp(
  title: "Embedded Software Engineer",
  organization: "MicroNova Inc.",
  date: "2001 - 2006",
  location: "Austin, TX",
  details: [
    - Delivered firmware for low-latency DSP filters used in medical and automotive devices.
    - Ported real-time schedulers to custom embedded targets using bare-metal C.
  ]
)

// Publications
// This template uses the `pub-list` function to display a list of publications.
// It requires a `.bib` or `.yml` file with publication entries.
// The `pub` function is a simplified version that could be used instead to produce multiple publication entries by calling it multiple times.
= Publications
#pub-list(
  bib: bibliography("assets/publications.bib"),
  style: "ieee"
)

// Education
= Education
#edu(
  institution: "University of California, Berkeley",
  date: "1996 - 2001",
  location: "Berkeley, CA",
  degrees: (
    ("Ph.D.", "Electrical Engineering and Computer Sciences"),
  ),
  extra: "Advisor: Prof. Margaret Wang",
)

#edu(
  institution: "University of California, Berkeley",
  date: "1992 - 1996",
  location: "Berkeley, CA",
  degrees: (
    ("B.S.", "Electrical Engineering"),
  ),
  gpa: "3.92",
  extra: "Graduated with Honors (Summa Cum Laude)",
)
