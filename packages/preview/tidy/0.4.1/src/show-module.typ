#import "styles.typ"
#import "utilities.typ"
#import "testing.typ"


#let def-state = state("tidy-definitions", (:))


/// Show given module in the given style.
/// This displays all (documented) functions in the module.
///
/// -> content
#let show-module(
  
  /// Module documentation information as returned by @parse-module. 
  /// -> dictionary
  module-doc, 

  /// The output style to use. This can be a module 
  /// defining the functions `show-outline`, `show-type`, `show-function`, 
  /// `show-parameter-list` and `show-parameter-block` or a dictionary with
  /// functions for the same keys.
  ///  -> module | dictionary
  style: styles.default,

  /// Level for the module heading. Function names are created as second-level
  /// headings and the "Parameters" heading is two levels below the first 
  /// heading level.  
  /// -> int
  first-heading-level: 2,

  /// Whether to output the name of the module at the top. 
  /// -> bool
  show-module-name: true,

  /// Whether to allow breaking of parameter description blocks. 
  /// -> bool
  break-param-descriptions: false,

  /// Whether to omit description blocks for parameters with empty description. 
  /// -> bool
  omit-empty-param-descriptions: true,

  /// Whether to omit functions and variables starting with an underscore. 
  /// -> bool
  omit-private-definitions: false,

  /// Whether to omit named function arguments starting with an underscore. 
  /// -> bool
  omit-private-parameters: false,

  /// Whether to output an outline of all functions in the module at the beginning. 
  /// -> bool
  show-outline: true,

  /// Function to use to sort the function documentations. With `auto`, they are 
  /// sorted alphabetically by name and with `none` they are not sorted. Otherwise 
  /// a function can be passed that each function documentation object is passed to 
  /// and that should return some key to sort the functions by. 
  /// -> auto | none | function
  sort-functions: auto,

  /// Whether to run doc-comment tests. 
  /// -> bool
  enable-tests: true,

  /// Whether to enable links for cross-references. If set to auto, the style 
  /// will select its default color set. 
  /// -> bool
  enable-cross-references: true,

  /// Give a dictionary for type and colors and other colors. 
  /// -> auto | dictionary
  colors: auto,

  /// Language-specific names for strings used in the output. Currently, these 
  /// are `parameters` and `default`. You can for example use: 
  /// `local-names: (parameters: [Paramètres], default: [défault])`.
  /// -> dictionary
  local-names: (parameters: [Parameters], default: [Default])
) = block({
  let label-prefix = module-doc.label-prefix
  if sort-functions == auto { 
    module-doc.functions = module-doc.functions.sorted(key: x => x.name) 
  } else if type(sort-functions) == function { 
    module-doc.functions = module-doc.functions.sorted(key: sort-functions) 
  }

  if omit-private-definitions {
    let filter = x => not x.name.starts-with("_")
    module-doc.functions = module-doc.functions.filter(filter)
    module-doc.variables = module-doc.variables.filter(filter)
  }

  
  let style-functions = utilities.get-style-functions(style)
  
  let style-args = (
    style: style-functions,
    label-prefix: label-prefix, 
    first-heading-level: first-heading-level, 
    break-param-descriptions: break-param-descriptions, 
    omit-empty-param-descriptions: omit-empty-param-descriptions,
    omit-private-parameters: omit-private-parameters,
    colors: colors,
    enable-cross-references: enable-cross-references,
    local-names: local-names,
  )
  
  
  let eval-scope = (
    // Predefined functions that may be called by the user in doc-comment code
    example: style-functions.show-example.with(
      inherited-scope: module-doc.scope,
      preamble: module-doc.preamble
    ),
    test: testing.test.with(
      inherited-scope: testing.assertations + module-doc.scope, 
      enable: enable-tests
    ),
    // Internally generated functions 
    tidy: (
      show-reference: style-functions.show-reference.with(style-args: style-args)
    )
  )

  eval-scope += module-doc.scope

  style-args.scope = eval-scope
  
  def-state.update(x => {
    x + module-doc.functions.map(x => (x.name, 1)).to-dict() + module-doc.variables.map(x => (x.name, 0)).to-dict()
  })

  show ref: it => {
    let target = str(it.target)
    if target.starts-with(label-prefix){ return it }
    if not enable-cross-references {
      return raw(target)
    }
    let defs = def-state.final()

    let base = target
    if "." in base { base = base.split(".").first() }
    let target-def = defs.at(target, default: none)
    let base-def = defs.at(base, default: none)
    if target-def == none and base-def == none { return it } 

    if target-def == 1 {
      target += "()"
    }
    (eval-scope.tidy.show-reference)(label(label-prefix + target), target)
  }

  show raw.where(lang: "example"): it => {
    set text(4em / 3)

    (eval-scope.example)(
      raw(it.text, block: true, lang: "typ"), 
      mode: "markup"
    )
  }
  show raw.where(lang: "examplec"): it => {
    set text(4em / 3)

    (eval-scope.example)(
      raw(it.text, block: true, lang: "typc"),
      mode: "code"
    )
  }

  // Show the docs
  
  if "name" in module-doc and show-module-name and module-doc.name != "" {
    heading(module-doc.name, level: first-heading-level)
    parbreak()
  }
  
  if show-outline {
    (style-functions.show-outline)(module-doc, style-args: style-args)
  }
  
  for (index, fn) in module-doc.functions.enumerate() {
    (style-functions.show-function)(fn, style-args)
  }
  for (index, fn) in module-doc.variables.enumerate() {
    (style-functions.show-variable)(fn, style-args)
  }
})


