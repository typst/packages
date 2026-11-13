#import "defaults.typ": merge
#import "themes.typ": theme-config

/// Resolve the appearance config used by the letter and invoice templates.
///
/// Starts from the template-specific defaults, applies a named palette, then
/// applies direct template arguments and finally the nested config, so
/// explicit config values have highest precedence. Only the closed appearance
/// groups and keys listed below are accepted; unsupported groups or keys fail
/// with an assertion.
///
/// - template-defaults (dictionary): complete template appearance defaults
/// - theme (str, none): palette name accepted by theme-config; none keeps
///   the defaults' colors
/// - direct (dictionary): normalized direct appearance arguments, such as
///   paper, margins, font, font size, leading, and justification
/// - config (dictionary): nested overrides. page accepts paper and margin;
///   typography accepts font, size, leading, justify, and hyphenate; colors
///   accepts bg-paper, brand-primary, and text-main; links accepts color and
///   url-color. Every group value must be a dictionary.
///   These postal templates reject every other shared or extension field. The
///   shared config schema and baseline values are documented once on the
///   exported `defaults` dictionary; hover `satz.defaults` with a namespace import.
///   Accepted postal config values override direct arguments; direct arguments
///   override the selected theme and template defaults. Every accepted field is
///   consumed by the postal templates.
/// -> dictionary: merged appearance settings; the inputs are not mutated
#let resolve-postal-appearance(template-defaults, theme, direct, config) = {
  let supported = (
    page: ("paper", "margin"),
    typography: ("font", "size", "leading", "justify", "hyphenate"),
    colors: ("bg-paper", "brand-primary", "text-main"),
    links: ("color", "url-color"),
  )
  for (group, options) in config {
    assert(group in supported,
      message: "Unsupported appearance config group `" + group + "`. Supported groups are page, typography, colors, and links.")
    assert(type(options) == dictionary,
      message: "Appearance config `" + group + "` must be a dictionary.")
    for (key, _) in options {
      assert(key in supported.at(group),
        message: "Unsupported appearance setting `" + group + "." + key + "` for letters and invoices.")
    }
  }
  let themed = merge(template-defaults, theme-config(theme))
  merge(merge(themed, direct), config)
}
