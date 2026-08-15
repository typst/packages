#import "../lib.typ" as calepin
#show: calepin.document

#calepin.setup(echo: true)

= Fallback shim

#calepin.chunk("python")[
```python
print(42)
```
]

```r
x <- 1
```

Inline value: #calepin.inline("r", "x")

#calepin.results("chunk-1")

Store default: #calepin.store.at("get")("answer", default: "42")

Pages: #str(calepin.pages().len())

#(calepin.elements.gallery)((("pixel.svg", "A pixel"),))
