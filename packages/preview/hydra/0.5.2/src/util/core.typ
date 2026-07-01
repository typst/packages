#import "@preview/oxifmt:0.2.1": strfmt as fmt

/// Substitute `value` for the return value of `default()` if it is a sentinel value.
///
/// - value (any): The value to check.
/// - default (function): The function to produce the default value with.
/// - check (any): The sentinel value to check for.
/// -> any
#let or-default(value, default, check: none) = if value == check { default() } else { value }

/// An alias for `or-default` with `check: auto`.
#let auto-or = or-default.with(check: auto)

/// An alias for `or-default` with `check: none`.
#let none-or = or-default.with(check: none)

/// Returns the text direction for a given language, defaults to `ltr` for unknown languages.
///
/// Source: #link("https://github.com/typst/typst/blob/9646a132a80d11b37649b82c419833003ac7f455/crates/typst/src/text/lang.rs#L50-57")[`lang.rs#L50-L57`]
///
/// lang (str): The languge to get the text direction for.
/// -> direction
#let text-direction(lang) = if lang in (
  "ar", "dv", "fa", "he", "ks", "pa", "ps", "sd", "ug", "ur", "yi",
) { rtl } else { ltr }

/// Returns the page binding for a text direction.
///
/// Source: #link("https://github.com/typst/typst/blob/9646a132a80d11b37649b82c419833003ac7f455/crates/typst/src/layout/page.rs#L368-L373")[`page.rs#L368-L373`]
///
/// dir (direction): The direction to get the page binding for.
/// -> alignement
#let page-binding(dir) = (ltr: left, rtl: right).at(repr(dir))

/// A list of queryable element functions.
#let queryable-functions = (
  bibliography,
  cite,
  figure,
  footnote,
  heading,
  locate,
  math.equation,
  metadata,
  ref,
)

