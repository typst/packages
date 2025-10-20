// #import "@preview/clean-cnam-template:1.1.0": *
#import "src/lib.typ": *
// #import "src/your-outline-code.typ": your-outline-code

#show: clean-cnam-template.with(
  title: "Component Customization Showcase",
  author: "Tom Planche",
  class: "Template Documentation",
  subtitle: "Demonstrating Enhanced Components",
  logo: image("template/assets/cnam_logo.svg"),
  start-date: datetime(day: 7, month: 9, year: 2025),
  main-color: "#C4122E",
  // outline-code: your-outline-code
)

= Component Customization Showcase

This document demonstrates the enhanced customization capabilities of all template components.

== Math Components

All math components now support extensive customization including colors, spacing, borders, and more.

=== Standard Definition (Default Styling)

#definition(title: "Linéarité")[
  On dit que $phi$ est linéaire (homomorphisme) si:

  $
    phi(lambda_1 X_1 + lambda_2 X_2 + dots + lambda_n X_n) = lambda_1 phi(X_1) + lambda_2 phi(X_2) + dots + lambda_n phi(X_n)
  $
]

=== Custom Colored Definition

#definition(
  title: "Prime Number",
  fill: blue.lighten(95%),
  stroke: blue.darken(20%),
  inset: 1em,
  radius: 0.5em
)[
  A *prime number* is a natural number greater than 1 that has no positive divisors other than 1 and itself.
]

=== Standard Example (Default Styling)

#example(title: "Basic Example")[
  Basic text. \
  #lorem(20)
  $
    phi(0, 0, 0) = (0, 0) = 0_(RR^2) \
    phi(alpha X_1 + beta X_2) stretch(=)^"?" alpha phi(X_1) + beta phi(X_2) \
  $
]

=== Custom Colored Example

#example(
  title: "Factorial Calculation",
  fill: green.lighten(95%),
  stroke: green.darken(20%),
  inset: 1em
)[
  The factorial of 5 is calculated as:
  $
    5! = 5 times 4 times 3 times 2 times 1 = 120
  $
]

=== Standard Theorem (Default Styling)

#theorem(title: "Théorème de Stokes")[
  Soit $M$ une variété différentielle à bord, orientée de dimension $n$, et $omega$ une $(n – 1)"-forme"$ différentielle à support compact sur $M$ de classe $C_1$.\
  Alors, on a :

  $
    integral_M d omega = integral_{partial M} i^* omega
  $

  où $d$ désigne la dérivée extérieure, $partial M$ le bord de $M$, muni de l'orientation induite,\
  et $i^* omega = omega |_{partial M}$ la restriction de $omega$ à $partial M$.
]

=== Custom Colored Theorem (Breakable)

#theorem(
  title: "Pythagorean Theorem",
  fill: orange.lighten(95%),
  stroke: orange.darken(20%),
  breakable: true,
  radius: 0.5em
)[
  For any right triangle with sides $a$, $b$, and hypotenuse $c$:
  $
    a^2 + b^2 = c^2
  $
]

== Block Components

=== Standard `my-block` (Default)

#my-block[
  This is a standard block with default styling. It's centered with a light gray background.
]

=== Block with Title (Centered)

#my-block(
  title: "Important Note",
  title-align: center,
  fill: rgb("#fff3cd"),
  outline: 1pt + rgb("#856404"),
)[
  This block has a centered title and custom warning colors.
]

=== Full-Width Block with Right-Aligned Content

#my-block(
  title: "Right-Aligned Content",
  width: 100%,
  content-align: right,
  fill: rgb("#d1ecf1"),
  outline: 1pt + rgb("#0c5460"),
)[
  This content is aligned to the right within a full-width block.
]

=== Auto-Width Block (Left-Aligned)

#my-block(
  block-align: left,
  width: auto,
  fill: rgb("#d4edda"),
  outline: 1pt + rgb("#155724"),
)[
  This block fits its content width and is aligned to the left.
]

== Blockquote Components

=== Standard Blockquote (Default)

#blockquote[
  This is a standard blockquote with the default left border accent.
]

=== Blockquote with Attribution

#blockquote(
  attribution: "— Albert Einstein",
)[
  Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.
]

=== Right-Side Border with Centered Content

#blockquote(
  border-side: "right",
  content-align: center,
  attribution: "— Confucius",
  attribution-align: center,
)[
  I hear and I forget. I see and I remember. I do and I understand.
]

=== Full Border with Custom Styling

#blockquote(
  border-side: "all",
  color: blue,
  fill: blue.lighten(95%),
  attribution: "— Marie Curie",
  attribution-style: (size: 0.85em, style: "italic", fill: blue.darken(20%)),
)[
  Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less.
]

=== Top Border with Custom Width

#blockquote(
  border-side: "top",
  color: rgb("#C4122E"),
  fill: rgb("#C4122E").lighten(95%),
  width: 80%,
  block-align: center,
  attribution: "— Oscar Wilde",
)[
  Be yourself; everyone else is already taken.
]

== Code Components

=== Standard Code Block (Default)

#code(
  lang: "Python",
  ```python
  def fibonacci(n):
      if n <= 1:
          return n
      return fibonacci(n-1) + fibonacci(n-2)
  ```
)

=== Code with Title and Filename

#code(
  title: "String Utility Functions",
  title-align: center,
  filename: "src/string_utils.rs",
  lang: "Rust",
  ```rust
  /// Extension traits and utilities for string manipulation
  pub trait TitleCase {
      fn to_title_case(&self) -> String;
  }

  impl TitleCase for str {
      fn to_title_case(&self) -> String {
          self.split(|c: char| c.is_whitespace() || c == '_' || c == '-')
              .filter(|s| !s.is_empty())
              .map(|word| {
                  let mut chars = word.chars();
                  match chars.next() {
                      None => String::new(),
                      Some(first) => {
                          let first_upper = first.to_uppercase().collect::<String>();
                          let rest_lower = chars.as_str().to_lowercase();
                          format!("{}{}", first_upper, rest_lower)
                      }
                  }
              })
              .collect::<Vec<String>>()
              .join(" ")
      }
  }
  ```
)

=== Centered Code Block without Line Numbers

#code(
  block-align: center,
  width: 80%,
  numbering: false,
  lang: "TypeScript",
  fill: rgb("#f0f0f0"),
  ```typescript
  interface User {
      id: string;
      name: string;
      email: string;
  }

  type UserWithoutId = Omit<User, 'id'>;
  ```
)

=== Code with Line Range (Lines 5-15)

#code(
  title: "Partial Code View",
  lines: (5, 15),
  lang: "Python",
  filename: "algorithms.py",
  ```python
  def quicksort(arr):
      if len(arr) <= 1:
          return arr

      pivot = arr[len(arr) // 2]
      left = [x for x in arr if x < pivot]
      middle = [x for x in arr if x == pivot]
      right = [x for x in arr if x > pivot]

      return quicksort(left) + middle + quicksort(right)

  def binary_search(arr, target):
      left, right = 0, len(arr) - 1

      while left <= right:
          mid = (left + right) // 2
          if arr[mid] == target:
              return mid
          elif arr[mid] < target:
              left = mid + 1
          else:
              right = mid - 1

      return -1
  ```
)

== Vector Notation

For vectors, use `ar(X)` to get $ar(X)$.

#pagebreak()

= Summary of Customization Options

This template now provides extensive customization for all components:

#my-block(
  title: "Math Components",
  title-align: center,
  fill: rgb("#e7f3ff"),
)[
  - *definition*, *example*, *theorem*
  - Customize: fill, stroke, radius, inset, numbering, breakable
  - Full control over colors and spacing
]

#my-block(
  title: "Block Components",
  title-align: center,
  fill: rgb("#fff3e7"),
)[
  - *my-block*
  - Features: title, alignment (block & content), width control
  - Perfect for callouts, notes, and highlighted content
]

#my-block(
  title: "Blockquote Components",
  title-align: center,
  fill: rgb("#f3e7ff"),
)[
  - *blockquote*
  - Features: attribution, border positioning, alignment
  - Support for all four sides or full border
]

#my-block(
  title: "Code Components",
  title-align: center,
  fill: rgb("#e7ffe7"),
)[
  - *code*
  - Features: title, line numbers, line ranges, custom styling
  - Extensive options for professional code display
]
