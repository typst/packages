#import "/src/_pkgs.typ": oxifmt.strfmt as fmt

/// Substitute @cmd:or-default.value for the return value of
/// @cmd:or-default.default if it is equal to @cmd:or-default.check value.
///
/// -> any
#let or-default(
  /// The value to check.
  ///
  // -> any
  value,
  /// The function to produce the default value with.
  ///
  // -> function
  default,
  /// The sentinel value to check for.
  ///
  // -> any
  check: none,
) = if value == check { default() } else { value }

/// An alias for #utils.rawi(lang: "typc", `or-default.with(check: auto)`).
#let auto-or = or-default.with(check: auto)

/// An alias for #utils.rawi(lang: "typc", `or-default.with(check: none)`).
#let none-or = or-default.with(check: none)

/// Returns the text direction for a given language, defaults to #builtin("ltr")
/// for unknown languages.
///
/// Source: #link(
///   "https://github.com/typst/typst/blob/9646a132a80d11b37649b82c419833003ac7f455/crates/typst/src/text/lang.rs#L50-57"
/// )[`lang.rs#L50-L57`]
///
/// -> direction
#let text-direction(
  /// The languge to get the text direction for.
  ///
  /// -> str
  lang,
) = if (
  lang
    in (
      "ar",
      "dv",
      "fa",
      "he",
      "ks",
      "pa",
      "ps",
      "sd",
      "ug",
      "ur",
      "yi",
    )
) { rtl } else { ltr }

/// Returns the page binding for a text direction.
///
/// Source: #link(
///   "https://github.com/typst/typst/blob/9646a132a80d11b37649b82c419833003ac7f455/crates/typst/src/layout/page.rs#L368-L373"
/// )[`page.rs#L368-L373`]
///
/// -> alignment
#let page-binding(
  /// The direction to get the page binding for.
  ///
  /// -> direction
  dir,
) = (ltr: left, rtl: right).at(repr(dir))

/// A list of @type:queryable element functions.
///
/// -> array
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

