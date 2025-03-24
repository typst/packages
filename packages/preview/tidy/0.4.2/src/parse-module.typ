#import "old-parser.typ"
#import "new-parser.typ"
#import "styles.typ"


#let resolve-parents(function-docs) = {
  for i in range(function-docs.len()) {
    let docs = function-docs.at(i)
    if not "parent" in docs { continue }
    
    let parent = docs.at("parent", default: none)
    if parent == none { continue }
    
    let parent-docs = function-docs.find(x => x.name == parent.name)
    if parent-docs == none { continue }

    // Inherit args and return types from parent
    docs.args = parent-docs.args
    docs.return-types = parent-docs.return-types
    
    for (arg, value) in parent.named {
      assert(arg in docs.args)
      docs.args.at(arg).default = value
    }
    
    // Maybe strip some positional arguments
    if parent.pos.len() > 0 {
      let named-args = docs.args.pairs().filter(((_, info)) => "default" in info)
      let positional-args = docs.args.pairs().filter(((_, info)) => not "default" in info)
      assert(parent.pos.len() <= positional-args.len(), message: "Too many positional arguments")
      positional-args = positional-args.slice(parent.pos.len())
      docs.args = (:)
      for (name, info) in positional-args + named-args {
        docs.args.insert(name, info)
      }
    }
    function-docs.at(i) = docs
  }
  return function-docs
}


#let old-parse(
  content, 
  label-prefix: "", 
  require-all-parameters: false,
  enable-curried-functions: true
) = {
  
  let parse-info = (
    label-prefix: label-prefix,
    require-all-parameters: require-all-parameters,
  )

  let module-docstring = old-parser.parse-module-docstring(content, parse-info)
  
  let matches = content.matches(old-parser.docstring-matcher)
  let function-docs = ()
  let variable-docs = ()

  for match in matches {
    
    if content.len() <= match.end or content.at(match.end) != "("  {
      let doc = old-parser.parse-variable-docstring(content, match, parse-info)
      if enable-curried-functions {
        let parent-info = old-parser.parse-curried-function(content, match.end)
        if parent-info == none {
          variable-docs.push(doc)
        } else {
          doc.parent = parent-info
          if "type" in doc { doc.remove("type") }
          doc.args = (:)
          function-docs.push(doc)
        }
      } else {
        variable-docs.push(doc)
      }
    } else {
      let function-doc = old-parser.parse-function-docstring(content, match, parse-info)
      function-docs.push(function-doc)
    }
  }
  return (
    description: module-docstring,
    functions: function-docs,
    variables: variable-docs
  )
}


/// Parse the doc-comments of a typst module. This function returns a dictionary 
/// with the keys
/// - `name`: The module name as a string.
/// - `functions`: A list of function documentations as dictionaries.
/// - `label-prefix`: The prefix for internal labels and references. 
/// The label prefix will automatically be the name of the module if not given 
/// explicity.
/// 
/// The function documentation dictionaries contain the keys
/// - `name`: The function name.
/// - `description`: The function's description.
/// - `args`: A dictionary of info objects for each function argument.
///
/// These again are dictionaries with the keys
/// - `description` (optional): The description for the argument.
/// - `types` (optional): A list of accepted argument types. 
/// - `default` (optional): Default value for this argument.
/// 
/// See @show-module for outputting the results of this function.
#let parse-module(
  
  /// Content of `.typ` file to analyze for docstrings. 
  /// -> str
  content, 

  /// The name for the module. 
  /// -> str
  name: "", 

  /// The label-prefix for internal function references. If `auto`, the 
  /// label-prefix name will be the module name. 
  /// -> auto | str
  label-prefix: auto,

  /// Require that all parameters of a functions are documented and fail
  /// if some are not. 
  /// -> bool
  require-all-parameters: false,
  
  /// A dictionary of definitions that are then available in all function
  /// and parameter descriptions. 
  /// -> dictionary
  scope: (:),

  /// Code to prepend to all code snippets shown with `#example()`. 
  /// This can for instance be used to import something from the scope. 
  /// -> str
  preamble: "",

  /// Whether to enable the detection of curried functions. 
  /// -> bool
  enable-curried-functions: true,

  /// Whether to use the old documentation syntax. 
  /// -> bool
  old-syntax: false
) = {
  if label-prefix == auto { label-prefix = name + "-" }
  
  let docs = (
    name: name,
    label-prefix: label-prefix,
    scope: scope,
    preamble: preamble
  )
  if old-syntax {
    docs += old-parse(content, require-all-parameters: require-all-parameters, label-prefix: label-prefix, enable-curried-functions: enable-curried-functions)
  } else {
    docs += new-parser.parse(content)
  }
  // TODO
  if enable-curried-functions {
    docs.functions = resolve-parents(docs.functions)
  }

  
  return docs
}
