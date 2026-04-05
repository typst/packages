#let timeline-state = state("timeline-dots", (:))

#let init-company-timeline(company-id, num-positions: 1) = {
  timeline-state.update(s => {
    s.insert(company-id, (
      num-positions: num-positions,
      current-position: 0,
    ))
    s
  })
}
