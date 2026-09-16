#import "@preview/hydra:0.6.3": hydra
#import "@preview/codly:1.3.0": *
#import "@preview/theorion:0.6.0": *

#let default-names = toml("config/names.toml")
#let default-styles = toml("config/styles.toml")
#let default-info = toml("config/info.toml").global

#let latin-coverage() = regex("[\\p{Latin}\\p{Mark}0-9.,:;!?()\\[\\]'’\\-–—]")

#let font-platform-for(styles) = {
  let catalogs = styles.at("fonts", default: (:))
  let requested = sys.inputs.at(
    "qooklet-font-platform",
    default: styles.at("font-platform", default: "windows"),
  )
  if requested in catalogs {
    requested
  } else {
    catalogs.keys().first(default: requested)
  }
}

#let font-role-options(styles, lang, role) = {
  // Legacy schema: `[fonts.<lang>]` maps roles directly to font names.
  if "font-roles" not in styles {
    let fonts = styles.at("fonts", default: (:)).at(lang, default: (:))
    let font = if lang == "cjk-latin" {
      ""
    } else {
      fonts.at(role, default: fonts.at("default", default: ""))
    }
    if font == "" { return (:) }
    return (font: font)
  }

  let platform-fonts = styles
    .at("fonts", default: (:))
    .at(font-platform-for(styles), default: (:))
  let roles = styles.at("font-roles").at(lang)
  let family = roles.at(role, default: roles.at("default", default: ""))
  let font = platform-fonts.at(family, default: family)
  if font == "" { return (:) }
  if lang == "zh" {
    let latin-font = font-role-options(styles, "cjk-latin", role).at("font", default: font)
    return (font: ((name: latin-font, covers: latin-coverage()), font))
  }
  (font: font)
}

#let cjk-latin-style(
  body,
  font: "",
  styles: default-styles,
  lang: "en",
  role: "",
  as-style: false,
  ..options,
) = {
  let base-options = if role == "" {
    if font == "" { (:) } else { (font: font) }
  } else {
    font-role-options(styles, lang, role)
  }
  let apply-cjk-latin = body => {
    show latin-coverage(): set text(
      ..font-role-options(styles, "cjk-latin", role),
      weight: options.named().at("weight", default: "regular"),
    ) if lang == "zh" and role != ""
    body
  }
  if as-style {
    apply-cjk-latin(body)
  } else {
    apply-cjk-latin(text(body, ..base-options, ..options))
  }
}

#let tip = tip-block
#let note = note-block
#let quote = quote-block
#let warning = warning-block
#let caution = caution-block
