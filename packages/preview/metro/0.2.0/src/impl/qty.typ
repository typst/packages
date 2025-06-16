#import "num.typ": num
#import "unit.typ": unit as unit_

#let qty(
  number,
  unit,
  e: none,
  pm: none,
  pw: none,
  allow-quantity-breaks: false,
  quantity-product: sym.space.thin,
  separate-uncertainty: "bracket",
  ..options
) = {
  let result = {
    let u = unit_(
      unit,
      quantity-product: quantity-product,
      ..options
    )
    num(
      number,
      exponent: e,
      uncertainty: pm,
      power: pw,
      separate-uncertainty: separate-uncertainty,
      separate-uncertainty-unit: if separate-uncertainty == "repeat" { u },
      ..options
    )
    u
  }
  return if allow-quantity-breaks {
    result
  } else {
    box(result)
  }

}