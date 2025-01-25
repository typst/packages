# qcm
Qualitative Colormaps for Typst

Qualitative colormaps contain a fixed number of distinct and easily differentiable colors. They are suitable to use for e.g. categorical data visualization.

## Source
The following colormaps are available:
- all [colorbrew](https://github.com/axismaps/colorbrewer/) qualitive colormaps, for discovery and as documentation visit [colorbrewer2.org](https://colorbrewer2.org)

## Usage
Usage is very simple:
```typst
#import "@preview/qcm:0.1.0": colormap

#colormap("Set1", 5)
```