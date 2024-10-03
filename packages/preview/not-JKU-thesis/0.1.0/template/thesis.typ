//#import "@local/not-JKU-thesis:0.1.0": jku-thesis // for development
#import "@preview/not-JKU-thesis:0.1.0": jku-thesis

#import "utils.typ": inwriting, draft, todo, flex-caption, flex-caption-styles
#import "glossary.typ": glossary
#import "@preview/glossarium:0.2.6": make-glossary, print-glossary, gls, glspl

#show: make-glossary
#show: flex-caption-styles


/** Drafting

  Set the boolean variables `inwriting` and `draft` inside utils.typ.
  
  The "draft" variable is used to show DRAFT in the header and the title. This should be true until the final version is handed-in.
  
  The "inwriting" is used to change the appearance of the document for easier writing. Set to true for yourself but false for handing in a draft or so.

**/


// global text settings
#set text(lang: "en", weight: "regular", font: "Arial", size: 11pt)
#set text(ligatures: false)
#set par(leading: 1em, first-line-indent: 0em, justify: true)
#show par: set block(spacing: 1.5em) // spacing after a paragraph
#show raw: set text( size: 9pt) // set text for code-blocks (``)

#set page(margin: (left: 2.5cm+1cm, // binding correction of 1cm for single sided printing
                   right: 2.5cm,
                   y: 2.9cm),
          // margin: (inside: 2.5cm+1cm, // binding correction of 1cm for double sided printing
          //          outside: 2.5cm,
          //          y:2.5cm),
          // binding: left
                   )

#let date =  datetime.today() // not today: datetime(year: 1969, month: 9, day: 6,)
#let k-number = "k12345678"


#show: jku-thesis.with(
  thesis-type: "Master",
  degree: "Master of Science",
  program: "Feline Behavioral Studies",
  supervisor: "Professor Mittens Meowington, Ph.D.",
  advisors: ("Dr. Felix Pawsworth","Dr. Whiskers Purrington"), // singular advisor like this: ("Dr. Felix Pawsworth",) and no supervisor: ""
  department: "Department of Animal Psychology",
  author: "Felina Whiskerstein, BSc.",
  date: date,
  place_of_submission: "Linz",
  title: "Purrfection: How Cats Skillfully Train and Manipulate Humans to Serve Their Every Need",
  abstract_en: [//max. 250 words
    This study explores the intricate ways in which domestic cats employ manipulation tactics to influence human behavior. Utilizing a mixed-methods approach that combines observational data, surveys, and interviews, this research investigates how cats utilize vocalizations, body language, and attention-seeking behaviors to achieve their goals, ranging from soliciting food to initiating play.

    The findings reveal that cats predominantly use vocalizations such as meowing, purring, and chirping to manipulate their human companions. Meowing is particularly effective for demanding attention and food, while purring is often used to enhance bonding and comfort. Chirps and trills are employed to encourage play and interaction. Additionally, body language such as kneading, tail positioning, and eye contact play significant roles in communication and manipulation. Attention-seeking behaviors, including climbing, rubbing, and bringing objects, are crucial in eliciting responses from humans.

    The research highlights the positive impact of these manipulation tactics on human-cat relationships, although it also acknowledges the potential for frustration and behavioral adjustments by cat owners. The study contributes valuable insights into the complexities of human-animal interactions and suggests pathways for future research, including larger sample sizes, longitudinal studies, and experimental investigations.

    This work offers practical implications for enhancing human-cat interactions and improving the understanding of feline behavior, fostering more harmonious relationships between cats and their human companions.  
  ],
  abstract_de: none,// or specify the abbstract_de in a container []
  acknowledgements: [
I would like to extend a huge thank you to Dr. Felina Whiskers, my primary advisor, for her pawsitive support and expert guidance. Without her wisdom and occasional catnip breaks, this thesis might have turned into a hairball of confusion.

A special shoutout to Dr. Felix Pawsworth, my co-advisor, for his keen insights and for keeping me from chasing my own tail during this research. Your input was invaluable and much appreciated.

To the cat owners, survey respondents, and interviewees—thank you for sharing your feline escapades. Your stories made this research more entertaining than a laser pointer.

Lastly, to my family and friends, thank you for tolerating the endless cat puns and my obsession with feline behavior. Your patience and encouragement kept me from becoming a full-time cat herder.

To everyone who contributed to this thesis, directly or indirectly, I offer my heartfelt gratitude. You've all made this journey a little less ruff!
  
  ],//acknowledgements: none // if you are self-made
  showTitleInHeader: false,
  draft: draft,
)

// set equation and heading numbering
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.1")


// Set font size
#show heading.where(level: 3): set text(size: 1.05em)
#show heading.where(level: 4): set text(size: 1.0em)
#show figure: set text(size: 0.9em)

// Set spacings
#set table(inset: 6.5pt)
#show table: set par(justify: false)
#show figure: it => [#v(1em) #it #v(1em)]

#show heading.where(level: 1): set block(above: 1.95em, below: 1em)
#show heading.where(level: 2): set block(above: 1.85em, below: 1em)
#show heading.where(level: 3): set block(above: 1.75em, below: 1em)
#show heading.where(level: 4): set block(above: 1.55em, below: 1em)


// Pagebreak after level 1 headings
#show heading.where(level: 1): it => [
  #pagebreak(weak: true)
  #it
]


// Set citation style
#set cite(style: "iso-690-author-date") // page info visible
//#set cite(style: "iso-690-numeric") // page info visible
//#set cite(style: "springer-basic")// no additional info visible (page number in square brackets)
//#set cite(style: "alphanumeric")// page info not visible


// Table stroke
#set table(stroke: 0.5pt + black)


// show reference targets in brackets
#show ref: it => {
  let el = it.element
  if el != none and el.func() == heading {

    [#it (#el.body)]
  } else [#it]
}

// color links and references for the final document
// #show link: set text(fill: blue)
// #show ref: set text(fill: color.olive)


// style table-of-contents
#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  strong(it)
}


// Draft Settings //
#show cite: set text(fill: purple) if inwriting // highlight citations 
#show footnote: set text(fill: purple) if inwriting
#show ref: set text(fill: purple) if inwriting

// Custom Footer //
#set page(footer: context [
  #text(size:9pt)[
    #table(
      stroke: none,
      columns:  (1fr, auto, 1fr),
      align: (left, center, right),
      inset: 5pt,
      [#date.display("[month repr:long] [day], [year]")],[#k-number],[#counter(page).display(
        "1",
      )],
      
    )
  ]
])

// ------ Content ------

// Table of contents.
#outline(
  title: {
    text(1.3em, weight: 700, "Contents")
    v(10mm)
  },
  indent: 2em,
  depth: 3
)<outline>
#pagebreak(weak: false)


// --- Main Chapters ---


#include "content/Tutorial.typ"// Some trivial, but useful snippets

#include "content/Introduction.typ"

#include "content/LiteratureReview.typ"

#include "content/Methodology.typ"

#include "content/DataCollection.typ"

#include "content/Analysis.typ"

#include "content/Conclusion.typ"


// --- Appendixes ---

// restart page numbering using roman numbers
#set page(footer: context [
  #text(size:9pt)[
    #table(
      stroke: none,
      columns:  (1fr, auto, 1fr),
      align: (left, center, right),
      inset: 5pt,
      [#date.display("[month repr:long] [day], [year]")],[#k-number],[#counter(page).display(
        "i",
      )],
      
    )
  ]
])
#counter(page).update(1)


#include("content/Appendix.typ")

// List of Acronyms - comment out, if not needed (no abbreviations were used).
#heading(numbering: none)[List of Acronyms]
#print-glossary(glossary)

// List of figures - comment out, if not needed.
#heading(numbering: none)[List of Figures]
#outline(
  title: none,
  target: figure.where(kind: image),
)

 
// List of tables - comment out, if not needed.
#heading(numbering: none)[List of Tables]
#outline(
  title: none,
  target: figure.where(kind: table))



// --- Bibliography ---

#set par(leading: 0.7em, first-line-indent: 0em, justify: true)
#bibliography("items.bib", style: "apa")