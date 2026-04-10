#import "helpers.typ"

#let eval-later = helpers.eval-later

#let load(ctxjs, load) = {
  return plugin.transition(ctxjs.load, cbor.encode(load))
}

#let eval(ctxjs, js) = {
  return cbor(ctxjs.eval(helpers.string-to-bytes(js)))
}

#let eval-format(ctxjs, js, args, type-field: "$type") = {
  return cbor(ctxjs.eval_format(helpers.string-to-bytes(js), cbor.encode(args), helpers.string-to-bytes(type-field)))
}

#let call-function(ctxjs, fnname, args, type-field: "$type") = {
  return cbor(ctxjs.call_function(helpers.string-to-bytes(fnname), cbor.encode(args), helpers.string-to-bytes(type-field)))
}

#let define-vars(ctxjs, vars, type-field: "$type") = {
  cbor(ctxjs.define_vars(cbor.encode(vars), helpers.string-to-bytes(type-field)))
}

#let load-module-bytecode(ctxjs, bytecode) = {
  return plugin.transition(ctxjs.load_module_bytecode, bytecode)
}

#let load-module-js(ctxjs, modulename, module) = {
  return plugin.transition(ctxjs.load_module_js, helpers.string-to-bytes(modulename), helpers.string-to-bytes(module))
}

#let call-module-function(ctxjs, modulename, fnname, args, type-field: "$type") = {
  return cbor(ctxjs.call_module_function(helpers.string-to-bytes(modulename), helpers.string-to-bytes(fnname), cbor.encode(args), helpers.string-to-bytes(type-field)))
}

#let get-module-properties(ctxjs, modulename) = {
  return cbor(ctxjs.get_module_properties(helpers.string-to-bytes(modulename)))
}