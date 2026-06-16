// page containing title followed by a blank page. First page of the document

#let metadata = toml("../metadata.toml")


#text(font: "Onest")[
= #metadata.title


== #metadata.subtitle
]

#pagebreak(to: "odd")
