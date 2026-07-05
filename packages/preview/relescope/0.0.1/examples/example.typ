#import "@preview/relescope:0.0.1": pick
#import "@preview/zebraw:0.4.3": zebraw

#set page(width: auto, height: auto, margin: 20pt, fill: none)
#show raw: zebraw

#let src = ```py
bar = "foo"

def foo():
    """
    This is a foo function.
    """
    return "bar"
```

#let result = pick(src.text, "foo", lang: src.lang)
#raw(result.src, lang: src.lang)
