// axiomst template - Academic homework and slides
// Delete the parts you don't need!

#import "@preview/axiomst:0.2.0": *

// ============================================================================
// HOMEWORK TEMPLATE
// ============================================================================

#show: homework.with(
  title: "Problem Set 1",
  author: "Your Name",
  course: "MATH 101",
  email: "you@university.edu",
  date: datetime.today(),
  // due-date: "Next Friday",
  // collaborators: ("Alice", "Bob"),
  // show-solutions: false,  // Set to false to hide solutions
)

// Optional: Use a nicer font
// #set text(font: "New Computer Modern")

#instructions[
  Replace this with your assignment instructions, or delete this block.
]

#problem(title: "Your First Problem")[
  State the problem here. You can use math: $integral_0^1 x^2 dif x = 1/3$.

  + First part of the problem.
  + Second part of the problem.
]

#solution[
  Write your solution here. This block can be hidden by setting
  `show-solutions: false` in the homework configuration.
]

#theorem(title: "A Theorem")[
  State your theorem here.
]

#proof[
  Write your proof here.
]

#definition(title: "A Definition")[
  Define your term here.
]

#lemma[
  A supporting lemma.
]

#corollary[
  A consequence of the theorem.
]

#example[
  An illustrative example.
]

// Two-column layout
#columns(count: 2)[
  Left column content.
][
  Right column content.
]

// ============================================================================
// SLIDES TEMPLATE (uncomment to use instead of homework)
// ============================================================================

// #show: slides.with(
//   title: "My Presentation",
//   author: "Your Name",
//   date: datetime.today(),
//   ratio: "16-9",   // or "4-3"
//   // handout: true,  // For print-friendly version
// )

// #title-slide(
//   title: "My Presentation",
//   subtitle: "A Subtitle",
//   author: "Your Name",
//   institution: "Your University",
//   date: datetime.today(),
// )

// #slide(title: "First Slide")[
//   Content here.
//
//   #pause
//
//   This appears on click.
// ]

// #section-slide[New Section]

// #slide(title: "Dynamic Content")[
//   #uncover(1)[Always visible from start]
//   #uncover((from: 2))[Appears on subslide 2+]
//   #only(3)[Only on subslide 3]
// ]
