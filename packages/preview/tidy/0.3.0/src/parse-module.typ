#import "tidy-parse.typ"
#import "styles.typ"

/// Parse the docstrings of a typst module. This function returns a dictionary 
/// with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module if not given 
/// explicity.
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
/// - label-prefix (auto, string): The label-prefix for internal function 
///       references. If `auto`, the label-prefix name will be the module name. 
/// - require-all-parameters (boolean): Require that all parameters of a 
///       functions are documented and fail if some are not. 
/// - scope (dictionary): A dictionary of definitions that are then available 
///       in all function and parameter descriptions. 
/// - preamble (string): Code to prepend to all code snippets shown with `#example()`. 
///       This can for instance be used to import something from the scope. 
#let parse-module(
  content, 
  name: "", 
  label-prefix: auto,
  require-all-parameters: false,
  scope: (:),
  preamble: ""
) = {
  if label-prefix == auto { label-prefix = name }
  
  let parse-info = (
    label-prefix: label-prefix,
    require-all-parameters: require-all-parameters,
  )
  
  let matches = content.matches(tidy-parse.docstring-matcher)
  let function-docs = ()
  let variable-docs = ()

  for match in matches {
    if content.len() <= match.end or content.at(match.end) != "(" {
      variable-docs.push(tidy-parse.parse-variable-docstring(content, match, parse-info))
    } else {
      function-docs.push(tidy-parse.parse-function-docstring(content, match, parse-info))
    }
  }
  
  return (
    name: name,
    functions: function-docs, 
    variables: variable-docs, 
    label-prefix: label-prefix,
    scope: scope,
    preamble: preamble
  )
}
