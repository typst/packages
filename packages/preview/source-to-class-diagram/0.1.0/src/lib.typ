// =============================================================================
// source-to-class-diagram — Main Entry Point
// =============================================================================
// Public API for the source-to-class-diagram package.
// Provides both show-rule based (code fences) and function-based APIs.

#import "deps.typ": cetz
#import "ir.typ"
#import "parser/mod.typ" as parser
#import "grammars/mod.typ" as grammars
#import "renderer/mod.typ" as renderer

// =============================================================================
// Internal render function
// =============================================================================

/// Parse source code and render the class diagram.
///
/// - grammar (str): "java" or "csharp"
/// - fit (bool): scale down to fit page width (default: true)
/// - max-height (length or none): if set, also scale down so the diagram
///   never exceeds this height.  Combined with `fit`, the smaller of the
///   two scale factors is applied, keeping aspect ratio intact.
///   Both the visual size AND the allocated box height are constrained,
///   so the diagram never pushes content onto the next page.
#let _render-diagram(
  source,
  grammar:    "java",
  theme:      auto,
  spacing:    (x: 4.0, y: 3.5),
  fit:        true,
  max-height: none,
) = {
  let diagram-ir = parser.parse(source, grammar: grammar)
  let result     = renderer.render(diagram-ir, theme: theme, spacing: spacing)

  if fit or max-height != none {
    layout(bounds => context {
      let size = measure(result)

      // Factor needed to fit page width
      let fw = if fit and size.width > bounds.width {
        bounds.width / size.width
      } else {
        1.0
      }

      // Factor needed to fit max-height constraint
      let fh = if max-height != none and size.height > max-height {
        max-height / size.height
      } else {
        1.0
      }

      let factor = calc.min(fw, fh)

      if factor < 1.0 {
        // Scale the content AND tell Typst the box is the scaled size so it
        // doesn't over-allocate vertical space (which would cause a page break).
        box(
          width:  size.width  * factor,
          height: size.height * factor,
          scale(
            x:      factor * 100%,
            y:      factor * 100%,
            origin: top + left,
            result,
          ),
        )
      } else {
        result
      }
    })
  } else {
    result
  }
}

// =============================================================================
// Show-rule API (code fences)
// =============================================================================

/// Setup function that enables code-fence rendering.
///
/// Usage:
/// ```typst
/// #import "src/lib.typ": setup-classuml
/// #show: setup-classuml.with(max-height: 18cm)
/// ```
///
/// Then use code fences:
/// ````
/// ```class-diagram-java
/// class Foo { ... }
/// ```
/// ````
#let setup-classuml(
  theme:      auto,
  spacing:    (x: 4.0, y: 3.5),
  fit:        true,
  max-height: none,
  doc,
) = {
  show raw.where(lang: "class-diagram-java"): it => {
    _render-diagram(it.text, grammar: "java", theme: theme, spacing: spacing,
      fit: fit, max-height: max-height)
  }
  show raw.where(lang: "class-diagram-csharp"): it => {
    _render-diagram(it.text, grammar: "csharp", theme: theme, spacing: spacing,
      fit: fit, max-height: max-height)
  }
  doc
}

// =============================================================================
// Function API (programmatic)
// =============================================================================

/// Render a class diagram from source code.
///
/// - source (str): Source text in the specified grammar
/// - grammar (str or function): "java" or "csharp"
/// - theme (dict): Theme override (default: built-in theme)
/// - spacing (dict): (x, y) spacing between classes
/// - fit (bool): scale to page width (default: true)
/// - max-height (length or none): maximum allowed height; scales down if exceeded
#let class-diagram(
  source,
  grammar:    "java",
  theme:      auto,
  spacing:    (x: 4.0, y: 3.5),
  fit:        true,
  max-height: none,
) = {
  _render-diagram(source, grammar: grammar, theme: theme,
    spacing: spacing, fit: fit, max-height: max-height)
}

// =============================================================================
// Re-exports for advanced usage
// =============================================================================

// Allow users to create custom grammars
#let register-grammar = grammars.resolve-grammar

// Allow users to manipulate IR directly
#let create-class = ir.uml-class
#let create-member = ir.uml-member
#let create-relation = ir.uml-relation
#let create-diagram = ir.uml-diagram

// Allow users to render IR directly
#let render-ir = renderer.render
