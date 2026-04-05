#import "styles.typ"
#import "utilities.typ"
#import "testing.typ"



/// Show given module in the given style.
/// This displays all (documented) functions in the module.
///
/// - module-doc (dictionary): Module documentation information as returned by 
///           @@parse-module(). 
/// - first-heading-level (integer): Level for the module heading. Function 
///           names are created as second-level headings and the "Parameters" 
///           heading is two levels below the first heading level. 
/// - show-module-name (boolean): Whether to output the name of the module at 
///           the top. 
/// - break-param-descriptions (boolean): Whether to allow breaking of parameter 
///           description blocks.
/// - omit-empty-param-descriptions (boolean): Whether to omit description blocks
///           for parameters with empty description. 
/// - omit-private-definitions (boolean): Whether to omit functions and variables
///           starting with an underscore. 
/// - omit-private-parameters (boolean): Whether to omit named function arguments 
///           starting with an underscore. 
/// - show-outline (function): Whether to output an outline of all functions in 
///           the module at the beginning.
/// - sort-functions (auto, none, function): Function to use to sort the function  
///           documentations. With `auto`, they are sorted alphabetically by 
///           name and with `none` they are not sorted. Otherwise a function can 
///           be passed that each function documentation object is passed to and 
///           that should return some key to sort the functions by.
/// - style (module, dictionary): The output style to use. This can be a module 
///           defining the functions `show-outline`, `show-type`, `show-function`, 
///           `show-parameter-list` and `show-parameter-block` or a dictionary with
///           functions for the same keys. 
/// - enable-tests (boolean): Whether to run docstring tests. 
/// - enable-cross-references (boolean): Whether to enable links for cross-references. 
/// - colors (auto, dictionary): Give a dictionary for type and colors and other colors. 
///          If set to auto, the style will select its default color set. 
/// - local-names (dictionary): Language-specific names for strings used in the output. Currently, these are `parameters` and `default`. You can for example use: `local-names: (parameters: [Paramètres], default: [défault])`
/// -> content
#let show-module(
  module-doc, 
  style: styles.default,
  first-heading-level: 2,
  show-module-name: true,
  break-param-descriptions: false,
  omit-empty-param-descriptions: true,
  omit-private-definitions: false,
  omit-private-parameters: false,
  show-outline: true,
  sort-functions: auto,
  enable-tests: true,
  enable-cross-references: true,
  colors: auto,
  local-names: (parameters: [Parameters], default: [Default])
) = block({
  let label-prefix = module-doc.label-prefix
  if sort-functions == auto { 
    module-doc.functions = module-doc.functions.sorted(key: x => x.name) 
  } else if type(sort-functions) == "function" { 
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
    // Predefined functions that may be called by the user in docstring code
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


