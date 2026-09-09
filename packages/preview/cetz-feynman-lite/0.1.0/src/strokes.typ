#import "paths.typ": frame, add, mul
// Sample once on the complete visible path. Cutting this polyline later keeps
// the original wave phase, taper and cycle count unchanged.
#let stroke-points(route, offset-sign: 1) = {
  let st = route.style
  let length = route.table.length*(route.end - route.start)
  if st.line == "coil" {
    // Fit full turns plus a half turn to the visible baseline. The local
    // ellipse drifts longitudinally; no endpoint amplitude taper is needed.
    let aspect = st.at("gluon-aspect", default: 1.1)
    let scale = calc.min(1, length/(2*aspect*st.amplitude + st.wavelength/2))
    let radius = st.amplitude*scale
    let excursion = aspect*radius
    let turns = calc.max(0, calc.round((length - 2*excursion)/st.wavelength - 0.5))
    let pitch = (length - 2*excursion)/(turns+0.5)
    let steps = int(calc.max(64, (turns+0.5)*64))
    return range(steps+1).map(i => {
      let phase = i/steps*(turns+0.5)*360deg
      let x = i/steps*(turns+0.5)*pitch + excursion*(1-calc.cos(phase))
      let f = frame(route.table, route.start + x/route.table.length)
      add(f.point, mul(f.normal, radius*calc.sin(phase)))
    })
  }
  let cycles = calc.max(1, calc.round(length/st.wavelength))
  let steps = int(calc.max(64, cycles*24))
  range(steps+1).map(i => {
    let t = i/steps
    let s = route.start + t*(route.end - route.start)
    let f = frame(route.table, s)
    let taper = calc.min(1, t*12, (1-t)*12)
    if st.line == "double" {
      add(f.point, mul(f.normal, offset-sign*st.amplitude*taper))
    } else if st.line == "wave" {
      add(f.point, mul(f.normal, st.amplitude*calc.sin(t*cycles*360deg)*taper))
    } else { f.point }
  })
}
