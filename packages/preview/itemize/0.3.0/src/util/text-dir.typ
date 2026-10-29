
#let rtl-langs = (
  "ar",
  "dv",
  "fa",
  "he",
  "ks",
  "pa",
  "ps",
  "sd",
  "ug",
  "ur",
  "yi",
)
#let get-text-dir() = {
  let _start = "left"
  let _end = "right"
  if text.dir == auto {
    if text.lang in rtl-langs {
      _start = "right"
      _end = "left"
    }
  } else {
    if text.dir == rtl {
      _start = "right"
      _end = "left"
    }
  }
  return (text-start: _start, text-end: _end)
}
