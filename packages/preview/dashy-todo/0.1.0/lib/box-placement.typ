// Given a set of box heights and the preferred positions for the boxes this function calculates the position for each box
#let calculate-box-positions(boxes) = {
  let total-height = boxes.map(box => box.height).sum()
  
  let positions = ()
  // If the total height of the boxes is bigger than the page height, we don't have room to re-arrange the boxes based on their preferred position. Just start at the top and place them underneath each other
  if total-height >= page.height {
    let accumulated-height = 0mm
    for box in boxes {
      let top = accumulated-height
      let bottom = top + box.height
      positions.push((top: top, bottom: bottom))
      accumulated-height = bottom
    }
  }
  // If there is still room available, try to move as many boxes to their preferred position as possible
  else {
    // `slack` is the amount of free space we still have available to move around the boxes
    let slack = page.height - total-height
    // Start filling the page at the bottom with the last box and work upwards
    let last-box-pos = page.height
    for box in boxes.rev() {
      let preferred-pos = box.preferred-pos.to-absolute() // We cannot compare pt to em, so we need to make the position absolute first
      // `lowest-possible-pos` is the lowest position we can give the box to make it barely fit the available space
      let lowest-possible-pos = last-box-pos - box.height
      // `highest-possible-pos` is the highest possible postion we can give the box so the remaining boxes still barely fit on the remaining page (all slack would be used up in this case)
      let highest-possible-pos = lowest-possible-pos - slack
      let box-pos
      // If the preferred position can be achieved, just give it to the box
      if preferred-pos >= highest-possible-pos and preferred-pos <= lowest-possible-pos {
        box-pos = preferred-pos
      }
      // If putting the box at its preferred position is impossible, move it down as much as possible to give the other boxes as much space as possible to move to their preferred positions
      else {
        box-pos = lowest-possible-pos
      }
      let top = box-pos
      let bottom = top + box.height
      positions.push((top: top, bottom: bottom))
      last-box-pos = box-pos
      // Track how much of the slack we've used up
      slack -= lowest-possible-pos - box-pos
    }
    positions = positions.rev()
  }
  positions
}