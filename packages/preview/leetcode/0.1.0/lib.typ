// lib.typ - LeetCode Package API
// Public entrypoint for @preview/leetcode package
//
// This file re-exports all public functions from submodules.
//
// Exported functions:
// - conf(...) — document configuration with filtering and practice mode
// - problem(id), test(id, fn), answer(id), solve(id, code-block), get-test-cases(id), get-problem-path(id)
// - get-problem-info(id) — returns metadata from problem.toml
// - filter-problems(...), available-problems — filtering utilities
// - linkedlist(arr), binarytree(arr), fill(value, n), display(value)
// - ll-node(list, id), ll-val(list, id), ll-next(list, id), ll-values(list) — linked list helpers
// - unordered-compare(a, b), float-compare(a, b), testcases(...) — testing utilities
//
// Usage examples:
//   // Default mode - show all problems with test results
//   #show: conf.with()
//
//   // Practice mode - manual control, user writes solutions
//   #show: conf.with(practice: true)
//   #problem(1)
//   #let my-solution(...) = { ... }
//   #test(1, my-solution)
//
//   // Filtered mode - show only specific problems
//   #show: conf.with(difficulty: "easy", labels: ("array",))

// Re-export from helpers (data structures, utilities)
#import "helpers.typ": *

// Re-export from submodules
#import "problems.typ": (
  available-problems, format-id, get-problem-info, get-problem-path,
  get-test-cases,
)
#import "badges.typ": difficulty-badge, difficulty-colors, label-badge
#import "render.typ": answer, problem
#import "workbook.typ": conf, filter-problems, solve, test
