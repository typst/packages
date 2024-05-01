#let sizes = (120%, 120% * 1.5, 120% * 2, 120% * 2.5)

#let scaled-delimiter(delimiter, size) = math.lr(delimiter, size: size)

#let big(delimiter) = scaled-delimiter(delimiter, sizes.at(0))
#let Big(delimiter) = scaled-delimiter(delimiter, sizes.at(1))
#let bigg(delimiter) = scaled-delimiter(delimiter, sizes.at(2))
#let Bigg(delimiter) = scaled-delimiter(delimiter, sizes.at(3))