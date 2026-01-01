#import "@preview/relescope:0.0.2": scope

#import "example-template.typ": config
#show: config

#let src = ```py
bar = "foo"

class Test:
    ...

def foo():
    """
    This is a foo function.
    """
    return "bar"
```

The source code is written in Python. Items in the source code are:

#let result = scope(src.text, lang: src.lang)
#result.keys().map(raw.with(block: false)).join(", ")

