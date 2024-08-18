#let $id = (
  base      : rgb("$base"),
  surface   : rgb("$surface"),
  overlay   : rgb("$overlay"),
  muted     : rgb("$muted"),
  subtle    : rgb("$subtle"),
  text      : rgb("$text"),
  love      : rgb("$love"),
  gold      : rgb("$gold"),
  rose      : rgb("$rose"),
  pine      : rgb("$pine"),
  foam      : rgb("$foam"),
  iris      : rgb("$iris"),
  highlight : (
    low     : rgb("$highlightLow"),
    med     : rgb("$highlightMed"),
    high    : rgb("$highlightHigh"),
  ),
  codeThemePath: "themes/$id.tmTheme",
)

#let variant = $id
