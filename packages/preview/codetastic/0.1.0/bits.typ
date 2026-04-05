
// TODO: This probably should be improved / optimized.

#let pow = calc.pow.with(2)

#let divmod(n) = (calc.quo(n, 2), calc.rem(n, 2))

#let new(pad:0) = (false,) * calc.max(1, pad)

/// >>> bits.to-int(()) == 0
/// >>> bits.to-int((true,)) == 1
/// >>> bits.to-int((true,false)) == 2
#let to-int(b) = b.rev().enumerate().fold(0, (d, bit) => d + if bit.at(1) {1} else {0} * pow(bit.at(0)))

#let display(b, format: (b) => b) = format(b.map((bit) => if bit {"1"} else {"0"}).join())

#let shift(b, n) = if n > 0 {
  return b + (false,)*n
} else if n == 0 {
  return b
} else {
  return b.slice(0, n)
}

#let shift-to(b, n) = if b.len() < n {
  b + (false,) * (n - b.len())
} else {
  b
}

#let at(b, i) = b.at(i)

#let trim(b) = b.fold((), (b, bit) => {if b != () or bit {b.push(bit)}; b})

#let pad(b, pad) = if b.len() < pad { (false,) * (pad - b.len()) + b} else { b }

#let pad-same(a, b) = if a.len() < b.len() {
  (pad(a, b.len()), b)
} else if b.len() < a.len() {
  (a, pad(b, a.len()))
} else {
  (a, b)
}

#let neg(b) = b.map((bit) => not bit)
#let inv = neg

#let band(a, b) = {
  (a, b) = pad-same(a, b)
  a.enumerate().map(((i, bit)) => bit and b.at(i))
}

#let bor(a, b) = {
  (a, b) = pad-same(a, b)
  a.enumerate().map(((i, bit)) => bit or b.at(i))
}

#let xor(a, b) = {
  (a, b) = pad-same(a, b)
  a.enumerate().map(((i, bit)) => bit != b.at(i))
}

#let is-zero(b) = b.all((bit) => not bit)

#let most-sig(b) = {
  return b.len() - b.position((v) => v) - 1
}
#let most-sig-idx(b) = {
  return b.position((v) => v)
}

#let bits-map = (
  (),
  (true,),
  (true,false),
  (true,true),
  (true,false,false),
  (true,false,true),
  (true,true,false),
  (true,true,true),
  (true,false,false,false),
  (true,false,false,true),
  (true,false,true,false),
  (true,false,true,true),
  (true,true,false,false),
  (true,true,false,true),
  (true,true,true,false),
  (true,true,true,true),
  (true,false,false,false,false),
  (true,false,false,false,true),
  (true,false,false,true,false),
  (true,false,false,true,true),
  (true,false,true,false,false),
  (true,false,true,false,true),
  (true,false,true,true,false),
  (true,false,true,true,true),
  (true,true,false,false,false),
  (true,true,false,false,true),
  (true,true,false,true,false),
  (true,true,false,true,true),
  (true,true,true,false,false),
  (true,true,true,false,true),
  (true,true,true,true,false),
  (true,true,true,true,true),
  (true,false,false,false,false,false),
  (true,false,false,false,false,true),
  (true,false,false,false,true,false),
  (true,false,false,false,true,true),
  (true,false,false,true,false,false),
  (true,false,false,true,false,true),
  (true,false,false,true,true,false),
  (true,false,false,true,true,true),
  (true,false,true,false,false,false),
  (true,false,true,false,false,true),
  (true,false,true,false,true,false),
  (true,false,true,false,true,true),
  (true,false,true,true,false,false),
  (true,false,true,true,false,true),
  (true,false,true,true,true,false),
  (true,false,true,true,true,true),
  (true,true,false,false,false,false),
  (true,true,false,false,false,true),
  (true,true,false,false,true,false),
  (true,true,false,false,true,true),
  (true,true,false,true,false,false),
  (true,true,false,true,false,true),
  (true,true,false,true,true,false),
  (true,true,false,true,true,true),
  (true,true,true,false,false,false),
  (true,true,true,false,false,true),
  (true,true,true,false,true,false),
  (true,true,true,false,true,true),
  (true,true,true,true,false,false),
  (true,true,true,true,false,true),
  (true,true,true,true,true,false),
  (true,true,true,true,true,true),
  (true,false,false,false,false,false,false),
  (true,false,false,false,false,false,true),
  (true,false,false,false,false,true,false),
  (true,false,false,false,false,true,true),
  (true,false,false,false,true,false,false),
  (true,false,false,false,true,false,true),
  (true,false,false,false,true,true,false),
  (true,false,false,false,true,true,true),
  (true,false,false,true,false,false,false),
  (true,false,false,true,false,false,true),
  (true,false,false,true,false,true,false),
  (true,false,false,true,false,true,true),
  (true,false,false,true,true,false,false),
  (true,false,false,true,true,false,true),
  (true,false,false,true,true,true,false),
  (true,false,false,true,true,true,true),
  (true,false,true,false,false,false,false),
  (true,false,true,false,false,false,true),
  (true,false,true,false,false,true,false),
  (true,false,true,false,false,true,true),
  (true,false,true,false,true,false,false),
  (true,false,true,false,true,false,true),
  (true,false,true,false,true,true,false),
  (true,false,true,false,true,true,true),
  (true,false,true,true,false,false,false),
  (true,false,true,true,false,false,true),
  (true,false,true,true,false,true,false),
  (true,false,true,true,false,true,true),
  (true,false,true,true,true,false,false),
  (true,false,true,true,true,false,true),
  (true,false,true,true,true,true,false),
  (true,false,true,true,true,true,true),
  (true,true,false,false,false,false,false),
  (true,true,false,false,false,false,true),
  (true,true,false,false,false,true,false),
  (true,true,false,false,false,true,true),
  (true,true,false,false,true,false,false),
  (true,true,false,false,true,false,true),
  (true,true,false,false,true,true,false),
  (true,true,false,false,true,true,true),
  (true,true,false,true,false,false,false),
  (true,true,false,true,false,false,true),
  (true,true,false,true,false,true,false),
  (true,true,false,true,false,true,true),
  (true,true,false,true,true,false,false),
  (true,true,false,true,true,false,true),
  (true,true,false,true,true,true,false),
  (true,true,false,true,true,true,true),
  (true,true,true,false,false,false,false),
  (true,true,true,false,false,false,true),
  (true,true,true,false,false,true,false),
  (true,true,true,false,false,true,true),
  (true,true,true,false,true,false,false),
  (true,true,true,false,true,false,true),
  (true,true,true,false,true,true,false),
  (true,true,true,false,true,true,true),
  (true,true,true,true,false,false,false),
  (true,true,true,true,false,false,true),
  (true,true,true,true,false,true,false),
  (true,true,true,true,false,true,true),
  (true,true,true,true,true,false,false),
  (true,true,true,true,true,false,true),
  (true,true,true,true,true,true,false),
  (true,true,true,true,true,true,true),
  (true,false,false,false,false,false,false,false),
  (true,false,false,false,false,false,false,true),
  (true,false,false,false,false,false,true,false),
  (true,false,false,false,false,false,true,true),
  (true,false,false,false,false,true,false,false),
  (true,false,false,false,false,true,false,true),
  (true,false,false,false,false,true,true,false),
  (true,false,false,false,false,true,true,true),
  (true,false,false,false,true,false,false,false),
  (true,false,false,false,true,false,false,true),
  (true,false,false,false,true,false,true,false),
  (true,false,false,false,true,false,true,true),
  (true,false,false,false,true,true,false,false),
  (true,false,false,false,true,true,false,true),
  (true,false,false,false,true,true,true,false),
  (true,false,false,false,true,true,true,true),
  (true,false,false,true,false,false,false,false),
  (true,false,false,true,false,false,false,true),
  (true,false,false,true,false,false,true,false),
  (true,false,false,true,false,false,true,true),
  (true,false,false,true,false,true,false,false),
  (true,false,false,true,false,true,false,true),
  (true,false,false,true,false,true,true,false),
  (true,false,false,true,false,true,true,true),
  (true,false,false,true,true,false,false,false),
  (true,false,false,true,true,false,false,true),
  (true,false,false,true,true,false,true,false),
  (true,false,false,true,true,false,true,true),
  (true,false,false,true,true,true,false,false),
  (true,false,false,true,true,true,false,true),
  (true,false,false,true,true,true,true,false),
  (true,false,false,true,true,true,true,true),
  (true,false,true,false,false,false,false,false),
  (true,false,true,false,false,false,false,true),
  (true,false,true,false,false,false,true,false),
  (true,false,true,false,false,false,true,true),
  (true,false,true,false,false,true,false,false),
  (true,false,true,false,false,true,false,true),
  (true,false,true,false,false,true,true,false),
  (true,false,true,false,false,true,true,true),
  (true,false,true,false,true,false,false,false),
  (true,false,true,false,true,false,false,true),
  (true,false,true,false,true,false,true,false),
  (true,false,true,false,true,false,true,true),
  (true,false,true,false,true,true,false,false),
  (true,false,true,false,true,true,false,true),
  (true,false,true,false,true,true,true,false),
  (true,false,true,false,true,true,true,true),
  (true,false,true,true,false,false,false,false),
  (true,false,true,true,false,false,false,true),
  (true,false,true,true,false,false,true,false),
  (true,false,true,true,false,false,true,true),
  (true,false,true,true,false,true,false,false),
  (true,false,true,true,false,true,false,true),
  (true,false,true,true,false,true,true,false),
  (true,false,true,true,false,true,true,true),
  (true,false,true,true,true,false,false,false),
  (true,false,true,true,true,false,false,true),
  (true,false,true,true,true,false,true,false),
  (true,false,true,true,true,false,true,true),
  (true,false,true,true,true,true,false,false),
  (true,false,true,true,true,true,false,true),
  (true,false,true,true,true,true,true,false),
  (true,false,true,true,true,true,true,true),
  (true,true,false,false,false,false,false,false),
  (true,true,false,false,false,false,false,true),
  (true,true,false,false,false,false,true,false),
  (true,true,false,false,false,false,true,true),
  (true,true,false,false,false,true,false,false),
  (true,true,false,false,false,true,false,true),
  (true,true,false,false,false,true,true,false),
  (true,true,false,false,false,true,true,true),
  (true,true,false,false,true,false,false,false),
  (true,true,false,false,true,false,false,true),
  (true,true,false,false,true,false,true,false),
  (true,true,false,false,true,false,true,true),
  (true,true,false,false,true,true,false,false),
  (true,true,false,false,true,true,false,true),
  (true,true,false,false,true,true,true,false),
  (true,true,false,false,true,true,true,true),
  (true,true,false,true,false,false,false,false),
  (true,true,false,true,false,false,false,true),
  (true,true,false,true,false,false,true,false),
  (true,true,false,true,false,false,true,true),
  (true,true,false,true,false,true,false,false),
  (true,true,false,true,false,true,false,true),
  (true,true,false,true,false,true,true,false),
  (true,true,false,true,false,true,true,true),
  (true,true,false,true,true,false,false,false),
  (true,true,false,true,true,false,false,true),
  (true,true,false,true,true,false,true,false),
  (true,true,false,true,true,false,true,true),
  (true,true,false,true,true,true,false,false),
  (true,true,false,true,true,true,false,true),
  (true,true,false,true,true,true,true,false),
  (true,true,false,true,true,true,true,true),
  (true,true,true,false,false,false,false,false),
  (true,true,true,false,false,false,false,true),
  (true,true,true,false,false,false,true,false),
  (true,true,true,false,false,false,true,true),
  (true,true,true,false,false,true,false,false),
  (true,true,true,false,false,true,false,true),
  (true,true,true,false,false,true,true,false),
  (true,true,true,false,false,true,true,true),
  (true,true,true,false,true,false,false,false),
  (true,true,true,false,true,false,false,true),
  (true,true,true,false,true,false,true,false),
  (true,true,true,false,true,false,true,true),
  (true,true,true,false,true,true,false,false),
  (true,true,true,false,true,true,false,true),
  (true,true,true,false,true,true,true,false),
  (true,true,true,false,true,true,true,true),
  (true,true,true,true,false,false,false,false),
  (true,true,true,true,false,false,false,true),
  (true,true,true,true,false,false,true,false),
  (true,true,true,true,false,false,true,true),
  (true,true,true,true,false,true,false,false),
  (true,true,true,true,false,true,false,true),
  (true,true,true,true,false,true,true,false),
  (true,true,true,true,false,true,true,true),
  (true,true,true,true,true,false,false,false),
  (true,true,true,true,true,false,false,true),
  (true,true,true,true,true,false,true,false),
  (true,true,true,true,true,false,true,true),
  (true,true,true,true,true,true,false,false),
  (true,true,true,true,true,true,false,true),
  (true,true,true,true,true,true,true,false),
  (true,true,true,true,true,true,true,true)
)

/// >>> bits.from-int(0) == ()
/// >>> bits.from-int(0, pad:8) == (false,) * 8
/// >>> bits.from-int(1) == (true,)
/// >>> bits.from-int(1, pad:8) == (false,) * 7 + (true,)
/// >>> bits.from-int(2) == (true, false)
/// >>> bits.from-int(254, pad:8) == (true,) * 7 + (false,)
/// >>> bits.from-int(255, pad:8) == (true,) * 8
#let from-int(n, pad:0) = {
  let bin = ()
  if n < 256 {
    bin = bits-map.at(n)
  } else {
    let mod
    while n > 0 {
      (n, mod) = divmod(n)
      bin.push(mod)
    }
    bin = bin.rev().map((bit) => (false, true).at(bit))
  }
  if bin.len() < pad {
    bin = (false,) * (pad - bin.len()) + bin
  }
  return bin
}

/// >>> bits.from-str("0000") == (false,) * 4
/// >>> bits.from-str("101010") == (true, false) * 3
/// >>> bits.from-str("100000000") == (true,) + (false,) * 8
/// >>> bits.from-str("0011011101") == (false,false,true,true,false,true,true,true,false,true)
#let from-str(s, pad:0) = {
  let bin = ()
  for c in s {
    bin.push(c == "1")
  }
  bin
}

#let from(n, pad:0) = if type(n) == "array" {
  if n.len() < pad {
    n = (false, ) * (pad - n.len()) + n
  }
  return n
} else if type(n) == "string" {
  from-str(n, pad:pad)
} else {
  from-int(n, pad:pad)
}
