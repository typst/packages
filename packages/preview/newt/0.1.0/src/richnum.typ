#import "strnum.typ": strnum, round, shift, first-sigfig
#import "strunit.typ": strunits
#import "util.typ": *



#let richnum(
  value,
) = {
  assert-type(value, str)

  let result = (r: none, pm: none, e: none, u: none, point: ",", explicit-sign: false, compact: false)

  (value, ..result.u) = value.split() + ("",)
  result.u = result.u.join(" ").trim()
  if result.u == "" { result.u = none }

  //+1+4-2e3
  let tok = 0
  let ch(tok) = value.at(tok)
  let eof(tok) = tok >= value.len()

  if "." in value { result.point = "." }
  if result.point == "," { value = value.replace(",", ".") }

  let dectok(c) = c in "1234567890."
  let inttok(c) = c in "1234567890"
  let sign(c) = if ch(c) == "+" { "+" } else if ch(c) == "-" { "-" } else { none }

  if ch(tok) == "+" { result.explicit-sign = true }
  let sign = sign(tok)
  if sign != none { tok += 1 }

  (result.r, tok) = strtok(value, tok, dectok)
  assert-number(result.r)
  if sign == "-" { 
    result.r = sign + result.r
  }

  if eof(tok) { return result }
  
  if ch(tok) == "+" { tok += 1
    if ch(tok) == "-" { tok += 1
      (result.pm, tok) = strtok(value, tok, dectok)
      assert-number(result.pm)
    } else {
      result.pm = (high: none, low: none)
      (result.pm.high, tok) = strtok(value, tok, dectok)
      assert(ch(tok) == "-", message: "Invalid number: " + value)
      tok += 1
      assert-number(result.pm.high)
      (result.pm.low, tok) = strtok(value, tok, dectok)
      assert-number(result.pm.low)
    }
  } else if ch(tok) == "(" { tok += 1
    result.compact = true
    (result.pm, tok) = strtok(value, tok, dectok)
    assert(result.pm.len() > 0, message: "Invalid number: " + value)
    assert(ch(tok) == ")", message: "Invalid number: " + value)
    tok += 1
    if "." in result.pm {
      assert("." in result.r, message: "Invalid number: " + value)
      assert-number(result.pm)
      let (_, pm-dec) = result.pm.split(".")
      let (_, r-dec) = result.r.split(".")
      assert.eq(pm-dec.len(), r-dec.len(), message: "Invalid number: " + value)
    } else if "." in result.r and result.pm.len() >= result.r.len() - result.r.position(".") {
      // Maybe throw for this case
        let n-dec = result.r.len() - result.r.position(".")
        result.pm = result.pm.slice(0, result.pm.len() - n-dec + 1) + "." + result.pm.slice(-n-dec + 1)
    } else {
      result.pm = result.r.slice(0, -result.pm.len()).replace(regex("\\d"), "0") + result.pm
    }
  }

  if eof(tok) { return result }


  assert(ch(tok) == "e", message: "Invalid number: " + value + "|" + repr(ch(tok)))
  tok += 1
  let sign = if ch(tok) == "-" { "-" } else { "+" }
  if ch(tok) == "-" or ch(tok) == "+" { tok += 1 }

  (result.e, tok) = strtok(value, tok, inttok)
  assert(result.e.len() < 3)
  result.e = int(sign + result.e)

  
  assert(eof(tok), message: "Invalid number: " + value)

  result



  /*
  (value, ..result.u) = value.split() + ("",)
  result.u = result.u.join(" ").trim()
  if result.u == "" { result.u = none }

  let has-pm = "+-" in value
  let has-e = "e" in value
  if has-pm and has-e {
    let pm-pos = value.position("+-")
    let e-pos = value.position("e")
    (result.r, result.pm, result.e) = value.split(regex("\+-|e"))

    // if pm after e, reverse
    if pm-pos > e-pos  {
       (result.pm, result.e) = (result.e, result.pm)
    }
  }
  else if has-pm {
   (result.r, result.pm) = value.split("+-")
  }
  else if has-e {
    (result.r, result.e) = value.split("e")
  }
  else {
    result.r = value
  }
  if result.e != none { result.e = int(result.e) }

  if value.at(0) == "+" { result.explicit-sign = true }

  result
  */
}
