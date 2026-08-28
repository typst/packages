
#import "@preview/resumetyp:0.1.0": *

#show: resume.with(
  contact-info-position: center,
  contacts-separator: [#h(0.45em)◆#h(0.45em)],
  inline-separator: [#h(0.35em)/#h(0.35em)],
  link-color: rgb("#B5651D"),
  accent-color: rgb("#654321"),
  font: "Libertinus Serif",
  font-size: 11pt,
  line-spacing: 0.65em,
  page-margin: 0.5in,
  list-marker: [--],
  justify: true,
)

// --------------------------------------------------------------------------------
// CONTACT INFORMATION
// --------------------------------------------------------------------------------
// Contact fields are optional except for name.
// LinkedIn/GitHub accept usernames; additional named arguments can be used
// for custom contact fields or URLs. See the examples below.
#contact-info(
  name: [Bramble Quillwhistle],
  phone: [+1 (OWL) HOO-HOOT],
  email: [bramble\@whiffmail.invalid],
  address: [Moonbeam, Cloudland],
  linkedin: [bramble-qw],
  // github: [username],
  // arbitrary-url: "https://www.url.com",
  // url-with-custom-anchor: [#link("url")[anchor]],
  // arbitrary-key: [arbitrary-value],
)



// --------------------------------------------------------------------------------
// PROFESSIONAL SUMMARY
// --------------------------------------------------------------------------------
#summary[
  #strong[Quantum Spreadsheet Cartographer] experienced in mapping
  imaginary datasets, taming semi-sentient spreadsheets, and turning
  complicated business riddles into questionable charts.
]


// --------------------------------------------------------------------------------
// SKILLS
// --------------------------------------------------------------------------------
#skillset(
  category: [Arcane Machinery],
  skills: [WobbleScript, QuantaQL, HyperCalc, FluxLogic, ByteWhistling]
)

#skillset(
  category: [Mystical Data],
  skills: [Moon Mapping, Data Alchemy, Pattern Sculpting, Cloud Analytics]
)

#skillset(
  category: [Vision Sorcery],
  skills: [Dream Charts, Hologram Tables, Orbital Graphs, Nebula Plotting]
)

#skillset(
  category: [Goblin Automation],
  skills: [Auto-Wrangling, Clockwork Pipelines, GoblinOps]
)


// --------------------------------------------------------------------------------
// WORK EXPERIENCE
// --------------------------------------------------------------------------------
// Set `new-page: true` to force this entry to start on a new page.
#experience(
  title: [Chief Spreadsheet Cartographer],
  company: [Whizzlewick Data],
  location: [Moonbeam, Cloudland],
  start-date: [Mar 2023],
  end-date: [Present],
  [Mapped 7.4 million imaginary records, uncovering 842 relationships
  between teacup capacity and quarterly moon phases.],
  [Designed a #emph[WobbleScript] engine that converted chaotic datasets
  into perfectly rectangular tables.],
  [Reduced spreadsheet turbulence by 73% using predictive cell alignment
  and emotionally supportive formulas.],
  [Presented findings to department heads, automated calculators,
  and one highly skeptical office fern.]
)

#experience(
  title: [Junior Data Enchanter],
  company: [Institute of Nonsense],
  location: [Pebblewick, Cloudland],
  start-date: [Jun 2021],
  end-date: [Feb 2023], 
  [Processed 480,000 synthetic moon records using #emph[QuantaQL].],
  [Built #emph[FluxLogic] pipelines for transforming numerical artifacts
  into structured analytical scrolls.],
  [Created #emph[Nebula Plotting] visualizations for imaginary
  commercial phenomena.],
  [Purified datasets by removing corrupted numbers, rogue decimals,
  and one particularly troublesome number 47.]
)

#experience(
  title: [Apprentice Pixel Mechanic],
  company: [Bumblebyte],
  location: [Tinkerbell Plains],
  start-date: [May 2020],
  end-date: [Aug 2020],
  [Maintained experimental computing contraptions for fictional
  customer transactions.],
  [Developed #emph[ByteWhistling] routines to automate numerical
  operations and summon dormant calculators.],
  [Investigated anomalous output from legacy computational machinery.]
)

// --------------------------------------------------------------------------------
// PROJECTS
// --------------------------------------------------------------------------------
// Set `new-page: true` to force this entry to start on a new page.
#project(
  name: [Interdimensional Sales Oracle],
  info: [WobbleScript, FluxLogic, Nebula Plotting],
  start-date: [Jan 2024],
  end-date: [Mar 2024],
  [Predicted fictional sales across twelve dimensions using
  historical sandwich observations.]
)

#project(
  name: [Automated Dragon Census],
  info: [QuantaQL, HyperCalc, Cloud Mapping],
  start-date: [Sep 2023],
  end-date: [Nov 2023],
  [Catalogued imaginary dragons by wing geometry, treasure preference,
  nap duration, and suspiciousness.]
)

#project(
  name: [The Infinite Spreadsheet],
  info: [Dream Charts, Auto-Wrangling, GoblinOps],
  start-date: [Apr 2023],
  end-date: [Jun 2023],
  [Created a spreadsheet engine capable of generating tables that
  continuously expand without reaching the bottom row.]
)

// --------------------------------------------------------------------------------
// EDUCATION
// --------------------------------------------------------------------------------
// Set `new-page: true` to force this entry to start on a new page.
#education(
  degree: [Master of Computational Whimsy],
  school: [Royal Academy of Impossibility],
  location: [Starling Valley],
  start-date: [Sep 2021],
  end-date: [Jun 2023],
  gpa: [4.87],
  coursework: [
    Nonsense Theory,
    Computational Daydreaming,
    Imaginary Data,
    Moon Mathematics
  ]
)

#education(
  degree: [Bachelor of Numerical Wizardry],
  school: [University of Tuesdays],
  location: [Bramblemoor],
  start-date: [Sep 2017],
  end-date: [Apr 2021],
  gpa: [4.42],
  coursework: [
    Enchanted Algorithms,
    Numerical Spellcraft,
    Calculator Theory
  ],
)

// --------------------------------------------------------------------------------
// CERTIFICATIONS
// --------------------------------------------------------------------------------
// Set `new-page: true` to force this entry to start on a new page.
#certification(
  name: [Certified Spreadsheet Whisperer],
  issuer: [Guild of Imaginary Analysts],
  date: [Jun 2024],
  [Demonstrated advanced spreadsheet whispering and circular-reference
  negotiation.]
)

#certification(
  name: [GoblinOps Practitioner],
  issuer: [Institute of Goblin Engineering],
  date: [Feb 2024],
  [Completed training in goblin coordination, recursive paperwork,
  and distributed snack allocation.]
)


// Sections can be reorder freely
// without needing to reorder data above
#print-contact
#print-summary
#print-skills
#print-experience
#print-projects
#print-education
#print-certifications
