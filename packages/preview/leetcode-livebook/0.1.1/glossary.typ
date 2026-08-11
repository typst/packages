// glossary.typ - Central terminology definitions
// This module provides automatic term highlighting and a glossary page

// Term definitions: (definition, external-link)
#let terms = (
  // Data Structures
  "array": (
    definition: "A collection of elements stored at contiguous memory locations.",
    link: "https://en.wikipedia.org/wiki/Array_(data_structure)",
  ),
  "subarray": (
    definition: "A contiguous part of an array. Unlike subsequence, elements must be adjacent.",
    link: "https://www.geeksforgeeks.org/subarraysubstring-vs-subsequence-and-programs-to-generate-them/",
  ),
  "subsequence": (
    definition: "A sequence derived by deleting some elements without changing order. Elements need not be contiguous.",
    link: "https://www.geeksforgeeks.org/subarraysubstring-vs-subsequence-and-programs-to-generate-them/",
  ),
  "linked list": (
    definition: "A linear data structure where elements are stored in nodes, each pointing to the next.",
    link: "https://en.wikipedia.org/wiki/Linked_list",
  ),
  "binary tree": (
    definition: "A tree data structure where each node has at most two children (left and right).",
    link: "https://en.wikipedia.org/wiki/Binary_tree",
  ),
  "hash table": (
    definition: "A data structure that maps keys to values using a hash function.",
    link: "https://en.wikipedia.org/wiki/Hash_table",
  ),
  "stack": (
    definition: "A LIFO (Last In, First Out) data structure.",
    link: "https://en.wikipedia.org/wiki/Stack_(abstract_data_type)",
  ),
  "queue": (
    definition: "A FIFO (First In, First Out) data structure.",
    link: "https://en.wikipedia.org/wiki/Queue_(abstract_data_type)",
  ),
  "heap": (
    definition: "A tree-based data structure satisfying the heap property (parent ≥ or ≤ children).",
    link: "https://en.wikipedia.org/wiki/Heap_(data_structure)",
  ),
  "graph": (
    definition: "A data structure consisting of vertices (nodes) connected by edges.",
    link: "https://en.wikipedia.org/wiki/Graph_(abstract_data_type)",
  ),
  "trie": (
    definition: "A tree-like data structure for storing strings, where each node represents a character.",
    link: "https://en.wikipedia.org/wiki/Trie",
  ),
  // Algorithms & Techniques
  "dynamic programming": (
    definition: "An optimization technique that solves problems by breaking them into overlapping subproblems.",
    link: "https://en.wikipedia.org/wiki/Dynamic_programming",
  ),
  "backtracking": (
    definition: "An algorithmic technique that builds solutions incrementally and abandons invalid paths.",
    link: "https://en.wikipedia.org/wiki/Backtracking",
  ),
  "binary search": (
    definition: "A search algorithm that repeatedly divides a sorted array in half.",
    link: "https://en.wikipedia.org/wiki/Binary_search_algorithm",
  ),
  "two pointers": (
    definition: "A technique using two pointers to traverse a data structure, often from opposite ends.",
    link: "https://www.geeksforgeeks.org/two-pointers-technique/",
  ),
  "sliding window": (
    definition: "A technique that maintains a window of elements while iterating through a sequence.",
    link: "https://www.geeksforgeeks.org/window-sliding-technique/",
  ),
  "divide and conquer": (
    definition: "An algorithm design paradigm that breaks a problem into smaller subproblems, solves them, and combines results.",
    link: "https://en.wikipedia.org/wiki/Divide-and-conquer_algorithm",
  ),
  "greedy": (
    definition: "An algorithmic paradigm that makes locally optimal choices at each step.",
    link: "https://en.wikipedia.org/wiki/Greedy_algorithm",
  ),
  "recursion": (
    definition: "A method where a function calls itself to solve smaller instances of the same problem.",
    link: "https://en.wikipedia.org/wiki/Recursion_(computer_science)",
  ),
  "memoization": (
    definition: "An optimization technique that stores results of expensive function calls.",
    link: "https://en.wikipedia.org/wiki/Memoization",
  ),
  // Problem Types
  "palindrome": (
    definition: "A sequence that reads the same forwards and backwards.",
    link: "https://en.wikipedia.org/wiki/Palindrome",
  ),
  "permutation": (
    definition: "An arrangement of elements in a specific order.",
    link: "https://en.wikipedia.org/wiki/Permutation",
  ),
  "combination": (
    definition: "A selection of elements where order does not matter.",
    link: "https://en.wikipedia.org/wiki/Combination",
  ),
  "subset": (
    definition: "A set containing some or all elements of another set.",
    link: "https://en.wikipedia.org/wiki/Subset",
  ),
  "substring": (
    definition: "A contiguous sequence of characters within a string.",
    link: "https://www.geeksforgeeks.org/subarraysubstring-vs-subsequence-and-programs-to-generate-them/",
  ),
  "matrix": (
    definition: "A 2D array organized in rows and columns.",
    link: "https://en.wikipedia.org/wiki/Matrix_(mathematics)",
  ),
  "sorted array": (
    definition: "An array where elements are arranged in ascending or descending order.",
    link: "https://en.wikipedia.org/wiki/Sorted_array",
  ),
  "bfs": (
    definition: "Breadth-First Search: explores neighbors level by level.",
    link: "https://en.wikipedia.org/wiki/Breadth-first_search",
  ),
  "dfs": (
    definition: "Depth-First Search: explores as far as possible before backtracking.",
    link: "https://en.wikipedia.org/wiki/Depth-first_search",
  ),
  "bit manipulation": (
    definition: "Techniques using bitwise operators to solve problems efficiently.",
    link: "https://en.wikipedia.org/wiki/Bit_manipulation",
  ),
  "prefix sum": (
    definition: "An array where each element is the sum of all previous elements.",
    link: "https://en.wikipedia.org/wiki/Prefix_sum",
  ),
)

// Term styling
#let term-color = rgb("#0066cc")

// Create a styled term that links to external resource directly
// This avoids the issue of missing internal labels when glossary-page is not called
#let term(word) = {
  let key = lower(word)
  let info = terms.at(key, default: none)
  if info != none {
    link(info.link)[
      #text(fill: term-color)[#underline(
        stroke: 0.5pt + term-color.lighten(50%),
        offset: 2pt,
      )[#word]]
    ]
  } else {
    word
  }
}

// Create a term that links to internal glossary (use only when glossary-page is included)
#let term-internal(word) = {
  let key = lower(word)
  let info = terms.at(key, default: none)
  if info != none {
    link(label("glossary-" + key))[
      #text(fill: term-color)[#underline(
        stroke: 0.5pt + term-color.lighten(50%),
        offset: 2pt,
      )[#word]]
    ]
  } else {
    word
  }
}

// Generate the glossary page
#let glossary-page() = {
  pagebreak(weak: true)
  heading(level: 1, outlined: true)[Glossary]

  set text(size: 10pt)

  for (key, info) in terms.pairs().sorted(key: p => p.at(0)) {
    block(inset: (bottom: 8pt))[
      #text(weight: "bold", size: 11pt)[#key] #label("glossary-" + key)
      #h(1em)
      #text(fill: gray.darken(20%))[#info.definition]
      #h(0.5em)
      #link(info.link)[#text(fill: term-color, size: 9pt)[\[→\]]]
    ]
  }
}

// Apply automatic term highlighting to content (links to external URLs)
// Use sparingly as it can impact performance
#let with-glossary(body) = {
  // Only highlight specific high-value terms to avoid performance issues
  show "subarray": it => term("subarray")
  show "subsequence": it => term("subsequence")
  show "palindrome": it => term("palindrome")
  show "binary tree": it => term("binary tree")
  show "linked list": it => term("linked list")
  show "dynamic programming": it => term("dynamic programming")
  show "backtracking": it => term("backtracking")
  show "sliding window": it => term("sliding window")
  show "two pointers": it => term("two pointers")

  body
}

// Apply automatic term highlighting with internal glossary links
// Only use when glossary-page() is included in the document
#let with-glossary-internal(body) = {
  show "subarray": it => term-internal("subarray")
  show "subsequence": it => term-internal("subsequence")
  show "palindrome": it => term-internal("palindrome")
  show "binary tree": it => term-internal("binary tree")
  show "linked list": it => term-internal("linked list")
  show "dynamic programming": it => term-internal("dynamic programming")
  show "backtracking": it => term-internal("backtracking")
  show "sliding window": it => term-internal("sliding window")
  show "two pointers": it => term-internal("two pointers")

  body
}
