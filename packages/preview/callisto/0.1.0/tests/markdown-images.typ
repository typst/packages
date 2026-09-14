#import "@preview/cmarker:0.1.3"
#import "@preview/mitex:0.2.5": mitex

#import "/src/callisto.typ" as callisto: *

#callisto.render(
  nb: "/tests/notebooks/Cpp.ipynb",
  handlers: (
    "text/markdown": cmarker.render.with(
        math: mitex,
        scope: (image: (path, alt: none) => image(path, alt: alt)),
    ),
  ),
)
