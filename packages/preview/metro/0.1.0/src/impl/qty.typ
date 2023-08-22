#import "num.typ": num
#import "unit.typ": unit

#let qty(
  number,
  unt,
  e: none,
  pm: none,
  allow-quantity-breaks: false,
  ..options
) = {
  let result = {
    num(number, e: e, pm: pm, ..options)
    $space.thin$
    unit(unt, ..options)
  }
  return if allow-quantity-breaks {
    result
  } else {
    box(result)
  }

}