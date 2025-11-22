# Kinave

Package for easy styling of links. See [Docs](docs/manual.pdf) for a detailed guide. Below is an example of the functionality that is added.
The problem the package solves is that different link types cannot be styled seperatly, but are recognized as such. This package allows for easy styling of phone numbers, urls and mail addresses. It provides helper functions that return regex patterns for the most common use cases.


```typ
#import "@previes/kinase:0.0.1"

#show: make-link

// Insert some rules
#update-link-style(key: l-mailto(), value: it => strong(it), )
#update-link-style(key: l-url(base: "typst\.app"), value: it => emph(it))
#update-link-style(key: l-url(base: "google\.com"), before: l-url(base: "typst\.app"), value: it => highlight(it))
#update-link-style(key: l-url(base: "typst\.app/docs"), value: it => strong(it), before: l-url(base: "typst\.app"))

#link("mailto:john.smith@typst.org") \

#link("https://www.typst.app/docs")

#link("typst.app")

#link("+49 2422424422")
```

![](ressources/example.png)
