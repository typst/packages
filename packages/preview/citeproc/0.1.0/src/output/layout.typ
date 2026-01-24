// citeproc-typst - Layout Selection Module
//
// Provides layout selection logic for CSL-M multilingual support.

#import "../parsing/locales.typ": locale-matches

// =============================================================================
// Layout Selection (CSL-M enhanced)
// =============================================================================

/// Select appropriate layout based on entry language
///
/// Supports CSL-M multilingual layout selection where each layout
/// can specify a locale attribute with space-separated language codes.
///
/// Examples:
///   - <layout locale="en es de"> matches entries in English, Spanish, German
///   - <layout locale="zh"> matches Chinese entries
///   - <layout> (no locale) is the default fallback
///
/// - layouts: Array of layout nodes from CSL
/// - entry-lang: The entry's detected language (e.g., "en", "zh-CN")
/// Returns: Matching layout node or none
#let select-layout(layouts, entry-lang) = {
  if layouts.len() == 0 { return none }

  // Try to find locale-specific layout using CSL-M matching
  let matching = layouts.find(l => {
    let locale = l.at("locale", default: none)
    if locale == none { return false }
    locale-matches(entry-lang, locale)
  })

  if matching != none { return matching }

  // Fallback to layout without locale (default/last)
  let default = layouts.find(l => l.at("locale", default: none) == none)
  if default != none { return default }

  // Last resort: last layout (CSL-M spec: last layout is default)
  layouts.last()
}
