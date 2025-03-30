#import "@preview/relescope:0.0.2": pick

#import "example-template.typ": config
#show: config

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
