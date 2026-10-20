#import "../bib-style.typ": set-style

#let bib-style-tieice = toml("tieice.toml")
#let (bib-init, bibliography-list, bib-tex, bib-file, bib-item, citet, citep, citen, citefull) = set-style(bib-style-tieice)
