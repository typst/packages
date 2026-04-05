#import "@preview/valkyrie:0.2.1" as z

/// Title content denerator, the result will be inserted into the document.
///
/// - meta (dict): document meta information
/// - theme (dict): theme obj
/// - title-style (str | none): expected to be `"whole-page"`, `none` or `"simple"`, default to `"whole-page"`
/// -> content
#let title-content(
  meta,
  theme,
  title-style,
  ..opt,
) = {
  z.parse(title-style, z.string())
  if title-style == "whole-page" {
    return (theme.title.whole-page)()
  } else if title-style == "simple" {
    return (theme.title.simple)()
  } else if title-style == "none" {
    return []
  }
  return []
}