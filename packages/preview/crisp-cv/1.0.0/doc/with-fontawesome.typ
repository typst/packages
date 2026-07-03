/*
 * This example shows how to use the fontawesome package
 * (https://typst.app/universe/package/fontawesome/) to add icons to the links
 * in the header.
 */
#import "@preview/crisp-cv:1.0.0": *
#import "@preview/fontawesome:0.6.2": *

// This section defines the content of the header as well as global configuration values.
#show: cv.with(
  name: "John Doe",
  contact: (
    "1847 Maple Crescent, Ottawa",
    "+1 (613) 555-1337",
    [#link("mailto:john.doe@mailbox.ca")],
  ),
  links: (
    [#fa-icon("gitlab", size: 10pt) #link("https://gitlab.com/jdoe")[gitlab.com/jdoe]],
    [#fa-icon("linkedin", size: 10pt) #link("https://linkedin.com/in/johndoe")[johndoe]],
  ),
)

= Skills
#skills(
  ("Natural Languages", [English _(native)_, French _(professional)_, Spanish _(basic)_]),
  ("Programming Languages", "Rust, Java, Python, TypeScript, JavaScript, C/C++"),
  ("Technologies", "Git, Kubernetes, Ansible, PostgreSQL, Redis"),
  (
    "Security",
    "Application Security, Threat Modeling, IAM, Delegated Authorization, SSDLC, Supply Chain Security, Post-Quantum Cryptography",
  ),
  ("Project Management", "GitLab, GitHub, Jira, Confluence, Agile Development / Scrum"),
)

= Professional Experience
...

= Education
...
