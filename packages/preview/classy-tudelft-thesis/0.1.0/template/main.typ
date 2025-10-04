/* Imports: */
// Note: these imports need to repeated for every file used in the document.

// Main import of the template
// This import contains the wrap-it and equate packages by default.
#import "@preview/classy-tudelft-thesis:0.1.0": *

// Extra packages to your liking
// Physics-reltated tools for equations
#import "@preview/physica:0.9.6": *
// Specifying quantities and units
#import "@preview/unify:0.7.1": num, numrange, qty, qtyrange
// Formatting of uncertainties
#import "@preview/zero:0.5.0"


// Main styling, containg the majority of typesetting including document layout, fonts, heading styling, figure styling, outline styling, etc. Some parts of the styling are customizable.
#show: base.with(
  // These first two parameters are only used for the pdf metadata.
  title: "My document",
  name: "Your Name",
  // What is displayed at the top-right of the page. The top-left of the page displays the current chapter.
  rightheader: "Your name",
  // Main and math fonts
  main-font: "Stix Two Text",
  math-font: "Stix Two Math",
  // Colors used for internal references (figures, equations, sections) and citations
  ref-color: olive,
  cite-color: blue,
  // Language, used for correct hyphenation patterns and default word for outline title, etc.
  language: "en",
  region: "GB",
)

/* Cover page */

#makecoverpage(
  // supply path to cover image
  img: image("img/cover-image.jpg"),
  // These arguments speak for themselves
  title: [Title of Thesis],
  subtitle: [Subtitle],
  name: [Your Name],
  // optional: change color to big box containing title, subtitle and name. Default is full black with 50% opacity.
  // main_titlebox_fill: color.hsv(0deg, 0%, 0%, 50%)
)

/* Title page */

#maketitlepage(
  // These first arguments are self-explanatory
  title: [Title of Thesis],
  subtitle: [Subtitle],
  name: "Your Name",
  defense_date: datetime.today().display("[weekday] [month repr:long] [day], [year]") + " at 10:00",
  // These following arguments appear in a small table below the main title, subtitle, author
  student_number: 1234567,
  project_duration: [Starting month and year - Ending month and year],
  daily_supervisor: [Your Daily supervisor],
  // The thesis committee should be an array of contents, consisting of all the committee members and their affiliations
  thesis_committee: (
    [Supervisor 1],
    [TU Delft, Supervisor],
    [Committee member 2],
    [TU Delft],
    [Committee member 3],
    [TU Delft.],
  ),
  cover_description: [Photo by #link("https://unsplash.com/@thejoltjoker?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash", "Johannes Andersson") on #link("https://unsplash.com/photos/two-brown-deer-beside-trees-and-mountain-UCd78vfC8vU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash", "Unsplash").
  ],
  // Some more options of a publicity statement:
  // publicity-statement: [An electronic version of thesis is available at #link("https://repository.tudelft.nl", [`https://repository.tudelft.nl`]).],
  // publicity-statement: smallcaps[This thesis is confidential and cannot be made public.],
  publicity-statement: none,
  // The final set of arguments form the content of a table outlining all your supervisors. You can add as little or many as you want.
)

/* Remaining contents of front matter */

#heading(numbering: none, [Preface])

// Your preface here
// #lorem(250)



#heading(numbering: none, [Abstract])

// Your Abstract here
// #lorem(250)


#outline()

// After the front matter is complete, we switch page numbering from roman to arabic numbering, and restart counting. The next chapter created afterwards starts on page 1.

#show: switch-page-numbering

#include "./sections/0default-template.typ" // Comment out this line when you start writing
#include "./sections/1introduction.typ"
#include "./sections/2theory.typ"
#include "./sections/3methods.typ"
#include "./sections/4results.typ"
#include "./sections/5conclusion.typ"


#bibliography(
  "references.bib",
  title: [References],
  style: "american-physics-society",
)


#show: appendix

#include "./sections/6appendix.typ"

