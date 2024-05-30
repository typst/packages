#import "num/num.typ": num
#import "unit.typ": unit as unit_
#import "/src/utils.typ": combine-dict


#let default-options = (
  allow-quantity-breaks: false,
  quantity-product: sym.space.thin,
  separate-uncertainty: "bracket",
)

#let get-options(options) = combine-dict(options, default-options)

#let qty(
  number,
  unit,
  e: none,
  pm: none,
  pw: none,
  options
) = {
  options = get-options(options)

  let result = {
    let u = unit_(
      unit,
      options
    )
    num(
      number,
      exponent: e,
      uncertainty: pm,
      power: pw,
      options + (
        separate-uncertainty-unit: if options.separate-uncertainty == "repeat" { u }
      )
    )
    u
  }
  return if options.allow-quantity-breaks {
    result
  } else {
    box(result)
  }

}