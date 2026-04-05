// Source code for the typst-doc package


#import "styles.typ"
#import "tidy-parse.typ"



/// Parse the docstrings of a typst module. This function returns a dictionary with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module if not given explicity.
/// 
/// The function documentation dictionaries contain the keys
/// - `name`: The function name.
/// - `description`: The function's docstring description.
/// - `args`: A dictionary of info objects for each function argument.
///
/// These again are dictionaries with the keys
/// - `description` (optional): The description for the argument.
/// - `types` (optional): A list of accepted argument types. 
/// - `default` (optional): Default value for this argument.
/// 
/// See @@show-module() for outputting the results of this function.
///
/// - content (string): Content of `.typ` file to analyze for docstrings.
/// - name (string): The name for the module. 
/// - label-prefix (auto, string): The label-prefix for internal function references. If `auto`, the label-prefix name will be the module name. 
/// - require-all-parameters (boolean): Require that all parameters of a functions are documented and fail if some are not. 
/// - scope (dictionary): A dictionary of definitions that are then available in all function and parameter descriptions. 
#let parse-module(
  content, 
  name: "", 
  label-prefix: auto,
  require-all-parameters: false,
  scope: (:)
) = {
  if label-prefix == auto { label-prefix = name }
  
  if "example" not in scope { 
    scope.insert("example", tidy-parse.example) 
  }
  
  let parse-info = (
    label-prefix: label-prefix,
    require-all-parameters: require-all-parameters,
    scope: scope
  )
  
  let matches = content.matches(tidy-parse.docstring-matcher)
  let function-docs = ()

  for match in matches {
    function-docs.push(tidy-parse.parse-function-docstring(content, match, parse-info))
  }
  
  return (
    name: name,
    functions: function-docs, 
    label-prefix: label-prefix
  )
}


/// Show given module in the given style.
/// This displays all (documented) functions in the module.
///
/// - module-doc (dictionary): Module documentation information as returned by 
///           @@parse-module. 
/// - first-heading-level (integer): Level for the module heading. Function names are 
///           created as second-level headings and the "Parameters" heading is two levels 
///           below the first heading level. 
/// - show-module-name (boolean): Whether to output the name of the module at the top. 
/// - break-param-descriptions (boolean): Whether to allow breaking of parameter description blocks.
/// - omit-empty-param-descriptions (boolean): Whether to omit description blocks for
///           parameters with empty description. 
/// - show-outline (function): Whether to output an outline of all functions in the module at the beginning.
/// - sort-functions (auto, none, function): Function to use to sort the function documentations. 
///           With `auto`, they are sorted alphabetatically by name and with `none` they
///           are not sorted. Otherwise a function can be passed that each function documentation object is passed to and that should return some key to sort the functions by.
/// - style (module, dictionary): The output style to use. This can be a module defining the 
///           functions `show-outline`, `show-type`, `show-function`, `show-parameter-list` and 
///           `show-parameter-block` or a dictionary with functions for the same keys. 
/// -> content
#let show-module(
  module-doc, 
  style: styles.default,
  first-heading-level: 2,
  show-module-name: true,
  break-param-descriptions: false,
  omit-empty-param-descriptions: true,
  show-outline: true,
  sort-functions: auto
) = {
  let label-prefix = module-doc.label-prefix
  if "name" in module-doc and show-module-name and module-doc.name != "" {
    heading(module-doc.name, level: first-heading-level)
    parbreak()
  }
  
  if sort-functions == auto { 
    module-doc.functions = module-doc.functions.sorted(key: x => x.name) 
  } else if type(sort-functions) == "function" { 
    module-doc.functions = module-doc.functions.sorted(key: sort-functions) 
  }

  let style-args = (
    style: style,
    label-prefix: label-prefix, 
    first-heading-level: first-heading-level, 
    break-param-descriptions: break-param-descriptions, 
    omit-empty-param-descriptions: omit-empty-param-descriptions,
    scope: (:)
  )
  if show-outline {
    (style.show-outline)(module-doc)
  }
  
  for (index, fn) in module-doc.functions.enumerate() {
    (style.show-function)(fn, style-args)
    if index < module-doc.functions.len() - 1  { v(3em) }
  }
}


