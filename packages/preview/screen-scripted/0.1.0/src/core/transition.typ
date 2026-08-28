#let transition(tr) = {
  tr = upper(tr.text.trim())
  align(right)[
    #tr:
  ]
}

// TODO: Remove?
#let act-num = counter("actnum")
#let act(body) = {
  act-num.step()

  [
    ACT #context act-num.display("I") \
    #body
    END OF ACT #context act-num.display("I")
  ]
}
