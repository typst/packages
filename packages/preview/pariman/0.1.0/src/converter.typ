#let multiply-unit(..units) = {
  units = units.pos()

  let result = ()
  for (name, exp) in units {
    let found = result.position(((n, e)) => n == name)
    if found == none {
      result.push((name, exp))
    } else {
      result.at(found).at(1) += exp
    }
  }
  result.filter(((n, e)) => e != 0)
}

#let invert-unit(..units) = {
  units.pos().map(((n, e)) => (n, -e))
}

#let operate-unit(..units, func: it => it) = {
  units.pos().map(((n, e)) => (n, func(e)))
}

#let power-unit(..units, n) = operate-unit(..units, func: e => n * e)
#let root-unit(..units, n) = operate-unit(..units, func: e => e/n)
