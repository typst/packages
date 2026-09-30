// Header QR matrix — opt-in via `preferences.qrCode`. Printed CVs lose
// the clickability of digital PDFs; a QR code rescues that one link
// the reader is most likely to follow (the homepage URL). Off by
// default — turn it on with `preferences.qrCode: auto` (encode
// `basics.url`) or any literal URL string.
//
// Generation is delegated to `@preview/zebra`, the only third-party
// Typst dependency this package pulls in. Zebra emits native Typst
// vector paths (not a rasterised image), so the matrix stays crisp at
// any size and inherits a `fill` colour like any other shape. The
// dependency is fetched on first compile and cached thereafter.
//
// This module owns three concerns and nothing else: validating the
// preference value, resolving it against `basics.url`, and rendering
// the matrix wrapped in `link()`. `internal/header.typ` consumes
// `_qr_render` and composes the result into the header layout — the
// header file doesn't import zebra directly, so swapping QR
// implementations stays a one-file change.

#import "@preview/zebra:0.1.0": qrcode

// Validates `preferences.qrCode`. Accepted shapes:
//   - `none`              — no QR rendered
//   - `auto`              — encode `basics.url` at render time
//   - any non-empty string — encode that string verbatim
// Anything else panics with a message anchored at the preferences
// call site, so a typo (`qrCode: true`, `qrCode: 42`) surfaces up
// front rather than as a render-time failure inside `qrcode(...)`.
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

// Resolves the validated preference against `basics`. Returns the URL
// string to encode, or `none` when no QR should render. Separated
// from `_check_qr_code` because the `auto` lookup depends on `basics`
// — only callable once `alta()` has the data dict in hand.
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

// `quiet-zone: 0` because the surrounding header padding already
// supplies enough whitespace; zebra's default 4-module quiet zone
// would shrink the dark matrix at the print size we target. The
// `link()` wrap lets digital readers click through to the same
// destination the QR encodes.
#let _qr_render(url, size, fill) = link(
  url,
  qrcode(url, width: size, quiet-zone: 0, fill: fill),
)
