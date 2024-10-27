#let p = plugin("typst_plugin_bigrational.wasm")

#let rational(x) = {
  let convert-scalar(x) = if type(x) == str {
    x
  } else if type(x) == int { 
    str(x)
  } else {
    panic("Required a scalar, representing an integer")
  }

  if type(x) in (int, str) {
    let numer = convert-scalar(x)
    (numer, "1")
  } else if type(x) == array and x.len() == 2 {
    (convert-scalar(x.at(0)), convert-scalar(x.at(1)))
  } else {
    panic("Required a scalar, representing an integer, or an array of two such scalars")
  }
}

#let add(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let c-bytes = p.add(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))
  
  let c-numer-len = int.from-bytes(c-bytes.slice(0, count: 8))
  let c-numer = str(c-bytes.slice(8, count: c-numer-len))
  
  let c-denom-len = int.from-bytes(c-bytes.slice(8 + c-numer-len, count: 8))
  let c-denom = str(c-bytes.slice(8 + c-numer-len + 8, count: c-denom-len))

  (c-numer, c-denom)
}

#let sub(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let c-bytes = p.sub(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))
  
  let c-numer-len = int.from-bytes(c-bytes.slice(0, count: 8))
  let c-numer = str(c-bytes.slice(8, count: c-numer-len))
  
  let c-denom-len = int.from-bytes(c-bytes.slice(8 + c-numer-len, count: 8))
  let c-denom = str(c-bytes.slice(8 + c-numer-len + 8, count: c-denom-len))

  (c-numer, c-denom)
}

#let div(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let c-bytes = p.div(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))
  
  let c-numer-len = int.from-bytes(c-bytes.slice(0, count: 8))
  let c-numer = str(c-bytes.slice(8, count: c-numer-len))
  
  let c-denom-len = int.from-bytes(c-bytes.slice(8 + c-numer-len, count: 8))
  let c-denom = str(c-bytes.slice(8 + c-numer-len + 8, count: c-denom-len))

  (c-numer, c-denom)
}

#let mul(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let c-bytes = p.mul(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))
  
  let c-numer-len = int.from-bytes(c-bytes.slice(0, count: 8))
  let c-numer = str(c-bytes.slice(8, count: c-numer-len))
  
  let c-denom-len = int.from-bytes(c-bytes.slice(8 + c-numer-len, count: 8))
  let c-denom = str(c-bytes.slice(8 + c-numer-len + 8, count: c-denom-len))

  (c-numer, c-denom)
}

#let repr(x) = {
  let (numer, denom) = rational(x)

  let repr-bytes = p.repr(bytes(numer), bytes(denom))

  let variant = repr-bytes.at(0)
  if variant == 0  [
    $#(str(repr-bytes.slice(1, none)))$
  ] else if variant == 1 {
    let numer-len = int.from-bytes(repr-bytes.slice(1, count: 8))
    let numer = str(repr-bytes.slice(9, count: numer-len))
    
    let denom-len = int.from-bytes(repr-bytes.slice(9 + numer-len, count: 8))
    let denom = str(repr-bytes.slice(9 + numer-len + 8, count: denom-len))

    $#str(numer)/#str(denom)$
  } else if variant == 2 {
    let whole-len = int.from-bytes(repr-bytes.slice(1, count: 8))
    let whole = str(repr-bytes.slice(9, count: whole-len))
    
    let numer-len = int.from-bytes(repr-bytes.slice(9 + whole-len, count: 8))
    let numer = str(repr-bytes.slice(9 + whole-len + 8, count: numer-len))
    
    let denom-len = int.from-bytes(repr-bytes.slice(9 + whole-len + 8 + numer-len, count: 8))
    let denom = str(repr-bytes.slice(9 + whole-len + 8 + numer-len + 8, count: denom-len))

    $#str(whole) #str(numer)/#str(denom)$
  } else {
    panic("Unknown variant: " + str(variant))
  }
}

#let to-decimal-str(x, precision: 8) = {
  let (numer, denom) = rational(x)
  str(p.to_decimal_string(bytes(numer), bytes(denom), int.to-bytes(precision)))
}

#let to-float(x, precision: 8) = {
  float(to-decimal-str(x, precision: precision))
}

#let to-decimal(x, precision: 8) = {
  decimal(to-decimal-str(x, precision: precision))
}

#let abs-diff(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let c-bytes = p.abs_diff(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))
  
  let c-numer-len = int.from-bytes(c-bytes.slice(0, count: 8))
  let c-numer = str(c-bytes.slice(8, count: c-numer-len))
  
  let c-denom-len = int.from-bytes(c-bytes.slice(8 + c-numer-len, count: 8))
  let c-denom = str(c-bytes.slice(8 + c-numer-len + 8, count: c-denom-len))

  (c-numer, c-denom)
}

#let cmp(a, b) = {
  let (a-numer, a-denom) = rational(a)
  let (b-numer, b-denom) = rational(b)
  
  let ordering-bytes = p.cmp(bytes(a-numer), bytes(a-denom), bytes(b-numer), bytes(b-denom))

  int.from-bytes(ordering-bytes)
}
