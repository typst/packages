// citrus - CSL-to-Typst Compiler (Hybrid)
//
// Compiles CSL macros into native Typst functions using eval().
// Uses hybrid approach: control flow is compiled, complex elements call helpers.
//
// Architecture:
//   CSL XML → parse-csl() → dict → compile-style() → Typst code string → eval() → functions
//   Generated code calls helper functions passed via eval(scope: helpers)
//
// The compiled functions take a context dict and return
// (content, var-state, done-vars, ends-with-period).

#import "emit/codegen.typ": compile-ast, compile-children, compile-macro
#import "rt/mod.typ": compiler-helpers

/// Default helpers scope for eval()
/// These are the functions that compiled code can call
#let default-helpers = compiler-helpers

/// Compile all macros in a CSL style to Typst functions
///
/// - style: Parsed CSL style object
/// - helpers: Dictionary of helper functions to pass to eval() scope
/// Returns: Dictionary of macro-name -> compiled function
#let compile-macros(style, helpers: default-helpers) = {
  let macros = style.at("macros", default: (:))
  let compiled = (:)

  for (name, macro-def) in macros.pairs() {
    let children = macro-def.at("children", default: ())
    let code = compile-macro(name, children, macros)

    // Compile the function using eval with helpers in scope
    // The function signature is: (ctx) => (content, var-state, done-vars, ends-with-period)
    let func = eval(code, mode: "code", scope: helpers)
    compiled.insert(name, func)
  }

  compiled
}

/// Compile citation layout to a Typst function
///
/// - style: Parsed CSL style object
/// - helpers: Dictionary of helper functions to pass to eval() scope
/// Returns: Compiled function (ctx) => (content, var-state, done-vars, ends-with-period)
#let compile-citation-layout(style, helpers: default-helpers) = {
  let citation = style.at("citation", default: none)
  if citation == none { return ctx => ([], "none", (), false) }

  let layouts = citation.at("layouts", default: ())
  if layouts.len() == 0 { return ctx => ([], "none", (), false) }

  let layout = layouts.first()
  let children = layout.at("children", default: ())
  let macros = style.at("macros", default: (:))

  let code = compile-children(children, macros)
  let full-code = (
    "(ctx) => {\n"
      + "  let macro-cache = (:)\n"
      + "  let ctx = (..ctx, compiled-macro-cache: macro-cache)\n"
      + "  "
      + code
      + "\n}"
  )

  eval(full-code, mode: "code", scope: helpers)
}

/// Compile all bibliography layouts to a dictionary of Typst functions
///
/// - style: Parsed CSL style object
/// - helpers: Dictionary of helper functions to pass to eval() scope
/// Returns: Dictionary mapping locale -> compiled function
/// (ctx) => (content, var-state, done-vars, ends-with-period)
///          Key "_default" is used for layouts without locale attribute
#let compile-bibliography-layouts(style, helpers: default-helpers) = {
  let bib = style.at("bibliography", default: none)
  if bib == none { return (:) }

  let layouts = bib.at("layouts", default: ())
  if layouts.len() == 0 { return (:) }

  let macros = style.at("macros", default: (:))
  let result = (:)

  for layout in layouts {
    let locale = layout.at("locale", default: none)
    let key = if locale == none { "_default" } else { locale }
    let children = layout.at("children", default: ())

    let code = compile-children(children, macros)
    let full-code = (
      "(ctx) => {\n"
        + "  let macro-cache = (:)\n"
        + "  let ctx = (..ctx, compiled-macro-cache: macro-cache)\n"
        + "  "
        + code
        + "\n}"
    )

    result.insert(key, eval(full-code, mode: "code", scope: helpers))
  }

  result
}

/// Compile entire style (macros + layouts)
///
/// - style: Parsed CSL style object
/// - helpers: Dictionary of helper functions to pass to eval() scope
/// Returns: Dictionary with compiled functions
#let compile-style(style, helpers: default-helpers) = {
  (
    macros: compile-macros(style, helpers: helpers),
    citation: compile-citation-layout(style, helpers: helpers),
    bibliography-layouts: compile-bibliography-layouts(style, helpers: helpers),
  )
}
