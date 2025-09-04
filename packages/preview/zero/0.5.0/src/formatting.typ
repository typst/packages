#import "state.typ": num-state
#import "parsing.typ": *


#let sequence-constructor = $$.body.func()

/// Creates an equation from a sequence. This function leaves the
/// `block` attribute unset. 
#let make-equation(sequence) = {
  math.equation(sequence-constructor(sequence))
}

#assert.eq(make-equation((sym.minus, [2])).body, $-2$.body)



/// Formats a sign. If the sign is the ASCII character "-", the minus
/// unicode symbol "−" is returned. Otherwise, "+" is returned but only 
/// if `positive-sign` is set to true. In all other cases, the result is
/// `none`. 
#let format-sign(sign, positive-sign: false) = {
  if sign == "-" { return "−" }
  else if sign == "+" and positive-sign { return "+" }
}

#assert.eq(format-sign("-", positive-sign: false), "−")
#assert.eq(format-sign("+", positive-sign: false), none)
#assert.eq(format-sign("-", positive-sign: true), "−")
#assert.eq(format-sign("+", positive-sign: true), "+")
#assert.eq(format-sign(none, positive-sign: true), none)



/// Inserts group separators (e.g., thousand separators if `group-size` is 3)
/// into a sequence of digits. 
/// - x (str): Input sequence. 
/// - invert (bool): If `false`, the separators are inserted counting from
///   right-to-left (as customary for integers), if `true`, they are inserted
///   from left-to-right (for fractionals). 
#let insert-group-separators(
  x, 
  invert: false,
  threshold: 5,
  size: 3,
  separator: sym.space.thin
) = {
  if type(threshold) == dictionary {
    assert(
      threshold.keys().sorted() == ("fractional", "integer"),
      message: "group.threshold expects either an int or a dictionary with the keys \"fractional\" and \"integer\""
    )
    if invert {
      threshold = threshold.fractional
    } else {
      threshold = threshold.integer
    }
  }
  if x.len() < threshold { return x }
  
  if not invert { x = x.rev() }
  let chunks = x.codepoints().chunks(size)
  if not invert { chunks = chunks.rev().map(array.rev) }
  return chunks.intersperse(separator).flatten().join()
}

#assert.eq(insert-group-separators("123"), "123")
#assert.eq(insert-group-separators("1234"), "1234")
#assert.eq(insert-group-separators("12345", separator: " "), "12 345")
#assert.eq(insert-group-separators("123456", separator: " "), "123 456")
#assert.eq(insert-group-separators("1234567", separator: " "), "1 234 567")
#assert.eq(insert-group-separators("12345678", separator: " "), "12 345 678")
#assert.eq(insert-group-separators("12345678", separator: " ", size: 2), "12 34 56 78")
#assert.eq(insert-group-separators("1234", separator: " ", threshold: 3), "1 234")

#assert.eq(insert-group-separators("1234", separator: " ", threshold: 3, invert: true), "123 4")
#assert.eq(insert-group-separators("1234567", separator: " ", threshold: 3, invert: true), "123 456 7")
#assert.eq(insert-group-separators("1234567", separator: " ", size: 2, threshold: 3, invert: true), "12 34 56 7")



#let contextual-group(x, invert: false) = {
  insert-group-separators(x, invert: invert)
}


/// Attaches sub-/super-script values using text mode, while allowing for 
/// stacking of a combined sub-script and super-script. 
/// - body (content): Content to attach to
/// - t (content): Superscript value
/// - b (content): Subscript value
#let non-math-attach(body, t: none, b: none) = {
  t = if t != none { super(typographic: false, t) } 
  b = if b != none { sub(typographic: false, b) } 
  if t != none and b != none {
    let width = calc.max(measure(t).width, measure(b).width)
    body + box(width: width, sym.zws + place(top, sym.zws + t) + place(top, sym.zws + b))
  } else {
    body + t + b
  }
} 


/// Takes a sequence of digits and returns a new sequence of length `digits`. 
/// If the input sequence is too short, a corresponding number of trailing
/// zeros is appended. Exceeding inputs are truncated. 
#let fit-decimals(x, digits) = {
  let len = x.len()
  if len == digits or digits == auto { return x }
  if len < digits { return x + "0" * (digits - len) }
  if len > digits { return x.slice(0, digits) }
}

#assert.eq(fit-decimals("345", 3), "345")
#assert.eq(fit-decimals("345", 4), "3450")
#assert.eq(fit-decimals("345", 2), "34")




#let format-integer = it => {
  // int, group
  if type(it.group) == dictionary and it.int != none { it.int = insert-group-separators(it.int, ..it.group) }
  if it.int == "" { it.int = "0" }
  it.int
}



#let format-fractional = it => {
  // frac, group, digits, decimal-separator?
  let frac = fit-decimals(it.frac, it.digits)
  if frac.len() == 0 { return none }
  if type(it.group) == dictionary { frac = insert-group-separators(frac, invert: true, ..it.group) }
  it.decimal-separator + frac
}



#let format-comma-number = it => {
  // sign, int, frac, digits, group, positive-sign
  let frac = format-fractional((frac: it.frac, group: it.group, digits: it.digits, decimal-separator: it.decimal-separator))
  
  return format-sign(it.sign, positive-sign: it.positive-sign) + format-integer((int: it.int, group: it.group)) + frac
}



#let format-uncertainty = it => {
  /// pm, digits, mode, concise, tight, math
  let pm = it.pm
  if pm == none { return () }
  let is-symmetric = type(pm.first()) != array
  if is-symmetric { pm = (pm,) }

  if it.concise {
    let compact-pm = (
      it.mode == "compact" or 
      (it.mode == "compact-separator" and pm.map(x => x.first().trim("0")).all(x => x.len() == 0))
    )
      
    if compact-pm {
      pm = pm.map(x => utility.shift-decimal-left(..x, -it.digits))
      it.digits = auto
    }
  }

  pm = pm.map(((int, frac)) => 
    format-comma-number((
      sign: none, int: int, frac: frac, digits: it.digits, group: false, positive-sign: false, decimal-separator: it.decimal-separator
    ))
  )
  if is-symmetric {
    if it.concise { ("(", pm.first(), ")") }
    else if it.math {
      (
        math.class("normal", none),
        math.class(if it.tight {"normal"} else {"binary"}, sym.plus.minus),
        pm.first()
      )
    } else {
      let space = if not it.tight { sym.space.thin }
      (
        space, sym.plus.minus, space,
        pm.first()
      )
    }
  } else if it.math {
     (
      math.attach(
        none, 
        t: $+#pm.at(0)$, 
        b: $-#pm.at(1)$
      ),
    )
  } else {
    (
      non-math-attach(
        none, 
        t: "+" + pm.at(0), 
        b: "−" + pm.at(1)
      ),
    )
  }
}



#let format-power = it => {
  /// x, base, product, positive-sign-exponent, tight, math
  if it.exponent == none { return () }
  
  let (sign, integer, fractional) = decompose-signed-float-string(it.exponent)
  let exponent = format-comma-number((sign: sign, int: integer, frac: fractional, digits: auto, group: false, positive-sign: it.positive-sign-exponent, decimal-separator: it.decimal-separator))

  if it.math {
    let power = math.attach([#it.base], t: [#exponent])
    if it.product == none { (power,) }
    else {
      (
        box(),
        math.class(if it.tight {"normal"} else {"binary"}, it.product),
        power
      )
    }
  } else {    
    let power = non-math-attach([#it.base], t: [#exponent])
    if it.product == none { (power,) }
    else {
      let space = if not it.tight { sym.space.thin }
      (
        box(), 
        space, it.product, space, 
        power
      )
    }
  }
}



#let show-num-impl = it => {
  /// sign, int, frac, e, pm, 
  /// digits
  /// omit-unity-mantissa, uncertainty-mode, positive-sign
  
  let omit-mantissa = (
    it.omit-unity-mantissa and it.int == "1" and
    it.frac == "" and it.e != none and it.pm == none and it.digits == 0
  )

  assert(
    it.uncertainty-mode in ("separate", "compact", "compact-separator"), 
    message: "The uncertainty-mode can be one of \"separate\", \"compact\", \"compact-separator\", got " + repr(it.uncertainty-mode)
  )
  let concise-uncertainty = it.uncertainty-mode != "separate"


  

  let integer = (
    sign: it.sign,
    int: if omit-mantissa { none } else { it.int },
    decimal-separator: it.decimal-separator,
    group: it.group
  )
  

  let uncertainty = (
    pm: it.pm,
    digits: it.digits,
    concise: concise-uncertainty,
    tight: it.tight,
    math: it.math,
    mode: it.uncertainty-mode,
    decimal-separator: it.decimal-separator
  )
  
  
  let power = (
    exponent: it.e, 
    base: it.base,
    product: if omit-mantissa {none} else {it.product},
    positive-sign-exponent: it.positive-sign-exponent,
    tight: it.tight,
    math: it.math,
    decimal-separator: it.decimal-separator
  )
  
  let integer-part = (
    format-sign(it.sign, positive-sign: it.positive-sign),
    format-integer(integer),
  )
  
  let fractional-part = (
    format-fractional((frac: it.frac, group: it.group, digits: it.digits, decimal-separator: it.decimal-separator)),
  )

  let uncertainty-part = format-uncertainty(uncertainty)

  if concise-uncertainty {
    fractional-part += uncertainty-part
    uncertainty-part = ()
  } 
  
  
  if it.pm != none and (it.e != none or it.fpau) and not concise-uncertainty {
    integer-part = ("(",) + integer-part
    uncertainty-part.push(")")
  }
  
  let result = (
    integer-part,
    fractional-part,
    uncertainty-part,
    format-power(power),
  )
  return result
}



