#import "../bib-style.typ": set-style

#let bib-style-jorsj = toml("jorsj.toml")
#let (bib-init, bibliography-list, bib-tex, bib-file, bib-item, citet, citep, citen, citefull) = set-style(bib-style-jorsj)
