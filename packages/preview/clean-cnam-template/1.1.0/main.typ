#import "@preview/clean-cnam-template:1.1.0": *
// #import "src/your-outline-code.typ": your-outline-code

#show: clean-cnam-template.with(
  title: "Main Title",
  author: "Tom Planche",
  class: "Class name",
  subtitle: "Class subtitle",
  logo: image("template/assets/cnam_logo.svg"),
  start-date: datetime(day: 7, month: 9, year: 2025),
  main-color: "#C4122E",
  // outline-code: your-outline-code
)

= Main title
== Maths

For my maths class, I made these things:

=== `#definition`

#definition(title: "Linéarité")[
    \ On dit que $phi$ est linéaire (homomorphisme) si:

    $
        phi(lambda_1 X_1 + lambda_2 X_2 + dots + lambda_n X_n) = lambda_1 phi(X_1) + lambda_2 phi(X_2) + dots + lambda_n phi(X_n)
    $
]

=== `#example`

#example(title: "Example title")[
    Basic text. \
    #lorem(20)
  $
      phi(0, 0, 0) = (0, 0)     = 0_(RR^2) \
      phi(alpha X_1 + beta X_2) stretch(=)^"?" alpha phi(X_1) + beta phi(X_2) \
  $
]

=== `#theorem`
==== With `title`

#theorem(title: "Théorème de Stokes")[
    \
    Soit $M$ une variété différentielle à bord, orientée de dimension $n$, et $omega$ une $(n – 1)"-forme"$ différentielle à support compact sur $M$ de classe $C_1$.\
    Alors, on a :

    $
        integral_M d omega = integral_{partial M} i^* omega
    $

    où $d$ désigne la dérivée extérieure, $partial M$ le bord de $M$, muni de l'orientation induite,\
    et $i^* omega = omega |_{partial M}$ la restriction de $omega$ à $partial M$.

]
==== Without `title`

#theorem[
    \
    Soit $E$ un espace vectoriel de dimension finie, $F$ un sous-espace vectoriel de $E$ et $B = (X_1, X_2, dots, X_n)$ une base de $F$. \
    Alors, il existe une base $(X_1, X_2, dots, X_n, X_{n+1}, dots, X_m)$ de $E$ telle que $(X_1, X_2, dots, X_n)$ soit une base de $F$.
]

=== `ar`

For vectors, I use `ar(X)` and it gives $ar(X)$.

== Subtitle
=== Subsubtitle

#my-block(
  [
  Custom Block
  ]
)

#blockquote([
  Custom Blockquote
])

`Basic inline raw text`

This code block uses `#code()` macro.

#code(
  filename: "src/string_utils.rs",
  ```rust
  /// Extension traits and utilities for string manipulation
  ///
  /// This module provides additional functionality for working with strings,
  /// including title case conversion and other string transformations.
  use std::string::String;

  /// Trait that adds title case functionality to String and &str types
  pub trait TitleCase {
      /// Converts the string to title case where each word starts with an uppercase letter
      /// and the rest are lowercase
      ///
      fn to_title_case(&self) -> String;
  }

  impl TitleCase for str {
      fn to_title_case(&self) -> String {
          self.split(|c: char| c.is_whitespace() || c == '_' || c == '-')
              .filter(|s| !s.is_empty())
              .map(|word| {
                  // If the word is all uppercase and longer than 1 character, preserve it
                  if word.chars().all(|c| c.is_uppercase()) && word.len() > 1 {
                      word.to_string()
                  } else {
                      let mut chars = word.chars();
                      match chars.next() {
                          None => String::new(),
                          Some(first) => {
                              let first_upper = first.to_uppercase().collect::<String>();
                              let rest_lower = chars.as_str().to_lowercase();
                              format!("{}{}", first_upper, rest_lower)
                          }
                      }
                  }
              })
              .collect::<Vec<String>>()
              .join(" ")
      }
  }

  impl TitleCase for String {
      fn to_title_case(&self) -> String {
          self.as_str().to_title_case()
      }
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn test_title_case_str() {
          assert_eq!("hello world".to_title_case(), "Hello World");
          assert_eq!("HASH_TABLE".to_title_case(), "HASH TABLE");
          assert_eq!("dynamic-programming".to_title_case(), "Dynamic Programming");
          assert_eq!("BFS".to_title_case(), "BFS");
          assert_eq!("two-sum".to_title_case(), "Two Sum");
          assert_eq!("binary_search_tree".to_title_case(), "Binary Search Tree");
          assert_eq!("   spaced   words   ".to_title_case(), "Spaced Words");
          assert_eq!("".to_title_case(), "");
      }
  }
  ```
)
