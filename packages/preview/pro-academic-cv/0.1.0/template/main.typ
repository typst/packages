#import "@preview/pro-academic-cv:0.1.0": *

#show: resume.with(
  author-info: (
    name: "John Doe",
    primary-info: [
      +1-234-567-8900 | #link("mailto:john.doe@example.com")[john.doe\@example.com] | #link("https://www.john-doe.com/")[john-doe.com]
    ],
    secondary-info: [
      #link("https://www.linkedin.com/in/john-doe-linkedin")[linkedin] | #link("https://github.com/john-doe-github")[github] | #link("https://scholar.google.com/citations?user=john-doe-google-scholar")[google-scholar] | #link("https://orcid.org/john-doe-orcid")[orcid]
    ],
    tertiary-info: "Your City, Your State - Your ZIP, Your Country",
  ),
  author-position: center
)

== Objective
Seeking a challenging position in \[your field\] to leverage my expertise in \[your key skills\]. Aiming to contribute to innovative projects at the intersection of \[your interests\] and practical problem-solving in fields such as \[specific areas of interest\].

== Experience
#r2c2_entry_list(
  (
    entry-header-args:(
      top-left: [#link("https://research.google.com")[Google Research]],
      top-right: [Month Year - Month Year],
      bottom-left: [Job Title A],
      bottom-right: [City, Country],
    ),
    list-items: (
      [Developed \[specific achievement\] achieving \[specific metric\] in \[specific area\]],
      [Implemented \[technology/method\], enhancing \[specific aspect\] by \[specific percentage\]],
      [Conducted analysis on \[specific data\], identifying \[key findings\]],
      [Presented findings at \[specific event\], receiving \[specific recognition\]],
    )
  ),
  (
    entry-header-args:(
      top-left: [Company B],
      top-right: [Month Year - Month Year],
      bottom-left: [Job Title B],
      bottom-right: [Remote],
    ),
    list-items: (
      [Engineered a \[specific system/model\], improving \[specific metric\] by \[percentage\]],
      [Developed \[specific tool/method\], increasing \[specific aspect\] by \[percentage\]],
      [Implemented \[specific system\], reducing \[specific metric\] by \[percentage\]],
      [Conducted \[specific test/analysis\] to validate \[specific aspect\]],
    )
  )
)

== Education
#r2c2_entry_list(
  (
    entry-header-args: (
      top-left: [University Name],
      top-right: [Month Year - Month Year],
      bottom-left: [Degree Name],
      bottom-right: [City, Country],
    ),
    list-items: (
      [GPA: X.XX/4.00],
    ),
  ),
  (
    entry-header-args: (
      top-left: [College Name],
      top-right: [Month Year],
      bottom-left: [Pre-University Education],
      bottom-right: [City, Country],
    ),
    list-items: (
      [Grade: XX.X%],
    ),
  ),
  (
    entry-header-args: (
      top-left: [High School Name],
      top-right: [Month Year],
      bottom-left: [Secondary Education],
      bottom-right: [City, Country],
    ),
    list-items: (
      [GPA: X.X/10],
    ),
  ),
)

== Projects
#r2c2_entry_list(
  (
    entry-header-args: (
      top-left: [Project A: \[Brief Description\]],
      top-right: [Month Year - Month Year],
      bottom-left: [Tools: \[List of tools and technologies used\]],
      bottom-right: [#link("https://github.com/your-username/project-a")[\@your-username/project-a]],
    ),
    list-items: (
      [Developed \[specific feature/system\] for \[specific purpose\]],
      [Implemented \[specific technology\] for \[specific goal\], achieving \[specific result\]],
      [Created \[specific component\], ensuring \[specific benefit\]],
      [Applied \[specific method\] to analyze \[specific aspect\]],
    ),
  ),
  (
    entry-header-args: (
      top-left: [Project B: \[Brief Description\]],
      top-right: [Month Year],
      bottom-left: [Tools: \[List of tools and technologies used\]],
      bottom-right: [#link("https://github.com/your-username/project-b")[\@your-username/project-b]],
    ),
    list-items: (
      [Developed \[specific model/system\], achieving \[specific metric\]],
      [Implemented \[specific feature\], processing \[specific volume\] of data],
      [Created \[specific visualization\] for \[specific purpose\]],
      [Developed \[specific component\] for easy integration with \[specific system\]],
    )
  )
)

== Patents~&~Publications (note:C=Conference, J=Journal, P=Patent, S=In Submission, T=Thesis)
#publication_entry_list(
  (
    (category: "C", value: [Your Name, et al. (Year). #link("https://doi.org/XX.XXXX/XXXXXXX.XXXX.XXXXXXX")[*Title of Conference Paper*]. In _Name of Conference Proceedings_, pp. XX-XX. Publisher. Date, Location. DOI: XX.XXXX/XXXXXXX.XXXX.XXXXXXX]),
    (category: "C", value: [Your Name, et al. (Year). #link("https://doi.org/XX.XXXX/XXXXXXX.XXXX.XXXXXXX")[*Title of Conference Paper*]. In _Name of Conference Proceedings_, pp. XX-XX. Publisher. Date, Location. DOI: XX.XXXX/XXXXXXX.XXXX.XXXXXXX]),
    (category: "S", value: [Your Name, et al. (Year). *Title of Submitted Paper*. Manuscript submitted for publication in _Journal Name_.]),
    (category: "P", value: [Inventor 1, Your Name, Inventor 3, et al. (Year). #link("https://patentoffice.gov/patent/XXXXXXXXX")[*Title of Patent*]. Patent Office, Patent No. XXXXXXXXX. Registration Date: Date, Grant Date: Date, Publication Date: Date.]),
    (category: "J", value: [Author 1, Your Name, Author 3, et al. (Year). #link("https://doi.org/XX.XXXX/XXXXX.XXXX.XXXXXXX")[*Title of Journal Article*]. _Journal Name_, Vol. XX, Issue X, pp. XXX-XXX. DOI: XX.XXXX/XXXXX.XXXX.XXXXXXX]),
  ),
  // number-style: "ascending",
)

== Skills
#multi_line_list(
  single_line_entry("Programming Languages:", [Language 1, Language 2, Language 3, Language 4, Language 5], []),
  single_line_entry("Web Technologies:", [Technology 1, Technology 2, Technology 3, Technology 4, Technology 5], []),
  single_line_entry("Database Systems:", [Database 1, Database 2, Database 3], []),
  single_line_entry("Data Science & Machine Learning:", [Tool 1, Tool 2, Tool 3, Tool 4, Tool 5, Tool 6], []),
  single_line_entry("Cloud Technologies:", [Cloud Platform 1, Cloud Platform 2, Cloud Platform 3], []),
  single_line_entry("DevOps & Version Control:", [Tool 1, Tool 2, Tool 3, Tool 4, Tool 5], []),
  single_line_entry("Specialized Area:", [Skill 1, Skill 2, Skill 3, Skill 4], []),
  single_line_entry("Mathematical & Statistical Tools:", [Tool 1, Tool 2, Tool 3, Tool 4, Tool 5], []),
  single_line_entry("Other Tools & Technologies:", [Tool 1, Tool 2, Tool 3, Tool 4, Tool 5], []),
  single_line_entry("Research Skills:", [Skill 1, Skill 2, Skill 3, Skill 4, Skill 5, Skill 6], []),
)

== Honors~&~Awards
- #r2c2_entry_header(
  top-left: [Award Name A],
  top-right: [Month Year],
  bottom-left: [Awarding Institution/Organization],
  bottom-right: [#link("https://award-link-a.com")[#link-icon()]],
)
#r2c2_entry_list(
  (
    entry-header-args: (
      top-left: [Award Name B],
      top-right: [Month Year],
      bottom-left: [Awarding Institution/Organization],
      bottom-right: [#link("https://award-link-b.com")[#link-icon()]],
    ),
    list-items: (
      [Brief description of the award and its significance],
      [Impact or recognition associated with the award],
    ),
  ),
  (
    entry-header-args: (
      top-left: [Competition Achievement],
      top-right: [Month Year],
      bottom-left: [Competition Name, Organizing Body],
      bottom-right: [#link("https://competition-link.com")[#link-icon()]],
    ),
    list-items: (
      [Specific achievement or rank in the competition],
      [Skills or abilities demonstrated through this achievement],
    ),
  ),
)

== Leadership Experience
#r2c2_entry_list(
  (
    entry-header-args: (
      top-left: [Leadership Role A],
      top-right: [Month Year - Month Year],
      bottom-left: [Organization/Institution Name],
      bottom-right: [#link("https://organization-a-link.com")[#link-icon()]],
    ),
    list-items: (
      [Key responsibility or achievement in this role],
      [Quantifiable impact or improvement made during tenure],
      [Initiative taken or project led],
    ),
  ),
  (
    entry-header-args: (
      top-left: [Leadership Role B],
      top-right: [Month Year - Month Year],
      bottom-left: [Organization/Institution Name],
      bottom-right: [#link("https://organization-b-link.com")[#link-icon()]],
    ),
    list-items: (
      [Key responsibility or achievement in this role],
      [Quantifiable impact or improvement made during tenure],
      [Initiative taken or project led],
    ),
  ),
)

== Volunteer Experience
#r2c2_entry_list(
  (
    entry-header-args: (
      top-left: [Volunteer Role A],
      top-right: [Month Year - Month Year],
      bottom-left: [Organization Name],
      bottom-right: [#link("https://volunteer-org-a-link.com")[#link-icon()]],
    ),
    list-items: (
      [Key responsibility or contribution in this role],
      [Impact of your volunteer work],
      [Skills developed or applied during this experience],
    ),
  ),
  (
    entry-header-args: (
      top-left: [Volunteer Role B],
      top-right: [Month Year - Present],
      bottom-left: [Organization Name],
      bottom-right: [#link("https://volunteer-org-b-link.com")[#link-icon()]],
    ),
    list-items: (
      [Key responsibility or contribution in this role],
      [Impact of your volunteer work],
      [Skills developed or applied during this experience],
    ),
  ),
)

== Professional Memberships
#multi_line_list(
  single_line_entry([Professional Organization A,], [Membership ID: XXXXXXXX], [Month Year - Present]),
  single_line_entry([Professional Organization B,], [Membership ID: XXXXXXXX], [Month Year - Present]),
  single_line_entry([Professional Organization C,], [Membership ID: XXXXXXXX], [Month Year - Present]),
)

== Certifications
#multi_line_list(
  single_line_entry([Certification A], [], [Month Year]),
  single_line_entry([Certifying Body:], [Certification B], [Month Year]),
  single_line_entry([Certifying Body:], [Certification C], [Month Year]),
  single_line_entry([Certification D], [], [Month Year]),
)

== Additional Information
#multi_line_text(
  single_line_entry([Languages:], [Language A (Proficiency level), Language B (Proficiency level), Language C (Proficiency level)], []),
  single_line_entry([Interests:], [Interest 1, Interest 2, Interest 3, Interest 4], [])
)

== References
#personal_info_list(
  (
    (name: [Reference Person 1], title: [Job Title, Department], org: [Organization/Institution Name], email: [email1\@example.com], phone: [+X-XXX-XXX-XXXX], note: [Relationship: e.g., Thesis Advisor, Manager, etc.]),
    (name: [Reference Person 2], title: [Job Title, Department], org: [Organization/Institution Name], email: [email2\@example.com], phone: [+X-XXX-XXX-XXXX], note: [Relationship: e.g., Project Supervisor, Colleague, etc.]),
    (name: [Reference Person 3], title: [Job Title, Department], org: [Organization/Institution Name], email: [email3\@example.com], phone: [+X-XXX-XXX-XXXX], note: [Relationship: e.g., Mentor, Collaborator, etc.]),
  ),
)
