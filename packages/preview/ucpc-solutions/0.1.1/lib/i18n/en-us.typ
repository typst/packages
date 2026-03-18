#let make-prob-meta = (
  difficulty_prefix: "Difficulty — ",
  difficulty_postfix: "",
  author: "Author",
  authors: "Authors",
  submitted_prefix: "",
  submitted_postfix: " Submitted",
  passed_prefix: "",
  passed_postfix: " Passed",
  ac-ratio_prefix: "AC Ratio: ",
  ac-ratio_postfix: "%",
  first-solver_prefix: "First Solver: ",
  first-solver_postfix: "",
  online-open-contest: "Online Open Contet",
  offline-onsite-contest: "Offline Onsite Contest",
  first_solved_at_prefix: "+",
  first_solved_at_postfix: "min",
)

#let make-prob-overview = (
  problem: "Problem",
  difficulty: "Difficulty",
  author: "Author",
)

#let make-problem = (
  make-prob-meta: make-prob-meta
)

#let problem = make-problem
