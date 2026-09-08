#import "../bib-style.typ": set-style

#let bib-style-junsrt = toml("junsrt.toml")
#let (bib-init, bibliography-list, bib-tex, bib-file, bib-item, citet, citep, citen, citefull) = set-style(bib-style-junsrt)
