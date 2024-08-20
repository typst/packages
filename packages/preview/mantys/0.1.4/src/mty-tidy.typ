
#import "./mty.typ": frame, match-value, match-func
#import "./api.typ": dtype, cmd, cmd-, arg, sarg, barg, command, argument, variable, example, cmdref
#import "./theme.typ"

#import "@preview/tidy:0.2.0" as tidy-preview


/// Color to highlight function names in
#let fn-color = theme.colors.command


// Colors for Typst types
#let type-colors = theme.colors.dtypes


#let _eval-value(v) = {
  if match-value(v) {
    eval(v)
  } else if match-func(v) {
    "(...) => ..."
  } else if v.starts-with("\"") {
    v.slice(1, -1)
  } else {
    v
  }
}


/// Returns the color for a specific type.
///
/// - type (any): Type to get the color for.
/// -> color
#let get-type-color(type) = type-colors.at(type, default: theme.colors.dtypes.at("any"))


/// Shows the outline of a module (list pf functions).
///
/// - module-doc (dictionary): Parsed module data.
/// - style-args (dictionary): Styling arguments.
/// -> content
#let show-outline(module-doc, style-args: none) = {
  let prefix = module-doc.label-prefix
  let items = ()
  for fn in module-doc.functions.sorted(key: (fn) => fn.name) {
    items.push(link(label(prefix + fn.name + "()"), cmd-(fn.name)))
  }

  if items != () {
    let cols_num = 3
    let per_col = calc.ceil(items.len() / cols_num)
    let cols = ()
    for i in range(items.len(), step:per_col) {
      cols.push(
        items
          .slice(
            i,
            calc.min(i + per_col, items.len())
          )
          .join(linebreak())
      )
    }
    frame(
      frame: (
        border-color: theme.colors.secondary,
        thickness: .75pt,
        radius: 4pt
      ),
      {
        set text(.88em)
        grid(
          columns: (1fr,) * cols_num,
          ..cols
        )
      }
    )
  }
}


/// Create beautiful, colored type box
#let show-type(type, style-args: (:)) = dtype(type)


/// Show a list of arguments for a given function.
///
/// - fn (dictionary): Parsed function dictionary.
/// - display-type-function (function):
/// -> content
#let show-parameter-list(fn, display-type-function) = {
  cmd(
    fn.name,
    ..fn.args.pairs().map(((a, info)) => {
      if a.starts-with("..") {
        sarg(a.slice(2))
      } else {
        if "default" in info {
          arg(a, info.default)
        } else {
          arg(a)
        }
      }
    }),
    ret:fn.return-types
  )
}


/// Create a parameter description block, containing name, type, description
/// and optionally the default value.
/// Passes the parameter information to #tidyref(none, "argument").
///
/// - name (string): Name of the function.
/// - types (array): Array of possible types.
/// - content (content): Description of the argument.
/// - style-args (dictionary): #package[Tidy] configuration.
/// -> content
#let show-parameter-block(
  name, types, content, style-args,
  show-default: false,
  default: none,
) = {
  argument(
    if name.starts-with("..") { name.slice(2) } else { name },
    is-sink: name.starts-with(".."),
    types: types,
    default: if show-default { _eval-value(default) } else { "__none__" },
    content
  )
}


/// Show function
#let show-function(
  fn, style-args,
  tidy: none, extract-headings: 2   // Additional arguments
) = [
  #let _tidy = tidy
  #if _tidy == none {
    _tidy = tidy-preview
  }

  #let descr = _tidy.utilities.eval-docstring(fn.description, style-args)
  #let headings = ()
  #if extract-headings != none and descr.has("children") {
    // Extract headings
    headings = descr.children.filter((e) => e.func() == heading and e.depth <= extract-headings)
    // Filter out extracted headings
    descr = descr.children.filter((e) => e.func() != heading or e.depth > extract-headings).join()
  }

  #headings.join()
  #command(
    fn.name,
    ..fn.args.pairs().map(((a, info)) => {
      if a.starts-with("..") {
        sarg(a.slice(2))
      } else if "types" in info and info.types == ("content",) and "default" not in info {
        barg(a)
      } else {
        if "default" in info {
          arg(a, _eval-value(info.default))
        } else {
          arg(a)
        }
      }
    }),
    ret:fn.return-types,
    [
      // #_tidy.utilities.eval-docstring(fn.description, style-args)
      #descr

      #for (name, info) in fn.args {
        let description = info.at("description", default: "")
        if description in ("", []) and style-args.omit-empty-param-descriptions { continue }
        (style-args.style.show-parameter-block)(
          name,
          info.at("types", default: ()),
          _tidy.utilities.eval-docstring(description, style-args),
          style-args,
          show-default: "default" in info,
          default: info.at("default", default: none)
        )
      }
    ]
  )
  #label(style-args.label-prefix + fn.name + "()")
]


#let show-variable(
  var, style-args, tidy: none
) = {
  let _tidy = tidy
  if _tidy == none {
    _tidy = tidy-preview
  }

  [
    #variable(
      var.name,
      types: var.at("type", default:none),
      // value: _eval-value(var.value),
      value: none,
      _tidy.utilities.eval-docstring(var.description, style-args)
    )
    #label(style-args.label-prefix + var.name)
  ]
}


#let show-reference(target, name, style-args: (:)) = {
  target = str(target)
  if not target.ends-with("()") {
    target = target + "()"
  }
  if name.ends-with("()") {
    name = name.slice(0, -2)
  }
  link(label(target), cmd-(name))
}

#let show-example(
  code,
  dir: ltr,
  scope: (:),
  ratio: 1,
  scale-output: 80%,
  inherited-scope: (:),
  ..options
) = example(
  scope: inherited-scope + scope,
  ..options,
  code
)
