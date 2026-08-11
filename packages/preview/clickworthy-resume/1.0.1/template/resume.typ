#import "@preview/clickworthy-resume:1.0.1": *

// Personal Information
#let name = "Jordan Michaels"
#let email = "jordan.michaels@example.com"
#let github = "github.com/jordan-devhub"
#let linkedin = "linkedin.com/in/jordan-michaels"
#let contacts = (
  [#link("mailto:" + email)[#email]],
  [#link("https://" + github)[#github]],
  [#link("https://" + linkedin)[#linkedin]],
)
#let location = ""

// Professional Summary
#let summary = ""

// Resume configuration
#let theme = rgb("#26428b")
#let font = "New Computer Modern"
#let fontSize = 11pt
#let lang = "en"
#let margin = (
  top: 1cm,
  bottom: 0cm,
  left: 1cm,
  right: 1cm,
)

// Resume Header and configuration
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

// Education
= Education
#edu(
  institution: "Carnegie Mellon University",
  date: "Sep 2023 - Jun 2025",
  location: "Pittsburgh, PA",
  degrees: (
    ("M.S.", "Computer Systems"),
  ),
  gpa: "3.81",
  extra: "",
)

#edu(
  institution: "University of Texas at Austin",
  date: "Aug 2018 - May 2023",
  location: "Austin, TX",
  degrees: (
    ("B.S.", "Software Engineering"),
    ("Minor", "Cognitive Science"),
  ),
  gpa: "3.97",
  extra: "",
)

// Experience
= Experience
#exp(
  title: "Platform Engineering Intern",
  organization: "Bitstream Networks",
  date: "May 2024 - Aug 2024",
  location: "Denver, CO",
  details: [
    - Designed and deployed a real-time telemetry pipeline for edge network routers using Go and Protobuf.
    - Developed high-throughput sync agents across distributed nodes using gRPC and Redis streams.
    - Created Verilog modules to validate MAC-level packet timings on custom FPGA NICs for load testing.
  ]
)

#exp(
  title: "Firmware Intern",
  organization: "Atlas Devices",
  date: "Jun 2023 - Sep 2023",
  location: "Boston, MA",
  details: [
    - Implemented drivers and diagnostics for a custom USB audio subsystem on a Cortex-M7 platform.
    - Built Python automation scripts for multidevice firmware upgrade pipelines and JTAG verification.
    - Validated board-level signal integrity with oscilloscope captures and SPI timing analyzers.
  ]
)

#exp(
  title: "Undergraduate Lab Assistant",
  organization: "University of Texas at Austin",
  date: "Aug 2021 - Dec 2022",
  location: "Austin, TX",
  details: [
    - Assisted with instructional support for algorithms, data structures, and discrete math courses.
    - Led peer tutoring sessions and created practice exams for midterm review.
  ],
  hide: true
)

// Projects
= Projects
#exp(
  title: link("https://github.com/jordan-devhub/lunar-nav-bot")[Lunar Navigation Bot (Autonomous Systems)],
  details: [
    - Simulated and field-tested a planetary rover using Jetson Nano, LiDAR, and YOLOv6 for rock classification.
    - Used MQTT to coordinate movement commands with a relay station over intermittent mesh networks.
    - Placed among top finalists in the #link("https://www.hackster.io/entries/space-bots-2023")[*SpaceBot 2023 Challenge*].
  ]
)

#exp(
  title: link("https://github.com/jordan-devhub/speechsync")[SpeechSync Streamer (Real-Time Communication)],
  details: [
    - Created a voice chat system with on-the-fly transcription and translation via Whisper + MarianMT.
  ]
)

#exp(
  title: link("https://github.com/jordan-devhub/audio-amp-kit")[Portable Audio Amplifier Kit (Hardware Design)],
  details: [
    - Designed a 7W audio amplifier with integrated thermal shutdown and overcurrent protection.
  ],
)

// Awards
= Awards
#exp(
  title: "SpaceBot 2023 Finalist",
  details: [
    - Received for the #link("https://github.com/jordan-devhub/lunar-nav-bot")[Lunar Navigation Bot] project among 200+ submissions.
  ]
)

// Publications
// This template uses the `pub` function twice to display two publication entries.
// The `pub-list` function is more advanced and could be used instead to display a list of publications from a `.bib` or `.yml` file.
= Publications
#pub(
  authors: (
    "Taylor Chen",
    "Jordan Michaels",
    "Emily Zhang",
  ),
  bold-author: "Jordan Michaels",
  title: "Lightweight Neural Pruning for Speech Tasks on Low-Power Devices",
  venue: "ACM UbiComp",
  year: "2024",
  doi-link: "doi.org/10.48550/arXiv.2404.00987",
)

#pub(
  authors: (
    "Jordan Michaels",
    "Alice Smith",
  ),
  bold-author: "Jordan Michaels",
  title: "Optimizing Edge AI Workflows for Low-Latency Inference",
  venue: "IEEE Edge Computing",
  year: "2023",
  doi-link: "doi.org/10.1109/EDGECOMP.2023.1234567",
  extra: "Best Paper Award",
)

// Skills
= Skills
#skills((
  ("Expertise", (
    [Edge Computing],
    [Network Protocols],
    [Robotics Systems],
    [FPGA Toolchains],
    [Embedded Audio],
    [Multilingual NLP],
    [System Monitoring],
    [CI/CD Automation],
  )),
  ("Software", (
    [PyTorch],
    [TensorFlow Lite],
    [OpenCV],
    [KiCad],
    [Docker],
    [Kubernetes],
    [Zephyr RTOS],
    [Vivado],
    [gRPC],
    [Git],
    [JIRA],
    [WireShark],
    [Linux],
  )),
  ("Languages", (
    [Python],
    [C/C++],
    [Rust],
    [Bash],
    [MATLAB],
    [VHDL],
    [Verilog],
    [TypeScript],
  )),
))
