// workbook.typ - Practice workbook API (conf, solve, filter-problems, test)
// Depends on: state.typ, problems.typ, render.typ, validators.typ, testing.typ

#import "state.typ": leetcode-config
#import "problems.typ": available-problems, format-id, get-problem-info
#import "render.typ": answer, problem
#import "validators.typ": load-validator
#import "testing.typ": testcases

// Filter problems by various criteria
// - ids: specific problem IDs to include (takes precedence if provided)
// - id-range: (start, end) inclusive range
// - difficulty: "easy" | "medium" | "hard"
// - labels: array of labels (matches if problem has ANY of these labels)
// All conditions are combined with AND logic (except labels which use OR internally)
#let filter-problems(
  ids: none,
  id-range: none,
  difficulty: none,
  labels: none,
) = {
  // Start with all available problems or specified IDs
  let result = if ids != none { ids } else { available-problems }

  // Filter by id-range (inclusive)
  if id-range != none {
    let (start, end) = id-range
    result = result.filter(id => id >= start and id <= end)
  }

  // Filter by difficulty
  if difficulty != none {
    result = result.filter(id => {
      let info = get-problem-info(id)
      info.at("difficulty", default: "") == difficulty
    })
  }

  // Filter by labels (OR logic: match if problem has ANY of the specified labels)
  if labels != none and labels.len() > 0 {
    result = result.filter(id => {
      let info = get-problem-info(id)
      let problem-labels = info.at("labels", default: ())
      // Check if any of the filter labels match
      labels.any(label => label in problem-labels)
    })
  }

  result
}

// Automatic test with built-in test cases and metadata
#let test(
  id,
  solution-fn,
  extra-cases: none,
  default-cases: true,
) = {
  let id-str = format-id(id)
  let base = "problems/" + id-str + "/"

  import (base + "solution.typ"): solution
  import (base + "testcases.typ"): cases

  let cases = if default-cases {
    if type(extra-cases) == array {
      (..cases, ..extra-cases)
    } else if type(extra-cases) == dictionary {
      (..cases, extra-cases)
    } else {
      cases
    }
  } else {
    extra-cases
  }

  // Load metadata from problem.toml
  let info = toml(base + "problem.toml")

  // Load validator (handles both named and custom validators)
  let val = load-validator(id-str, base)

  // Try to load custom-display from display.typ if flag is set
  let custom-disp = none
  if info.at("custom-display", default: false) {
    import (base + "display.typ"): custom-display
    custom-disp = custom-display
  }

  // Try to load custom-output-display from display.typ if flag is set
  let custom-output-disp = none
  if info.at("custom-output-display", default: false) {
    import (base + "display.typ"): custom-output-display
    custom-output-disp = custom-output-display
  }

  testcases(
    solution-fn,
    solution,
    cases,
    validator: val,
    custom-display: custom-disp,
    custom-output-display: custom-output-disp,
  )
}

// Complete workflow: display problem + code + test solution
// Usage:
//   #solve(1, code-block: ```typst
//   let solution(nums, target) = { ... }
//   ```)
//
// Or just view the problem without solving:
//   #solve(1)
//
// Parameters:
// - id: problem ID
// - code-block: user's solution code (optional)
// - show-answer: show reference solution (auto = use global config, true/false = override)
// - extra-cases: additional test cases to add
// - default-cases: if false, only use extra-cases (ignore built-in cases)
//
// Note: Don't use # prefix in code-block (it's eval'd in code mode)
// The main function name must be "solution" when code-block is provided
#let solve(
  id,
  code-block: none,
  show-answer: auto,
  extra-cases: none,
  default-cases: true,
) = {
  // Display problem
  problem(id)

  // Determine whether to show answer (global config or local override)
  context {
    let cfg = leetcode-config.get()
    let should-show-answer = if show-answer == auto {
      cfg.show-answer
    } else {
      show-answer
    }

    if should-show-answer {
      answer(id)
    }
  }

  // If no code block provided, just show the problem (and possibly answer)
  if code-block == none {
    return
  }

  // Display user's solution code (blue color to distinguish from reference)
  heading(level: 2, outlined: false, numbering: none)[
    #text(fill: blue.darken(20%))[My Solution \##id]
  ]
  {
    show raw: it => block(stroke: 0.8pt + blue.lighten(50%), inset: 0.6em, it)
    code-block
  }

  // Execute the code and test
  let solution-fn = eval(code-block.text + "\n" + "solution")
  test(id, solution-fn, extra-cases: extra-cases, default-cases: default-cases)
}

// Document configuration function for practice workbook mode
// Usage: #show: conf.with(ids: (1, 2, 3), difficulty: "medium", practice: true)
//
// Parameters:
// - ids: specific problem IDs to include
// - id-range: (start, end) inclusive range filter
// - difficulty: "easy" | "medium" | "hard" filter
// - labels: array of labels (matches problems with ANY of these labels)
// - practice: if true, don't auto-render problems (user controls via solve())
// - show-answer: if true, show reference solution code after each problem
// - show-title: if true, show the title page
// - show-outline: if true, show table of contents
#let conf(
  ids: none,
  id-range: none,
  difficulty: none,
  labels: none,
  practice: false,
  show-answer: false,
  show-title: true,
  show-outline: true,
  body,
) = {
  // Update global config state (for solve() to read)
  leetcode-config.update(cfg => (
    show-answer: show-answer,
  ))

  // Title page
  if show-title {
    align(center)[
      #v(3fr)
      #box(baseline: 12pt)[#image("images/logo.png", height: 48pt)]
      #h(12pt)
      #text(48pt)[*Leetcode.typ*]
      #v(6fr)
      // Authors
      #if not practice {
        text(
          size: 24pt,
        )[Gabriel Wu (#link("https://github.com/lucifer1004", "@lucifer1004"))]
      }
      #v(1fr)
      // Build date
      #text(size: 20pt)[
        #datetime.today().display("[month repr:long] [day], [year]")
      ]
      #v(2cm)
    ]
    pagebreak()
  }

  // Table of contents with roman numerals
  if show-outline {
    set page(numbering: "i")
    counter(page).update(1)
    show outline.entry: set block(above: 1.2em)
    outline()
    pagebreak()
  }

  // Document styling - reset to arabic numerals starting from 1
  counter(page).update(1)
  set smartquote(enabled: false)
  set par(justify: true)
  set page(numbering: "1")
  show link: it => {
    set text(blue)
    underline(it)
  }
  show heading.where(level: 1, outlined: true): it => {
    pagebreak(weak: true)
    it
    v(1.5em)
  }

  // Get filtered problems
  let problems-to-show = filter-problems(
    ids: ids,
    id-range: id-range,
    difficulty: difficulty,
    labels: labels,
  )

  // Render problems based on mode
  if not practice {
    // Normal mode: auto-render all filtered problems with test results
    for problem-id in problems-to-show {
      problem(problem-id)
      if show-answer {
        answer(problem-id)
      }
      test(problem-id, (..args) => none)
    }
  }
  // Practice mode: don't auto-render problems
  // User has full control via problem() and test() in body

  // Include body content (user's solutions, tests, etc.)
  body
}
