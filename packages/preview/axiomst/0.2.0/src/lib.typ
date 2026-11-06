// axiomst: Academic homework and presentation slides template
// https://github.com/rezaarezvan/axiomst

// Re-export common components
#import "common.typ": (
  // Counters
  problem-counter,
  theorem-counter,
  definition-counter,
  lemma-counter,
  corollary-counter,
  example-counter,
  algorithm-counter,
  // State
  show-solutions-state,
  // Layout
  columns,
  // Academic elements
  theorem-base,
  theorem,
  lemma,
  definition,
  corollary,
  example,
  proof,
  problem,
  subquestions,
  solution,
  pfigure,
  ptable,
  instructions,
)

// Re-export homework template
#import "homework.typ": homework

// Re-export slides components
#import "slides.typ": (
  slides,
  slide,
  title-slide,
  section-slide,
  pause,
  uncover,
  only,
)
