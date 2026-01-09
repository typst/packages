#import "../../helpers.typ": *

#let solution(buildings) = {
  if buildings.len() == 0 { return () }

  // Create events: (x, type, height, building_idx)
  // type: 0 = start (entering), 1 = end (leaving)
  // For start events, we use negative height for sorting (higher buildings first)
  let events = ()
  for (idx, b) in buildings.enumerate() {
    let (left, right, height) = (b.at(0), b.at(1), b.at(2))
    // Start event: (x, 0, height, idx) - type 0 means start
    events.push((left, 0, height, idx))
    // End event: (x, 1, height, idx) - type 1 means end
    events.push((right, 1, height, idx))
  }

  // Sort events:
  // 1. By x coordinate
  // 2. Start events before end events at same x
  // 3. For starts: higher height first (to avoid redundant points)
  // 4. For ends: lower height first
  events = events.sorted(key: e => {
    let (x, typ, h, _) = e
    if typ == 0 {
      // Start: sort by x, then type (0 before 1), then -height (higher first)
      (x, typ, -h)
    } else {
      // End: sort by x, then type, then height (lower first)
      (x, typ, h)
    }
  })

  // Active buildings: we'll use a sorted array as a max-heap simulation
  // Store (height, end_x, idx) for each active building
  let active = ()
  let result = ()
  let prev-max-height = 0

  for event in events {
    let (x, typ, height, idx) = event

    if typ == 0 {
      // Start event: add building to active set
      let b = buildings.at(idx)
      let end-x = b.at(1)
      // Insert into active (we'll keep it sorted by height descending)
      active.push((height, end-x, idx))
      // Sort by height descending
      active = active.sorted(key: a => -a.at(0))
    } else {
      // End event: remove building from active set
      // Find and remove the building with matching idx
      let new-active = ()
      for a in active {
        if a.at(2) != idx {
          new-active.push(a)
        }
      }
      active = new-active
    }

    // Remove expired buildings (whose end_x <= current x)
    let new-active = ()
    for a in active {
      if a.at(1) > x {
        new-active.push(a)
      }
    }
    active = new-active

    // Get current max height
    let curr-max-height = if active.len() > 0 { active.at(0).at(0) } else { 0 }

    // If height changed, record key point
    if curr-max-height != prev-max-height {
      result.push((x, curr-max-height))
      prev-max-height = curr-max-height
    }
  }

  result
}
