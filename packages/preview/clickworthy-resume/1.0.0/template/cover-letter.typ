#import "@preview/clickworthy-resume:1.0.0": *

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

// Addressee Information
#let addressee-name = "Dr. Jane Smith"
#let addressee-institution = "Embedded Innovations Inc."
#let addressee-address = "123 Innovation Drive"
#let addressee-city = "Tech City"
#let addressee-state = "CA"
#let addressee-country = "USA"
#let addressee-zip = "90210"

// Resume configuration
#let date = datetime.today().display()
#let font = "New Computer Modern"
#let fontSize = 11pt
#let lang = "en"
#let margin = (
  top: 1cm,
  bottom: 1cm,
  left: 1cm,
  right: 1cm,
)

// Cover letter Header and configuration
#show: cover-letter.with(
  author: name,
  location: location,
  contacts: contacts,
  date: date,
  addressee-name: addressee-name,
  addressee-institution: addressee-institution,
  addressee-address: addressee-address,
  addressee-city: addressee-city,
  addressee-state: addressee-state,
  addressee-country: addressee-country,
  addressee-zip: addressee-zip,
  font: font,
  font-size: fontSize,
  lang: lang,
  margin: margin,
)

// Body of the cover letter
Dear #addressee-name

I am writing to apply for the Software Engineer position at #addressee-institution. As a fresh M.S. graduate in Computer Systems at Carnegie Mellon University, I am eager to bring my experience in embedded systems, networked platforms, and hardware-software integration to your innovative team. I was drawn to #addressee-institution's work in cutting-edge embedded technology, and I'm excited about the opportunity to contribute to impactful projects. In this letter, I would like to highlight how my technical experience, research, and project leadership make me a strong fit for this role.

During my internship at Bitstream Networks, I engineered a real-time telemetry system for edge routers using Go, Redis Streams, and gRPC. To ensure performance under high-throughput conditions, I developed sync agents and created Verilog modules for FPGA-based packet testing. This experience strengthened my ability to design scalable, distributed infrastructure that interfaces directly with hardware—something I see as core to your work at #addressee-institution. Prior to that, I worked at Atlas Devices on a Cortex-M7 USB audio platform, where I developed embedded drivers, automated firmware pipelines, and verified signal integrity at the board level. Across both roles, I learned how to navigate the full development lifecycle in low-level systems.

In addition to industry experience, I've led several interdisciplinary projects—most notably the *Lunar Navigation Bot*, a semi-autonomous rover that used YOLOv6 and MQTT for real-time classification and navigation. This project was selected as a top finalist in the SpaceBot 2023 Challenge and reflects my ability to design intelligent systems for constrained and unreliable environments. I've also published research in edge AI optimization and model pruning for low-power speech systems, which has shaped my approach to designing efficient, deployable software on resource-constrained hardware.

Thank you for considering my application. I'm confident that my background in embedded platforms, real-time systems, and cross-disciplinary project work aligns well with your engineering goals. I would welcome the opportunity to discuss how I can contribute to #addressee-institution's mission and ongoing innovations.
