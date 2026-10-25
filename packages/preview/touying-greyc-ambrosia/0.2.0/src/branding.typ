#import "assets.typ"
#import "colors.typ"

#let team-names = assets.asset-paths.logo-teams.keys()
#let normalize-team(team) = {
  if team == none { return none }
  assert(type(team) == str, message: "Team must be a name or none.")
  let name = lower(team.trim())
  if name in ("elec", "électronique") { name = "electronique" }
  assert(name in team-names, message: "Unknown GREYC team: " + team + ". Choose: " + team-names.join(", ") + ".")
  name
}

#let team-color(team) = {
  let team = normalize-team(team)
  if team == none { colors.primary }
  else { colors.teams.at(if team == "electronique" { "elec" } else { team }) }
}

// Read each SVG once at module initialization. Recoloring retains team accents.
#let _lab = (
  en: str(assets.read-asset(assets.asset-paths.logo-greyc.en)),
  fr: str(assets.read-asset(assets.asset-paths.logo-greyc.fr)),
  small: str(assets.read-asset(assets.asset-paths.logo-greyc.small)),
)
#let _teams = {
  let result = (:)
  for (name, variants) in assets.asset-paths.logo-teams {
    let cached = (:)
    for (variant, path) in variants { cached.insert(variant, str(assets.read-asset(path))) }
    result.insert(name, cached)
  }
  result
}

#let logo-data(team: none, variant: "full", lang: "en", light: false) = {
  let team = normalize-team(team)
  let data = if team == none {
    _lab.at(if variant == "small" { "small" } else if lang == "fr" { "fr" } else { "en" })
  } else { _teams.at(team).at(variant) }
  if light { assets.colorize-svg(data, source: colors.logo, target: colors.logo-light) } else { data }
}

#let logo(team: none, variant: "full", lang: "en", light: false, opacity: 100%, ..args) = {
  let data = logo-data(team: team, variant: variant, lang: lang, light: light)
  if opacity != 100% { data = assets.transparentize-svg(data, opacity: opacity) }
  image(bytes(data), ..args)
}

/// A monochrome lab symbol for decorative watermarks; ordinary logos stay intact.
#let watermark-data(fill) = bytes(_lab.small.replace(
  regex("#[A-Fa-f0-9]{6}\\b"), _ => fill.rgb().to-hex(),
))
