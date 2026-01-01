#import "styles.typ"
#import "utilities.typ"
#import "testing.typ"
#import "parse-module.typ": parse-module
#import "show-module.typ": show-module

#let help-box(content) = {
  block(
    above: 1em,
    inset: 1em,
    stroke: rgb("#AAA"),
    fill: rgb("#F5F5F544"), {
      text(size: 1.8em, [? #smallcaps("help")#h(1fr)?])
      text(.9em, content)
    }
  )
}

#let parse-namespace-modules(entry, old-syntax: false) = {
  // "Module" is made up of several files
  if type(entry) != array {
    entry = (entry,)
  }
  parse-module(entry.map(x => x()).join("\n"), old-syntax: old-syntax, label-prefix: "help-")
}

#let search-docs(search, searching, namespace, style, old-syntax: false) = {
  if search == "" { return help-box(block[_empty search string_]) }
  let search-names = "n" in searching
  let search-descriptions = "d" in searching
  let search-parameters = "p" in searching

  let search-argument-dict(args) = {
    if search in args { return true }
    for (key, value) in args { 
      if "description" in value and search in value.description { return true } 
    }
    return false
  }

  let filter = definition => {
    (search-names and search in definition.name) or         (search-descriptions and "description" in definition and search in definition.description) or (search-parameters and "args" in definition and search-argument-dict(definition.args)) 
  }
  
  let definitions = ()
  let module = parse-namespace-modules(namespace.at("."), old-syntax: old-syntax)
  let functions = ()
  let variables = ()
  for (name, modules) in namespace {
    let module = parse-namespace-modules(modules, old-syntax: old-syntax)
   
    functions += module.functions.filter(filter)
    variables += module.variables.filter(x => search in x.name or search in x.description)
  }
  module.functions = functions
  module.variables = variables
  return help-box({ 
    show search: highlight.with(fill: rgb("#FF28")) 
    show-module(module, style: style, enable-cross-references: false)
  })
}



#let get-docs(
  definition-name, namespace, package-name, style,
  onerror: msg => assert(false, message: msg)
) = {
  let name = definition-name
  let result
  if type(name) == function { name = repr(name) }
  assert.eq(type(name), str, message: "The definition name has to be a string, found `" + repr(name) + "`")

  let name-components = name.split(".")
  name = name-components.pop()
  let module-name = name-components.join(".")

  if module-name == none { module-name = "." }

  if module-name not in namespace {
    return onerror("The package `" + package-name + "` contains no module `" + module-name + "`")
  }
  
  
  let module = parse-namespace-modules(namespace.at(module-name))

  // We support selecting a specific parameter name (for functions)
  let param-name
  if "(" in name {
    let match = name.match(regex("(\w[\w\d\-_]*)\((.*)\)"))
    if match != none {
      (name, param-name) = match.captures
      if param-name == "" { param-name = none }
      definition-name = definition-name.slice(0, definition-name.position("("))
    }
  }

  // First check if there is a function with the given name
  let definition-doc = module.functions.find(x => x.name == name)
  if definition-doc != none {
    if param-name != none { // extract only the parameter description
      let style-functions = utilities.get-style-functions(style)
          
      let style-args = (
        style: style-functions,
        label-prefix: "", 
        first-heading-level: 2, 
        break-param-descriptions: true, 
        omit-empty-param-descriptions: false,
        colors: styles.default.colors,
        enable-cross-references: false
      )
          
      let eval-scope = (
        // Predefined functions that may be called by the user in doc-comment code
        example: style-functions.show-example.with(
          inherited-scope: module.scope
        ),
        test: testing.test.with(
          inherited-scope: testing.assertations + module.scope, 
          enable: false
        ),
        // Internally generated functions 
        tidy: (
          show-reference: style-functions.show-reference.with(style-args: style-args)
        )
      )
    
      eval-scope += module.scope
    
      style-args.scope = eval-scope
      
    
      // Show the docs
      if param-name not in definition-doc.args {
        if ".." + param-name in definition-doc.args {
          param-name = ".." + param-name 
        } else {
          return onerror("The function `" + definition-name + "` has no parameter `" + param-name + "`")
        }
      }
      let info = definition-doc.args.at(param-name)
      let types = info.at("types", default: ())
      let description = info.at("description", default: "")
      result = block(strong(name), above: 1.8em)
      result += (style.show-parameter-block)(
        param-name, types, utilities.eval-docstring(description, style-args), 
        style-args,
        show-default: "default" in info, 
        default: info.at("default", default: none),
      )
    }
    module.functions = (definition-doc,)
    module.variables = ()
  } else {
    let definition-doc = module.variables.find(x => x.name == name)
    if definition-doc != none {
      assert(param-name == none, message: "Parameters can only be specified for function definitions, not for variables. ")
      module.variables = (definition-doc,)
      module.functions = ()
    } else {
      
      if module-name == "." {
        return onerror("The package `" + package-name + "` contains no (documented) definition `" + name + "`")
      } else {
        return onerror("The module `" + module-name + "` from the package `" + package-name + "` contains no (documented) definition `" + name + "`")
      }
    }
  }
    
  if result == none {
    result = show-module(
      module, 
      style: style,
      enable-cross-references: false,
      enable-tests: false,
      show-outline: false,
    )
  }
  return result
}


/// Generates a `help` function for your package that allows the user to
/// prints references directly into their document while typing. This allows
/// them to easily check the usage and documentation of a function or variable. 
#let generate-help(
  
  /// This dictionary should reflect the "namespace" of the package
  /// in a flat dictionary and contain `read.with()` instances for the respective code 
  /// files. 
  /// Imagine importing everything from a package, `#import "mypack.typ": *`. How a 
  /// symbol is accessible now determines how the dictionary should be built. 
  /// We start with a root key, `(".": read.with("lib.typ"))`. If `lib.typ` imports 
  /// symbols from other files _into_ its scope, these files should be added to the
  /// root along with `lib.typ` by passing an array: 
  /// ```typ
  /// (
  ///   ".": (read.with("lib.typ"), read.with("more.typ")),
  ///   "testing": read.with("testing.typ")
  /// )
  /// ```
  /// Here, we already show another case: let `testing.typ` be imported in `lib.typ`
  /// but without `*`, so that the symbols are accessed via `testing.`. We therefore 
  /// add these under a new key. Nested files should be added with multiple 
  /// dots, e.g., `"testing.float."`. 
  /// 
  /// By providing instances of `read()` with the filename prepended, you allow tidy 
  /// to read the files that are not part of the tidy package but at the same time
  /// enable lazy evaluation of the files, i.e., a file is only opened when a 
  /// definition from this file is requested through `help()`. 
  /// -> dictionary
  namespace: (".": () => ""), 

  /// The name of the package. This is required to give helpful error messages when
  ///  a symbol cannot be found. 
  /// -> str
  package-name: "",

  /// A tidy style that is used for showing parts of the documentation
  /// in the help box. It is recommended to leave this at the `help` style which is 
  /// particularly designed for this purpose. Please post an issue if you have problems
  /// or suggestions regarding this style. 
  /// -> dictionary
  style: styles.help,

  /// What to do with errors. By default, an assertion is failed (the document panics). 
  /// -> function
  onerror: msg => assert(false, message: msg),

  /// Whether to use the old parser. 
  /// -> bool
  old-syntax: false
) = {

  let validate-namespace-tree(namespace) = {
    let validate-file-reader(file-reader) = {
      assert(type(file-reader) == function, message: "The namespace must have instances of `read.with([filename])` as leaves, found " + repr(file-reader))
    }
    for (entry, value) in namespace {
      if type(value) == array {
        for file-reader in value {
          validate-file-reader(file-reader)
        } 
      } else if type(value) == dictionary {
        validate-namespace-tree(value)
      } else {
        validate-file-reader(value)
      }
    }
  }
  

  validate-namespace-tree(namespace)


  let help-function = (
    ..args, 
    search: none, 
    searching: "ndp", // Enable search of: name, descriptions, parameters 
    style: style
  ) => {
    if search == none {
      if args.pos().len() == 0 { return none }
      let name = args.pos().first()
      help-box(get-docs(name, namespace, package-name, style, onerror: onerror))
    } else {
      search-docs(search, searching, namespace, style, old-syntax: old-syntax)
    }
  }
  help-function
}




#let flatten-namespace(namespace) = {
  let sub-namespace-name = ""

  let flatten-impl(dict, name) = {
    let name-without-dot = name.trim(".")
    let flattened-dict = ((name-without-dot): ())
    for (key, value) in dict {
      if type(value) == function { value = (value,) }
      if key == "." { 
        flattened-dict.at(name-without-dot) += value
      } else if type(value) == array { 
        flattened-dict.insert(name + key, value)
      } else if type(value) == dictionary {
        let u = flatten-impl(value, name + key + ".")
        flattened-dict += u
      }
    }
    return flattened-dict
  }
  let flattened-namespace = flatten-impl(namespace, "")
  
}

#flatten-namespace((
  ".": read,
  "math": read,
  "matrix": (
    ".": (read, read),
    "vector": (
      "algebra": read,
      "addition": (
        "binary": read
      )
    )
  ),
  
))