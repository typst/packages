#import "@preview/min-manual:0.2.1": manual

#show: manual.with(
  title: "Minimal Manuals",
  description: "Modern but sober manuals inspired by the manpages of old.",
  authors: "Maycon F. Melo <@mayconfmelo>",
  package: "min-manual:0.2.1",
  url: "typst.app/universe/package/min-manual/",
  license: "MIT",
  logo: image("docs/assets/manual-logo.png"),
  from-comments:
    read("src/lib.typ") +
    read("src/comments.typ") +
    read("src/markdown.typ"),
)


= Copyright

Copyright #sym.copyright #datetime.today().year() Maycon F. Melo. \
This manual is licensed under MIT. \
The manual source code is free software: you are free to change and redistribute
it.  There is NO WARRANTY, to the extent permitted by law.

The logo was obtained from #link("https://flaticon.com")[Flaticon] website.