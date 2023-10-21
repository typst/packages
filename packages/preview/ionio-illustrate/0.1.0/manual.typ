#import "lib.typ": *

#let data = csv("assets/isobutelene_epoxide.csv")
#let massspec = data.slice(1)

#set page(
  numbering: "1/1",
  header: align(right)[The `ionio-illustrate` package],
)

#set heading(numbering: "1.")
#set terms(indent: 1em)
#show link: set text(blue)
#set text(font: "Fira Sans")

#show raw.where(lang:"typ"): it => block(
  fill: rgb("#F6F4EB"),
  inset: 8pt,
  radius: 5pt,
  width: 100%,
  text(font:"Consolas", it),
)

#align(center, text(16pt)[*The `ionio-illustrate` package*])
#align(center)[Version 0.1.0]

#set par(justify: true, leading: 0.618em)
#v(3em)

= Introduction
This package implements a Cetz chart-like object for displaying mass spectrometric data in Typst documents. It allows for individually styled mass peaks, callouts, titles, and mass calipers.

= Usage
This is the minimal starting point:
```typ
#import "@preview/ionio-illustrate:0.1.0": *
#let data = csv("isobutelene_epoxide.csv")

#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
)) 

#figure((ms.display)(ms))
```

The above code produces the following content:
#let ms = mass-spectrum(massspec, args: (
  size: (12,6),
  range: (0,100),
)) 

#v(1em)
#figure((ms.display)(ms))

It is important to note at this point that the syntax for interacting with mass spectrum objects will certainly change with the introduction of a native type system. This document will be updated to reflect this upon implementation of those changes.
#pagebreak()
== `mass-spectrum()`
The `mass-spectrum()` function takes two positional arguments:
- `data` (array or dictionary): This is a 2-dimensional array relating mass-charge ratios to their intensities. By default, the first column is the mass-charge ratio and the second column is the intensity.
- `args` (dictionary): This contains suplemental data that can be used to change the style of the mass spectrum, or to add additional content using provided functions (see @extra-content).

The defaults for the `args` dictionary are shown below:

```typ
keys: (
  mz: 0,
  intensity: 1
),
size: (auto, 1),
range: (40, 400),
style: (:),
labels: (
  x: [Mass-Charge Ratio],
  y: [Relative Intensity \[%\]]
),
linestyle: (idx)=>{},
```

=== `keys`
The `keys` entry in the `args` positional argument is a dictionary that can be used to change which fields in the provided `data` array/dictionary are to be used to plot the mass spectrum. An example usage of this may be to store several mass spectra within a single datafile.

Note that arrays are 0-index based.

```typ
#let ms = mass-spectrum(massspec, args: (
  keys: (
    mz: 0, // mass-charge is contained in the first column
    intensity: 1 // intensity is contained in the second column
  )
)) 
```

=== `size`
The `keys` entry in the `args` positional argument is a tuple specifying the size of the mass spectrum on the page, in `Cetz` units.
```typ
#let ms = mass-spectrum(massspec, args: (
  size: (12,6)
)) 
```

=== `range`
The `range` entry in the `args` positional argument is a tuple specifying the min and the max of the mass-charge axis.
```typ
#let ms = mass-spectrum(massspec, args: (
  range: (0,100) // Show mass spectrum between 0 m/z and 100 m/z
)) 
```

=== `style`
The `style` entry in the `args` positional argument is a cetz style dictionary. It is presently unused until it is better understood where styling is appropriate.

=== `labels`
The `labels` entry in the `args` positional argument is a dictionary specifying the labels to be used on each axis.

Note that if you provide this entry, you must provide both child entries.

```typ
#let ms = mass-spectrum(massspec, args: (
  labels: (
    x: [Mass-Charge Ratio],
    y: [Relative Intensity \[%\]]
  )
)) 
```


=== `linestyle`
The `linestyle` entry in the `args` positional argument is a function taking two parameters: `this` (refering to the `#ms` object), and `idx` which represents the mass-charge ratio of the peak being drawn. Returning a cetz style dictionary will change the appearence of the peaks. This may be used to draw the reader's attention to a particular mass spectrum peak by colouring it in red, for example.
```typ
#let ms = mass-spectrum(massspec, args: (
  linestyle: (this, idx)=>{
      if idx==41 {return (stroke: red)}
    }
)) 
```

=== `plot-extras` <extra-content>
The `plot-extras` entry in the `args` positional argument is a function taking one parameter, `this`, which refers to the `#ms` object. It can be used to add additional content to a mass spectrum using provided functions
```typ
#let ms = mass-spectrum(massspec, args: (
  size: (14,8),range: (0,100),
  plot-extras: (this) => {
    (this.callout-above)(this, 72, content: MolecularIon())
    (this.callout-above)(this, 27)
    (this.callout-above)(this, 41)
    (this.calipers)(this, 43, 57, content: [\-CH#sub("2")])
    (this.title)(this, [Isobutelene Epoxide])
  }
)) 
#figure((ms.display)(ms))
```
#let ms = mass-spectrum(massspec, args: (
  size: (12,6), range: (0,100),
  plot-extras: (this) => {
    (this.callout-above)(this, 72, content: MolecularIon())
    (this.callout-above)(this, 27)
    (this.callout-above)(this, 41)
    (this.calipers)(this, 43, 57, content: [\-CH#sub("2")])
    (this.title)(this, [Isobutelene Epoxide])
  }
)) 
#v(1em)
#figure((ms.display)(ms))

== Method functions
This section briefly outlines method functions and where/why they might be used

=== `#ms.display(this)`
the `#ms.display` method is used to place a mass spectrum within a document. It can be called several times. It *must not* be called within the context of a `plot-extras(this)` function.

=== `#ms.title(this, content)`
the `#ms.title` method allows the addition of a title to a mass spectrum. It should be called within the context of a `plot-extras(this)` function.

=== `#ms.callout-above(this, mz, content: [])`
the `#ms.callout-above` method places a callout slightly above the intensity peak for a given mass-charge ratio. It should be called within the context of a `plot-extras(this)` function.

=== `#ms.calipers(this, mz1, mz2, content: none, height: none)`
the `#ms.calipers` method places a mass calipers between two mass spectrum peaks, along with any desired content centered above the calipers. If `height` is not specified, it is set automatically to a few units above the most intense peak. If `content` is not specified, it is set automatically to represent the loss of mass between the specified peaks. It should be called within the context of a `plot-extras(this)` function.
