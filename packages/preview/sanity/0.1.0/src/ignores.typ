#import "core.typ": finding
#import "collect.typ": label-exists

#let id = "orphaned-ignore"

#let run(ignores, bib-keys, cfg, bibliography-unknown: false) = {
  if not cfg.checks.at(id, default: false) { return () }
  if bibliography-unknown { return () }

  let keys = if bib-keys == none { () } else { bib-keys }
  let seen = ()
  let out = ()
  for entry in ignores {
    let target = entry.target
    if target in seen { continue }
    seen.push(target)
    if target in keys or label-exists(target) { continue }

    let reason = entry.at("reason", default: none)
    out.push(finding(
      id,
      cfg.severities.at(id),
      "sanity-ignore names <" + target + ">, which is not in the document"
        + if reason == none { "" } else { " (" + reason + ")" },
      target: target,
    ))
  }
  out
}
