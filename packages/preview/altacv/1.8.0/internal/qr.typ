// Header QR code (opt-in via `preferences.qrCode`), restoring the
// most-followed link on a printed CV. Validates, resolves and renders
// the preference; only this file imports `@preview/zebra`, so swapping
// QR implementations stays a one-file change. Zebra emits vector
// paths, so the matrix stays crisp and takes a `fill` like any shape.

#import "@preview/zebra:0.1.0": qrcode

// Called from `_validate_preferences`, so a typo (`qrCode: true`)
// fails up front rather than inside `qrcode(...)` at render time.
#let _check_qr_code(value) = {
  if value == none or value == auto { return }
  if type(value) != str {
    panic(
      "qrCode must be `none`, `auto`, or a URL string, got: " + repr(value),
    )
  }
  if value == "" {
    panic("qrCode must be a non-empty string when not `none` / `auto`.")
  }
}

// Separate from `_check_qr_code` because `auto` needs `basics`.
#let _resolve_qr_url(qr-code, basics) = {
  if qr-code == none { return none }
  if qr-code != auto { return qr-code }
  let url = basics.at("url", default: none)
  if url == none {
    panic(
      "preferences.qrCode is `auto` but basics.url is missing. "
        + "Set basics.url to the destination URL, or pass the URL "
        + "directly via preferences.qrCode.",
    )
  }
  if type(url) != str {
    panic("basics.url must be a string, got: " + repr(url))
  }
  if url == "" {
    panic(
      "basics.url is empty; set it to the destination URL or remove preferences.qrCode.",
    )
  }
  url
}

// `quiet-zone: 0`: the header padding already supplies whitespace, and
// zebra's default 4-module zone would shrink the matrix.
//
// Neither zebra's output nor `link` takes alt text, so the matrix goes
// in `figure(alt: url)`, Typst's carrier for alt text on non-image
// content in tagged PDF. Unnumbered, unoutlined and gap-free, it
// leaves the layout unchanged.
#let _qr_render(url, size, fill) = link(
  url,
  figure(
    qrcode(url, width: size, quiet-zone: 0, fill: fill),
    alt: url,
    numbering: none,
    outlined: false,
    gap: 0pt,
  ),
)
