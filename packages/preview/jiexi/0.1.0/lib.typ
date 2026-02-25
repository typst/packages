#let _jiexi-wasm = plugin.transition(plugin("jiexi.wasm").hs_init_wrapped)

#let _table-parse(parse-metadata, tag-stream, value-stream, scope: (:)) = {
  assert.eq(tag-stream.len(), value-stream.len(), message: "Tag stream and value stream has unequal length")
  let (
    shift-reduce-table,
    goto-table,
    prod-arity-table,
    prod-token-table,
    prod-worker-code-table,
    token-by-tag-table,
    eof-token,
  ) = parse-metadata
  let prod-worker-table = for (arity, code) in array.zip(prod-arity-table, prod-worker-code-table) {
    let lambda-header = for i in range(0, arity) {
      "t" + str(arity - i)
      if (i != arity - 1) { ", " }
    }
    let lambda-code = "{(" + lambda-header + ") => {" + code + "}}"
    (eval(mode: "code", scope: scope, lambda-code),)
  }
  let state-stack = (0,)
  let value-stack = ()
  let worker-args = ()
  let ptr = 0
  let bound = tag-stream.len()
  while true {
    let curr-token = if (ptr >= bound) { eof-token } else {
      let curr-tag = tag-stream.at(ptr)
      token-by-tag-table.at(curr-tag)
    }
    let curr-state = state-stack.last()
    let action = shift-reduce-table.at(curr-state).at(curr-token)
    if (action == 0) {
      panic("Parser errored after consuming " + str(ptr) + " tokens! ")
    } else if (action > 0) {
      // shift
      state-stack.push(action - 1)
      value-stack.push(value-stream.at(ptr, default: none))
      ptr += 1
    } else {
      let prod = -action - 1
      if (prod == 0) {
        // accept
        break
      }
      // reduce
      let new-token = prod-token-table.at(prod)
      let arity = prod-arity-table.at(prod)
      worker-args = ()
      while (arity > 0) {
        worker-args.push(value-stack.pop())
        let _ = state-stack.pop()
        arity -= 1
      }
      let exposed-state = state-stack.last()
      state-stack.push(goto-table.at(exposed-state).at(new-token))
      value-stack.push((prod-worker-table.at(prod))(..worker-args))
    }
  }
  return value-stack.first()
}

#let make-parser(grammar) = {
  let metadata = cbor(_jiexi-wasm.grammar_to_metadata(cbor.encode(grammar)))
  return _table-parse.with(metadata)
}