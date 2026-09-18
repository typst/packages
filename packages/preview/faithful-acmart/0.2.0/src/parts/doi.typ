// Normalize DOI input that already carries a resolver URL.

#let normalize-doi(d) = {
  let t = d.trim()
  let m = t.match(regex("(?i)^https?://(dx\\.)?doi\\.org/"))
  if m == none { t } else { t.slice(m.end) }
}
