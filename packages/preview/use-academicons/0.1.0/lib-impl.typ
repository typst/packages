/// Render an Academicon by its name or unicode
// based on duskmoons typst-fontawesome 
// https://github.com/duskmoon314/typst-fontawesome

/// Parameters:
/// - `name`: The name of the icon
///   - This can be name in string or unicode of the icon
/// - `ai-icon-map`: The map of icon names to unicode
///   - Default is a map generated from Academicons CSS
///   - *Not recommended* You can provide your own map to override it
/// - `..args`: Additional arguments to pass to the `text` function
///
/// Returns: The rendered icon as a `text` element
#let ai-icon(
  name,
  ai-icon-map: (:),
  ..args,
) = {
  text(
    font: ("Academicons"),
    weight: { 400 },
    // If the name is in the map, use the unicode from the map
    // If not, pass the name and let the ligature feature handle it
    ai-icon-map.at(name, default: name),
    ..args,
  )
}
