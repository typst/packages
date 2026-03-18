#let ctxjs = plugin("ctxjs.wasm")

#let string-to-bytes(data) = {
  let data = data
  if type(data) == str {
    data = bytes(data)
  } else if type(data) == array {
    data = bytes(data)
  } else if type(data) == content {
    data = bytes(data.text)
  }
  data
}

#let create-context(ctxname) = {
  ctxjs.create_context(string-to-bytes(ctxname))
}

#let eval(ctxname, js) = {
  cbor.decode(ctxjs.eval(string-to-bytes(ctxname), string-to-bytes(js)))
}

#let call-function(ctxname, fnname, args) = {
  cbor.decode(ctxjs.call_function(string-to-bytes(ctxname), string-to-bytes(fnname), cbor.encode(args)))
}

#let define-vars(ctxname, vars) = {
  cbor.decode(ctxjs.define_vars(string-to-bytes(ctxname), cbor.encode(vars)))
}

#let eval-format(ctxname, js, args) = {
  cbor.decode(ctxjs.eval_format(string-to-bytes(ctxname), string-to-bytes(js), cbor.encode(args)))
}

#let load-module-bytecode(ctxname, bytecode) = {
  ctxjs.load_module_bytecode(string-to-bytes(ctxname), bytecode)
}

#let load-module-js(ctxname, modulename, module) = {
  ctxjs.load_module_js(string-to-bytes(ctxname), string-to-bytes(modulename), string-to-bytes(module))
}

#let call-module-function(ctxname, modulename, fnname, args) = {
  cbor.decode(ctxjs.call_module_function(string-to-bytes(ctxname), string-to-bytes(modulename), string-to-bytes(fnname), cbor.encode(args)))
}

#let get-module-properties(ctxname, modulename) = {
  cbor.decode(ctxjs.get_module_properties(string-to-bytes(ctxname), string-to-bytes(modulename)))
}