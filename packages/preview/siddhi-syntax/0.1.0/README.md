This package adds support for syntax highlighting Siddhi source code in Typst.

## How to use

Add global support to the raw black.
````typst
#import "@preview/siddhi-syntax:0.1.0": init-siddhi

#show: init-siddhi

```siddhi
@App:name("HelloWorldApp")

@source(type = 'http', receiver.url = "http://0.0.0.0:8006/cargo", @map(type = 'json'))
define stream CargoStream (weight int);
```
````