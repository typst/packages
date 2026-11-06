// based on duskmoons typst-fontawesome 
// https://github.com/duskmoon314/typst-fontawesome

// Implementation of `ai-icon`
#import "lib-impl.typ": *

// Generated icons
#import "lib-gen.typ": *

// Re-export the `ai-icon` function
// The following doc comment is needed for lsp to show the documentation

/// Render a Academicon by its name or unicode
///
/// Parameters:
/// - `name`: The name of the icon
///   - This can be name in string or unicode of the icon
/// - `ai-icon-map`: The map of icon names to unicode
///   - Default is a map generated from Academicons CSS
///   - *Not recommended* You can provide your own map to override it
/// - `..args`: Additional arguments to pass to the `text` function
///
/// Returns: The rendered icon as a `text` element
#let ai-icon = ai-icon.with(ai-icon-map: ai-icon-map)

/// Render multiple Font Awesome icons together
///
/// Parameters:
/// - `icons`: The list of icons to render
///   - Multiple types are supported:
///     - `str`: The name of the icon, e.g. `"lattes"`
///     - `array`: A tuple of the name and additional arguments, e.g. `("lattes", (fill: white))`
///     - `arguments`: Arguments to pass to the `ai-icon` function, e.g. `arguments("lattes", fill: white)`
///     - `content`: Any other content you want to render, e.g. `ai-lattes(fill: white)`
/// - `box-args`: Additional arguments to pass to the `box` function
/// - `grid-args`: Additional arguments to pass to the `grid` function
/// - `ai-icon-args`: Additional arguments to pass to all `ai-icon` function
#let ai-stack(
  box-args: (:),
  grid-args: (:),
  ai-icon-args: (:),
  ..icons,
) = (
  context {
    let icons = icons.pos().map(icon => {
      if type(icon) == str {
        ai-icon(icon, ..ai-icon-args)
      } else if type(icon) == array {
        let (name, args) = icon
        ai-icon(name, ..ai-icon-args, ..args)
      } else if type(icon) == arguments {
        ai-icon(..icon.pos(), ..ai-icon-args, ..icon.named())
      } else if type(icon) == content {
        icon
      } else {
        panic("Unsupported content. Please submit an issue for your use case.")
      }
    })

    // Get the maximum width of the icons
    let max-width = calc.max(
      ..icons.map(icon => {
        measure(icon).width
      }),
    )

    box(
      ..box-args,
      grid(
        align: center + horizon,
        columns: icons.len() * (max-width,),
        column-gutter: -max-width,
        rows: 1,
        ..grid-args,
        ..icons
      ),
    )
  }
)