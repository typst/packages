# JQ

## Description

A typst plugin to run jq filter agains typst data.

Full Documentation for jq: https://gedenkt.at/jaq/manual/#corelang

```typ
#import "@preview/jq:0.1.0": *

#jq(json("data.json", "."))
```