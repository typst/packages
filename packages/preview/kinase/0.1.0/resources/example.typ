#import "@preview/kinase:0.1.0": *

#show: make-link

#update-link-style(key: l-mailto(), value: it => strong(it), )
#update-link-style(key: l-url(base: "typst\.app"), value: it => emph(it))
#update-link-style(key: l-url(base: "google\.com"), before: l-url(base: "typst\.app"), value: it => highlight(it))
#update-link-style(key: l-url(base: "typst\.app/docs"), value: it => strong(it), before: l-url(base: "typst\.app"))

#link("mailto:john.smith@typst.org") \

#link("https://www.typst.app/docs")

#link("typst.app")

#link("+49 2422424422")
