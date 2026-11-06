#let part-linear-gradient(grad, pos1, pos2) = {
  let stops = grad.stops()

  // only get inside the interval
  stops = stops.filter(s => s.at(1) >= pos1 and s.at(1) <= pos2)

  let sorted = stops.sorted(key: s => s.at(1))

  // add edge points if needed
  if sorted.at(0).at(1) != 0% { sorted.insert(0, (grad.sample(pos1), pos1)) }
  if sorted.last().at(1) != 100% { sorted.push((grad.sample(pos2), pos2)) }
  
  // scale to fit 0%-100%
  sorted = sorted.map(s => { s.at(1) -= sorted.at(0).at(1); s })
  sorted = sorted.map(s => { s.at(1) /= float(sorted.last().at(1)); s })

  return gradient.linear(..sorted)
}