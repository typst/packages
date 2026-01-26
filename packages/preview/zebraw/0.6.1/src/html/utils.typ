
#let repr-or-str(x) = {
  if type(x) == str {
    x
  } else {
    repr(x)
  }
}

#let class-list(..cls) = cls.pos().filter(it => it != none).join(" ")

#let create-style(..styles) = styles.named().pairs().map(((k, v)) => k + ":" + v).join(";")

#let create-style-dict(styles) = styles.pairs().map(((k, v)) => k + ":" + v).join(";")
