// # Source. Fonte.
// NBR 14724:2024 5.8, NBR 14724:2024 5.9

#let source_for_content_created_by_authors(
  start_with_uppercase: false,
) = {
  // NBR 14724:2024
  [#if start_with_uppercase { "E" } else { "e" }laboração própria]
}
