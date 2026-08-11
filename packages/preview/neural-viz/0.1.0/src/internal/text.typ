#let clip-str(txt, n) = {
  let n = int(calc.floor(n))
  let chars = txt.clusters()
  if n <= 0 {
    ""
  } else if chars.len() <= n {
    txt
  } else {
    chars.slice(0, n).join("")
  }
}

#let truncate-title(txt, enabled: true, max-chars: 18) = {
  if txt == none {
    none
  } else {
    let chars = txt.clusters()
    if not enabled or chars.len() <= max-chars {
      txt
    } else if max-chars <= 3 {
      clip-str(txt, max-chars)
    } else {
      clip-str(txt, max-chars - 3) + "..."
    }
  }
}

#let fit-lines(txt, max-chars: 16, max-lines: 2) = {
  if txt == none {
    none
  } else {
    // Manual control only: no automatic cuts or wraps.
    txt
  }
}
