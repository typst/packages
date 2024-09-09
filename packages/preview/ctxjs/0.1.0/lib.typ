#let ctxjs = plugin("ctxjs.wasm")

#let string_to_bytes(data) = {
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

#let create_context(ctx_name) = {
  ctxjs.create_context(string_to_bytes(ctx_name))
}

#let eval(ctx_name, js) = {
  cbor.decode(ctxjs.eval(string_to_bytes(ctx_name), string_to_bytes(js)))
}

#let call_function(ctx_name, fn_name, args) = {
  cbor.decode(ctxjs.call_function(string_to_bytes(ctx_name), string_to_bytes(fn_name), cbor.encode(args)))
}

#let define_vars(ctx_name, vars) = {
  cbor.decode(ctxjs.define_vars(string_to_bytes(ctx_name), cbor.encode(vars)))
}

#let eval_format(ctx_name, js, args) = {
  cbor.decode(ctxjs.eval_format(string_to_bytes(ctx_name), string_to_bytes(js), cbor.encode(args)))
}

#let load_module_bytecode(ctx_name, bytecode) = {
  ctxjs.load_module_bytecode(string_to_bytes(ctx_name), bytecode)
}

#let load_module_js(ctx_name, module_name, module) = {
  ctxjs.load_module_js(string_to_bytes(ctx_name), string_to_bytes(module_name), string_to_bytes(module))
}

#let call_module_function(ctx_name, module_name, fn_name, args) = {
  cbor.decode(ctxjs.call_module_function(string_to_bytes(ctx_name), string_to_bytes(module_name), string_to_bytes(fn_name), cbor.encode(args)))
}

#let get_module_properties(ctx_name, module_name) = {
  cbor.decode(ctxjs.get_module_properties(string_to_bytes(ctx_name), string_to_bytes(module_name)))
}