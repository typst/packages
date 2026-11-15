#import "context.typ": component-wrapper
#import "../palettes.typ": contrast, readable-accent, prefer-light

// These helpers change emphasis only. Font, size, weight, and line spacing
// continue to come from the surrounding text, including headings and blocks.
#let render-muted(self: none, body) = [#metadata(body)<ambrosia-muted>]
#let render-subtle(self: none, body) = [#metadata(body)<ambrosia-subtle>]
#let muted(body) = component-wrapper(render-muted, body)
#let subtle(body) = component-wrapper(render-subtle, body)

#let tone-ink(preferred, background, fallback, subtle: false) = {
  // A non-solid fill has no single backing color; retain inherited ink.
  if type(background) != color { return fallback }
  let ink = readable-accent(preferred, (background,), dark: prefer-light(background))
  if not subtle { return ink }
  // Fade at most 20%, while retaining 4.5:1 on a known solid surface. Roles
  // may converge when the palette has little remaining contrast headroom.
  let low = 0%
  let high = 20%
  for _ in range(12) {
    let fade = (low + high) / 2
    let candidate = color.mix((ink, 100% - fade), (background, fade), space: color.oklab)
    if contrast(candidate, background) >= 4.5 { low = fade } else { high = fade }
  }
  color.mix((ink, 100% - low), (background, low), space: color.oklab)
}

#let apply-tone-style(muted: none, background: auto, body) = {
  let show-tone(it, subtle: false) = context {
    let surface = if background == auto { page.fill } else { background }
    text(fill: tone-ink(muted, surface, text.fill, subtle: subtle), it.value)
  }
  show <ambrosia-muted>: show-tone
  show <ambrosia-subtle>: show-tone.with(subtle: true)
  body
}
