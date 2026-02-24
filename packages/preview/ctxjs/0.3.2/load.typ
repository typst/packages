#import "helpers.typ"

#let eval-later = helpers.eval-later

#let eval(js) = {
  return ("method": "Eval", arguments: js)
}

#let eval-format(js, args, type-field: "$type") = {
  return ("method": "EvalFormat", arguments: (js, args, type-field))
}

#let define-vars(vars, type-field: "$type") = {
  return ("method": "DefineVars", arguments: (vars, type-field))
}

#let call-function(fnname, args, type-field: "$type") = {
  return ("method": "CallFunction", arguments: (fnname, args, type-field))
}

#let load-module-bytecode(bytecode) = {
  return ("method": "LoadModuleBytecode", arguments: bytecode)
}

#let load-module-js(modulename, module) = {
  return ("method": "LoadModuleJs", arguments: (modulename, module))
}

#let call-module-function(modulename, fnname, args, type-field: "$type") = {
  return ("method": "CallModuleFunction", arguments: (modulename, fnname, args, type-field))
}
