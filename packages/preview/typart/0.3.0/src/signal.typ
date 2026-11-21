// Signal: a short waveform drawn natively, to stand for a signal inside a node, a panel
// or an annotation without an image file.  Import with:  #import "signal.typ": signal
//
//   #signal("ecg")
#import "common.typ": _lens, _theme

// One period of each waveform: a function from the phase in [0, 1] to a level, or the
// (phase, level) corners of a waveform made of straight strokes.
#let _bump(u, at, width, level) = level * calc.exp(-calc.pow((u - at) / width, 2))
#let _waves = (
  sine: u => calc.sin(u * 360deg),
  square: ((0, 1), (0.5, 1), (0.5, -1), (1, -1)),
  sawtooth: ((0, -1), (1, 1)),
  // P wave, QRS complex and T wave
  ecg: u => _bump(u, 0.18, 0.035, 0.14) - _bump(u, 0.36, 0.012, 0.14) + _bump(u, 0.4, 0.014, 1) - _bump(u, 0.44, 0.012, 0.28)
    + _bump(u, 0.66, 0.06, 0.3),
  // systolic peak and dicrotic wave
  ppg: u => _bump(u, 0.28, 0.1, 1) + _bump(u, 0.58, 0.13, 0.42),
)

#let signal(
  kind,
  cycles: 3,
  width: 6em,
  height: 2em,
  stroke: auto,
  theme: (:),
  ..style,
) = context {
  let t = _theme("signal", theme, style)
  if not (kind in _waves) { assert(false, message: "signal: `kind` must be one of " + _waves.keys().join(", ") + ", got " + repr(kind)) }
  if not (type(cycles) == int and cycles > 0) { assert(false, message: "signal: `cycles` must be a positive integer, got " + repr(cycles)) }
  let (w, h) = _lens("signal", width: width, height: height).values()
  let line = if stroke == auto { (paint: auto, thickness: auto) } else { std.stroke(stroke) }
  let thickness = if line.thickness == auto { 1.4 * t.stroke } else { line.thickness.to-absolute() }
  let wave = _waves.at(kind)
  let period = if type(wave) == array { wave } else { range(49).map(k => (k / 48, wave(k / 48))) }
  let (lo, hi) = (calc.min(..period.map(p => p.at(1))), calc.max(..period.map(p => p.at(1))))
  // the wave fills the height, less the stroke that would stick out
  let y(level) = thickness / 2 + (hi - level) / (hi - lo) * (h - thickness)
  let pts = range(cycles).map(c => period.map(((u, level)) => ((c + u) * w / cycles, y(level)))).join()
  box(width: w, height: h, place(top + left, curve(
    stroke: (paint: if line.paint == auto { t.line } else { line.paint }, thickness: thickness, join: "round", cap: "round"),
    curve.move(pts.first()), ..pts.slice(1).map(curve.line))))
}
