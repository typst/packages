#let base-size = 1.2em
#let sizes = (base-size, base-size * 1.5, base-size * 2, base-size * 2.5)

#let scaled-delimiter(delimiter, size) = math.lr(delimiter, size: size)

#let big(delimiter) = scaled-delimiter(delimiter, sizes.at(0))
#let Big(delimiter) = scaled-delimiter(delimiter, sizes.at(1))
#let bigg(delimiter) = scaled-delimiter(delimiter, sizes.at(2))
#let Bigg(delimiter) = scaled-delimiter(delimiter, sizes.at(3))

#let paired-delimiter(left, right) = (content, size: auto) => {
  if size == auto {
    $lr(#left#content#right)$
  } else if size == none {
    $lr(#left#content#right, size: #1em)$
  } else if size == big {
    $lr(#left#content#right, size: sizes.at(#0))$
  } else if size == bigg {
    $lr(#left#content#right, size: sizes.at(#1))$
  } else if size == Big {
    $lr(#left#content#right, size: sizes.at(#2))$
  } else if size == Bigg {
    $lr(#left#content#right, size: sizes.at(#3))$
  } else {
    $lr(#left#content#right, size: size)$
  }
}