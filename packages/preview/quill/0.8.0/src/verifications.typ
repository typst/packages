#let plural-s(n) = if n == 1 { "" } else { "s" }

#let verify-controlled-gate(gate, x, y, circuit-rows, circuit-cols) = {
  let multi = gate.multi
  if y + multi.target >= circuit-rows or y + multi.target < 0 {
    assert(false, message: 
      "A controlled gate starting at qubit " + str(y) + 
      " with relative target " + str(multi.target) + 
      " exceeds the circuit which has only " + str(circuit-rows) + 
      " qubit" + plural-s(circuit-rows)
    )
  }
}


#let verify-mqgate(gate, x, y, circuit-rows, circuit-cols) = {
  let nq = gate.multi.num-qubits
  if y + nq - 1 >= circuit-rows {
    assert(false, message: 
      "A " + str(nq) + "-qubit gate starting at qubit " + 
      str(y) + " exceeds the circuit which has only " + 
      str(circuit-rows) + " qubits"
    )
  }
}

#let verify-slice(slice, x, y, circuit-rows, circuit-cols) = {
  if slice.wires < 0 {
    assert(false, message: "`slice`: The number of wires needs to be > 0 (is " + str(slice.wires) + ")")
  }
  if y + slice.wires > circuit-rows {
    assert(false, message: 
      "A `slice` starting at qubit " + str(y) + 
      " spanning " + str(slice.wires) + 
      " qubit" + plural-s(slice.wires) + 
      " exceeds the circuit which has only " + 
      str(circuit-rows) + " qubit" + plural-s(circuit-rows)
    )
  }
}


#let verify-gategroup(gategroup, x, y, circuit-rows, circuit-cols) = {
  if gategroup.wires <= 0 {
    assert(false, message: "`gategroup`: The number of wires needs to be > 0 (is " + str(gategroup.wires) + ")")
  }
  if gategroup.steps <= 0 {
    assert(false, message: "`gategroup`: The number of steps needs to be > 0 (is " + str(gategroup.steps) + ")")
  }
  if y + gategroup.wires > circuit-rows {
    assert(false, message: 
      "A `gategroup` at qubit " + str(y) + 
      " spanning " + str(gategroup.wires) + 
      " qubit" + plural-s(gategroup.wires) + 
      " exceeds the circuit which has only " + 
      str(circuit-rows) + " qubit" + plural-s(circuit-rows)
    )
  }
  if x + gategroup.steps > circuit-cols {
    assert(false, message: 
      "A `gategroup` at column " + str(x) + 
      " spanning " + str(gategroup.steps) + 
      " column" + plural-s(gategroup.steps) + 
      " exceeds the circuit which has only " + 
      str(circuit-cols) + " column" + plural-s(circuit-cols)
    )
  }
}

#let verify-annotation-content(annotation-content) = {
  let content-type = type(annotation-content)
  assert(content-type in (symbol, content, str, dictionary), message: "`annotate`: Unsupported callback return type `" + str(content-type) + "` (can be `dictionary` or `content`")

  if content-type == dictionary {
    assert("content" in annotation-content, message: "`annotate`: Missing field `content` in annotation. If the callback returns a dictionary, it must contain the key `content` and may specify coordinates with `dx` and `dy`.")
    if "z" in annotation-content {
      let z = annotation-content.z
      assert(z in ("below", "above"), message: "`annotate`: The parameter `z` can take the values `\"above\"` and `\"below\"`")
    }
  }
}
