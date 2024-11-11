/// Render a [Tabler icon](https://tabler.io/icons) by its name or unicode.
///
/// Parameters:
/// - `icon`: The name of the icon
///   - This can be name in string or unicode of the icon
/// - `tabler-icon-map`: The map of icon names to unicode
///   - Default is a map generated from Tabler metadata
///   - *Not recommended* You can provide your own map to override it
/// - `..args`: Additional arguments to pass to the `text` function
///
/// Returns: The rendered icon as a `text` element
#let tabler-icon(
  icon,
  tabler-icon-map: (:),
  ..args,
) = {
  text(
    font: "tabler-icons",
    // If the name is in the map, use the unicode from the map
    // If not, pass the name and let the ligature feature handle it
    tabler-icon-map.at(icon, default: icon),
    ..args,
  )
}
