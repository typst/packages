// state.typ - Global configuration state
// Shared state between conf() and solve()

// Global state for sharing configuration
#let leetcode-config = state("leetcode-config", (
  show-answer: false,
))
