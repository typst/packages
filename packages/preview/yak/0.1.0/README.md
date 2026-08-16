# Yak

## Description

A typst plugin to run jq filter agains typst data.

Full Documentation for jq: https://gedenkt.at/jaq/manual/#corelang

```typ
#import "@preview/yak:0.1.0": *

#yak(json("data.json"), ".")
```