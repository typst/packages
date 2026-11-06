// qrypst: draw a QR code whose modules are exactly `module` on paper.
//
//   #import "qrypst.typ": qr
//   #qr("hello", module: 0.5mm)
//
// The plugin encodes the payload in byte mode at the requested
// error-correction level and returns the smallest QR version that fits.
// It returns no quiet zone; `quiet` white modules are drawn around the
// symbol here so that the clearance is in paper units too.

#let _plugin = plugin("qrypst.wasm")

// Module count and SVG for a payload. Returns (n, svg-bytes).
#let encode(payload, ecc: "M") = {
  let out = str(_plugin.svg(bytes(payload), bytes(ecc)))
  let nl = out.position("\n")
  (int(out.slice(0, nl)), bytes(out.slice(nl + 1)))
}

// The raw module matrix: an array of `n` rows, each an array of `n`
// booleans, true = dark. For callers that want to draw modules themselves.
#let matrix(payload, ecc: "M") = {
  let m = _plugin.encode(bytes(payload), bytes(ecc))
  let n = m.at(0)
  range(n).map(y => range(n).map(x => m.at(1 + y * n + x) == 1))
}

// A QR symbol as a box. `module` is the printed side of one module;
// `quiet` is the width of the white border in modules (the QR spec says 4).
#let qr(payload, module: 0.5mm, ecc: "M", quiet: 4) = {
  let (n, svg) = encode(payload, ecc: ecc)
  box(
    fill: white,
    inset: quiet * module,
    image(svg, format: "svg", width: n * module, height: n * module),
  )
}
