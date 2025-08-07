#import "../monash-template/report/cover.typ": cover
#import "../monash-template/report/heading.typ": apply as apply-heading
#import "../monash-template/report/page.typ": apply as apply-page, apply-header-footer
#import "../monash-template/report/monash-colors.typ": monash-blue, monash-bright-blue, monash-navy, monash-yellow, monash-light-blue, monash-deep-blue
#import "@preview/thmbox:0.3.0": thmbox-init, thmbox, proof

#let monash-report(
  // Required parameters
  title,
  author,
  
  // Optional parameters with defaults
  subtitle: none,
  student-id: none,
  course-code: none,
  course-name: none,
  assignment-type: "Assignment",
  tutor-name: none,
  date: none,
  word-count: none,
  despair-mode: false,
  show-typst-attribution: true,
  show-outline: true,
  body
) = {
  // Set document metadata
  set text(lang: "en")
  set document(title: title, author: author, date: if date != none { date } else { datetime.today() })
  
  // Apply page and heading styles
  show: apply-page.with(despair-mode: despair-mode)
  show: apply-heading
  show: thmbox-init()
  
  // Cover page
  cover(
    title, 
    author, 
    none, // date-start (deprecated)
    none, // date-end (deprecated) 
    subtitle: subtitle, 
    logo: none, 
    logo-horizontal: true,
    student-id: student-id,
    course-code: course-code,
    course-name: course-name,
    assignment-type: assignment-type,
    tutor-name: tutor-name,
    word-count: word-count,
    date: date,
    show-typst-attribution: show-typst-attribution
  )
  pagebreak()
  
  // Apply header and footer
  show: apply-header-footer.with(course-code: course-code, assignment-type: assignment-type)
  
  // Table of contents (optional)
  if show-outline {
    outline(title: [Table of Contents], indent: 1em, depth: 2)
    pagebreak()
  }
  
  // User content
  body
}

// Custom color palette based on Monash brand colors
#let thm-colors = (
  // Primary theorem colors - using Monash blues
  theorem: monash-blue,
  proposition: monash-bright-blue,
  lemma: monash-yellow,  // Changed from navy to yellow for better contrast
  corollary: rgb(0, 102, 204),
  definition: monash-deep-blue,
  
  // Secondary colors - extended palette
  example: rgb(46, 125, 50),      // Green for examples
  remark: rgb(97, 97, 97),         // Gray for remarks
  note: rgb(0, 150, 136),          // Teal for notes
  exercise: rgb(63, 81, 181),       // Indigo for exercises
  algorithm: rgb(123, 31, 162),     // Purple for algorithms
  claim: rgb(76, 175, 80),         // Light green for claims
  axiom: rgb(0, 188, 212),          // Cyan for axioms
  
  // Special environments
  proof: monash-navy,
  observation: rgb(255, 152, 0),    // Orange for observations
  convention: rgb(156, 39, 176),    // Purple for conventions
  hypothesis: rgb(244, 67, 54),     // Red for hypotheses
)

// Used for theorems, uses Monash Blue by default.
#let theorem(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Theorem", title: title, color: thm-colors.theorem)
}

// Used for propositions, uses Bright Blue by default.
#let proposition(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Proposition", title: title, color: thm-colors.proposition)
}

// Used for lemmas, uses Monash Navy by default.
#let lemma(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Lemma", title: title, color: thm-colors.lemma)
}

// Used for corollaries, uses a lighter blue by default.
#let corollary(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Corollary", title: title, color: thm-colors.corollary)
}

// Used for definitions, uses Deep Blue by default.
#let definition(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Definition", title: title, color: thm-colors.definition)
}

// Used for examples, uses green color and is not numbered by default.
#let example(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Example", title: title, color: thm-colors.example, numbering: none, sans: false)
}

// Used for remarks, uses gray color and is not numbered by default.
#let remark(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Remark", title: title, color: thm-colors.remark, numbering: none, sans: false)
}
  
// Used for notes, uses teal color and is not numbered by default.
#let note(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Note", title: title, color: thm-colors.note, numbering: none, sans: false)
}

// Used for exercises, uses indigo color by default.
#let exercise(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Exercise", title: title, color: thm-colors.exercise, sans: false)
}

// Used for algorithms, uses purple color by default.
#let algorithm(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Algorithm", title: title, color: thm-colors.algorithm, sans: false)
}

// Used for claims, uses light green color and is not numbered by default.
#let claim(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Claim", title: title, color: thm-colors.claim, numbering: none)
}

// Used for axioms, uses cyan color by default.
#let axiom(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Axiom", title: title, color: thm-colors.axiom)
}

// Additional useful environments
#let observation(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Observation", title: title, color: thm-colors.observation, numbering: none, sans: false)
}

#let convention(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Convention", title: title, color: thm-colors.convention, numbering: none, sans: false)
}

#let hypothesis(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  thmbox(..args, variant: "Hypothesis", title: title, color: thm-colors.hypothesis)
}

// Custom proof environment
#let custom-proof(..args) = {
  let pa = args.pos()
  let num-pas = pa.len()
  let title = if num-pas >= 2 { pa.at(num-pas - 2) } else { none }
  let body = if num-pas >= 1 { pa.at(num-pas - 1) } else { [] }
  proof(..args, title: title)
}