// Helper function. 
// if the value is auto "ret" is returned else the value self is returned
#let if-auto-then(val,ret) = {
  if (val == auto){
    ret
  } else { 
    val 
  }
}

// basic result type implementation
#let ok(value) = ("ok": value)
#let error(msg) = ("error": msg)
#let is-ok(result) = result.at("ok", default: none) != none
#let is-error(result) = result.at("error", default: none) != none
