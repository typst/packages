// Header QR code (opt-in via `preferences.qr-code`), restoring the
// most-followed link on a printed CV. Renders the code;
// `data/validation.typ` checks the preference and `sections/header.typ`
// resolves its target. Only this file imports `@preview/zebra`, so
// swapping QR implementations stays a one-file change. Zebra emits vector
// paths, so the matrix stays crisp and takes a `fill` like any shape.

#import "@preview/zebra:0.1.0": qrcode
#import "../icons.typ": _alt-figure

// `quiet-zone: 0`: the header padding already supplies whitespace, and
// zebra's default 4-module zone would shrink the matrix.
// Neither zebra's output nor `link` takes alt text, so the URL rides
// an `_alt-figure`.
#let _qr-render(url, size, fill) = link(
  url,
  _alt-figure(qrcode(url, width: size, quiet-zone: 0, fill: fill), url),
)
