#import "@preview/ailab-isetbz:0.1.0": *

#let title = "Lab Report"
#let abstract = "The main topics discussed in the manuscript."
#let students = ("Student 1", "Student 2")
#let emails = ("student1@bizerte.r-iset.tn", "student2@bizerte.r-iset.tn")
#let profiles = ("profile1", "profile2") // GITHUB Profiles
#let terms = ("Typst", "GitHub", "Docker", "Julia", "Lab Report")

// --- DO NOT EDIT ---
#set document(keywords: terms, date: auto) 

#show: AILAB.with(
  title: text(smallcaps(title)),
  abstract: abstract,
  authors: 
  (
    (
      name: students.at(0),
      email: emails.at(0),
      profile: profiles.at(0)
    ),
    (
      name: students.at(1),
      email: emails.at(1),
      profile: profiles.at(1)
    ),
  ),
  index-terms: terms,
  // bibliography-file: "Biblio.bib",
)
// --- END OF METADATA ---

= Section 1
/* REST OF DOC */

// --- THE END ---
