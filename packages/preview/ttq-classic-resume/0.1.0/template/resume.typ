// Import the resume template components
#import "@preview/ttq-classic-resume:0.1.0": project-entry, resume, resume-header, section-header, table, timeline-entry

// Apply the resume styling to the document
#show: resume

// Create your header with name and contact information
// Contacts are separated by ❖ symbols automatically
#resume-header(
  name: "John Doe",
  contacts: (
    "john.doe@example.com",
    "(555) 123-4567",
    "github.com/johndoe",
    "linkedin.com/in/johndoe",
    "Pittsburgh, PA",
  ),
)

// Section headers create titled sections with an underline
#section-header("Active Certifications")

// Use table for lists of items (certifications, awards, etc.)
// The table component auto-detects flat vs categorized structure
#table(
  items: (
    [Offensive Security Certified Professional (OSCP)],
    [GIAC Cyber Threat Intelligence (GCTI)],
    [CompTIA CASP+, CySA+, Sec+, Net+, A+, Proj+],
    [GIAC Machine Learning Engineer (GMLE)],
  ),
  columns: 2,
)

#section-header("Skills")

// Use table for categorized information like skills
// Each item has a 'category' and 'text'
#table(
  items: (
    (category: "Programming", text: [Python, R, JS, C\#, Rust, PowerShell, CI/CD]),
    (category: "Data Science", text: [ML/statistics, TensorFlow, AI Engineering]),
    (category: "IT & Cybersecurity", text: [AD DS, Splunk, Metasploit, Wireshark, Nessus]),
    (category: "Cloud", text: [AWS EC2/S3, Helm, Docker, Serverless]),
  ),
  columns: 2,
)

#section-header("Work Experience")

// Use timeline-entry for work experience, education, or achievements
// heading-left: Company/School name, heading-right: Dates
// subheading-left: Job title/Degree, subheading-right: Location
// body: Native Typst content including lists (optional)
#timeline-entry(
  heading-left: "Templar Archives Research Division",
  heading-right: "August 2024 – Present",
  subheading-left: "Psionic Research Analyst",
  subheading-right: "Aiur",
  body: [
    - Analyzed Khala disruption patterns following Amon's corruption, developing countermeasures to protect remaining neural link infrastructure.
    - Building automated threat detection pipelines using Khaydarin crystal arrays to monitor Void energy signatures across the sector.
  ],
)

#timeline-entry(
  heading-left: "Terran Dominion Ghost Academy",
  heading-right: "May 2025 – July 2025",
  subheading-left: "Covert Ops Trainee",
  subheading-right: "Tarsonis (Remote)",
  body: [
    - Developed tactical HUD displays for Ghost operatives integrating real-time Zerg hive cluster intelligence.
    - Created automated target acquisition systems for nuclear launch protocols; involved cloaking field calibration and EMP targeting.
    - Discovered (and reported) a critical vulnerability in Adjutant defense networks exploitable by Zerg Infestors.
  ],
)

#timeline-entry(
  heading-left: "Abathur's Evolution Pit",
  heading-right: "June 2023 – July 2023",
  subheading-left: "Biomass Research Intern",
  subheading-right: "Char",
  body: [
    - Developed tracking algorithms for Overlord surveillance networks; supported pattern-of-life analysis for Terran outpost elimination.
    - Prototyped a creep tumor optimization tool featuring swarm pathfinding, resource node mapping, and hatchery placement recommendations.
  ],
)

#timeline-entry(
  heading-left: "Raynor's Raiders",
  heading-right: "January 2018 – June 2020",
  subheading-left: "Combat Engineer",
  subheading-right: "Mar Sara",
  body: [
    - Administered Hyperion shipboard systems, SCV maintenance protocols, and bunker defense automation for 30,000+ colonists.
    - Developed siege tank targeting scripts, delivered Zerg threat briefs, and integrated supply depot optimization procedures.
    - Achieved Distinguished Graduate honors at the Mar Sara Militia Academy.
    - Awarded the Raynor's Star and Mar Sara Defense Medal for meritorious service against the Swarm.
  ],
)

#section-header("Education")

// Education entries use the same entry_block component
// Omit the body parameter if you don't need content
#timeline-entry(
  heading-left: "Carnegie Mellon University",
  heading-right: "December 2025",
  subheading-left: "Master of Information Technology Strategy",
  subheading-right: "Pittsburgh, PA",
)

#timeline-entry(
  heading-left: "United States Air Force Academy",
  heading-right: "May 2024",
  subheading-left: "BS, Data Science",
  subheading-right: "Colorado Springs, CO",
  body: [
    - Distinguished Graduate (top 10%); Chinese language minor (L2+/R1 on DLPT).
    - Delogrand deputy captain, cyber combat lead, and web exploit SME.
    - Professor Bradley A. Warner Data Science Catalyst and Top Cadet in Computer Networks.
  ],
)

#timeline-entry(
  heading-left: "Western Governors University",
  heading-right: "April 2022",
  subheading-left: "BS, Cybersecurity and Information Assurance",
  subheading-right: "Remote",
)

#timeline-entry(
  heading-left: "Community College of the Air Force",
  heading-right: "February 2019",
  subheading-left: "AS, Information Systems Technology",
  subheading-right: "Remote",
)

#section-header("Cyber Competition")

#timeline-entry(
  heading-left: "1st in SANS Academy Cup 2024",
  body: [
    - Competed as the Delogrand Web Exploit SME, solving SQLi, API, and HTTP packet crafting problems.
    - Also placed first in SANS Core Netwars competition.
  ],
)

#timeline-entry(
  heading-left: "1st in NCX 2023",
  body: [
    - Developed strategies, defensive scripts, and exploits for the Cyber Combat event.
    - Analyzed logs with Bash and Python for the Data Analysis event.
  ],
)

#timeline-entry(
  heading-left: "1st in SANS Academy Cup 2023",
  body: [
    - Competed as the Delogrand Web Exploit SME, solving XSS, XXE, SQLi, and HTTP crafting problems.
    - Took first place against rival Army, Navy, and Coast Guard service academy teams.
  ],
)

#timeline-entry(
  heading-left: "1st in RMCS 2023",
  body: [
    - Competed as the Delogrand Web Exploit SME, solving obfuscated JS, Wasm, XSS, and SQLi problems.
  ],
)

#timeline-entry(
  heading-left: "1st in NCX 2022",
  body: [
    - Trained and strategized teams for the Cyber Combat event.
  ],
)

#section-header("Projects")

// Use project-entry for personal projects
// name: Project name, url: Project URL (optional), body: Native Typst content (optional)
#project-entry(
  name: "TongueToQuill",
  url: "https://www.tonguetoquill.com",
  body: [
    - Rich markdown editor for perfectly formatted USAF and USSF documents with Claude MCP integration.
  ],
)

#project-entry(
  name: "Quillmark",
  url: "https://github.com/nibsbin/quillmark",
  body: [
    - Parameterization engine for generating arbitrarily typesetted documents from markdown content.
  ],
)

#project-entry(
  name: "RoboRA",
  url: "https://github.com/nibsbin/RoboRA",
  body: [
    - AI research automation framework for Dr. Nadiya Kostyuk's research on global cyber policy.
  ],
)

#project-entry(
  name: "Scraipe",
  url: "https://pypi.org/project/scraipe/",
  body: [
    - An asynchronous scraping and enrichment library to automate cybersecurity research.
  ],
)

#project-entry(
  name: "Quandry",
  url: "https://quandry.streamlit.app/",
  body: [
    - LLM Expectation Engine to automate security and behavior evaluation of LLM models.
    - Awarded 1st place out of 11 teams in CMU's Fall 2024 Information Security, Privacy, and Policy poster fair.
  ],
)

#project-entry(
  name: "Streamlit Scroll Navigation",
  url: "https://pypi.org/project/streamlit-scroll-navigation/",
  body: [
    - Published a Streamlit-featured PyPI package to help data scientists create fluid single-page applications.
  ],
)

#project-entry(
  name: "ADSBLookup",
  url: "<closed source>",
  body: [
    - Reversed the internal API of a popular ADSB web service to pull comprehensive live ADSB datasets; ported and exposed attributes in a user-friendly, Pandas-compatible Python library for data scientists.
  ],
)

#project-entry(
  name: "OSCP LaTeX Report Template",
  url: "https://github.com/SnpM/oscp-latex-report-template",
  body: [
    - Published a report template that features custom commands for streamlined penetration test documentation.
  ],
)

#project-entry(
  name: "Lockstep Framework",
  url: "https://github.com/SnpM/LockstepFramework",
  body: [
    - As a budding programmer, I created a popular RTS engine with custom-built deterministic physics.
  ],
)
