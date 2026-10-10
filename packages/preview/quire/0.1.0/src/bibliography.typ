/// This module configures the bibliography.
#import "i18n.typ": translate

/// Applies the bibliography settings: a localized, unnumbered title at the level of chapters (or sections, without
/// chapters). The citation and bibliography styles are left to Typst's defaults, to be set by the user.
///
/// -> content
#let _bibliography-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set bibliography(title: translate("bibliography"))

  let level = cfg.levels.at("chapter", default: cfg.levels.section)
  show bibliography: set heading(numbering: none, offset: level - 1)

  body
}
