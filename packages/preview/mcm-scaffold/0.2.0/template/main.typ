#import "@preview/mcm-scaffold:0.2.0": *
#import "@preview/mitex:0.2.5": *

#show: mcm.with(
  title: "A Simple Example for MCM/ICM Typst Template",
  problem-chosen: "ABCDEF",
  team-control-number: "1111111",
  year: "2025",
  summary: [
    #lorem(100)
    
    #lorem(100)
    
    #lorem(100)

    #lorem(100)
  ],
  keywords: [MCM; ICM; Mathemetical; template],
  magic-leading: 0.65em,
)

///////////////////////Body//////////////////////////

= Introduction

Create a new file and start with following lines.

```typst
#import "@preview/mcm-scaffold:0.2.0": *

#show: mcm.with(
  title: "A Simple Example for MCM/ICM Typst Template",
  problem-chosen: "ABCDEF",
  team-control-number: "1111111",
  year: "2025",
  summary: [
  ],
  keywords: [MCM; ICM; Mathemetical; template],
  magic-leading: 0.65em,
)

///////////////////////Body//////////////////////////
= Introduction
```

= Images

== Single Image

```typst
#img-single(img: image, caption: none, placement: none)
```

=== An image with default width and no caption

```typst
#img-single(img: image("figures/image1.png"))
```

// #img-single(path: "template/figures/image1.png")
#img-single(img: image("figures/image1.png"))

=== An image with caption

```typst
#img-single(img: image("figures/image1.png"), caption:[workflow])
```

// #img-single(path: "template/figures/image1.png", caption:[workflow])
#img-single(img: image("figures/image1.png"), caption:[workflow])

=== Adjust width

```typst
#img-single(
  img: image("figures/image1.png", width: 50%), 
  caption:[image of 50% width (default 70%).]
)
```

// #img-single(
//   path: "template/figures/image1.png", 
//   width: 50%,
//   caption:[image of 50% width (default 70%).]
// )
#img-single(
  img: image("figures/image1.png", width: 50%), 
  caption:[image of 50% width (default 70%).]
)

=== Specify image placement

```t
placement: none(default)/auto/top/buttom
```


I put 3 images right below the code.

```typst
#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: top
)

#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: auto
)

#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: bottom
)
```

See where the images are gone:

// #img-single(
//   path: "template/figures/image1.png", 
//   width: 40%,
//   caption:[placement: top (default none).],
//   placement: top
// )
#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: top
)

// #img-single(
//   path: "template/figures/image1.png", 
//   width: 40%,
//   caption:[placement: auto (default none).],
//   placement: auto
// )
#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: auto
)

// #img-single(
//   path: "template/figures/image1.png", 
//   width: 40%,
//   caption:[placement: bottom (default none).],
//   placement: bottom
// )
#img-single(
  img: image("figures/image1.png", width: 40%), 
  caption:[placement: top (default none).],
  placement: bottom
)

#pagebreak()

== Multiple Images

If you want to show multiple images in one figure, try this. 

```typst
#img-grid(
  cols: 2, 
  rows: 1, 
  imgs: array, 
  subcaps: (), 
  caption: none, 
  placement: none
)
```

=== Two images in default

If not specified cloumns and rows, $1 times 2$ grid is in default.

```typst
#img-grid(
  imgs: (image("figures/image1.png", width:70%), image("figures/image1.png", width:70%)),
)
```

#img-grid(
  imgs: (image("figures/image1.png", width:70%), image("figures/image1.png", width:70%)),
)

=== Subcaptions

```typst
#img-grid(
  imgs: (image("figures/image1.png", width:70%), image("figures/image1.png", width:70%)),
  subcaps: ([(a)], [(b)]),
  caption: [Two images with subcaptions.]
)
```

#img-grid(
  imgs: (image("figures/image1.png", width:70%), image("figures/image1.png", width:70%)),
  subcaps: ([(a)], [(b)]),
  caption: [Two images with subcaptions.]
)

=== More images to show!

You can specify the columns and rows to put more images as you like.

```typst
#img-grid(
  cols: 2, rows: 2, 
  imgs: (image("figures/image1.png", width:70%),) * 4,
  subcaps: ([(a)], [(b)], [(c)], [(d)]),
  caption: [Four images with subcaptions.]
)
```

#img-grid(
  cols: 2, rows: 2, 
  imgs: (image("figures/image1.png", width:70%),) * 4,
  subcaps: ([(a)], [(b)], [(c)], [(d)]),
  caption: [Four images with subcaptions.]
)

```typst
#img-grid(
  cols: 3, rows: 2, 
  imgs: (image("figures/image1.png", width:70%),) * 6,
  subcaps: ([(a)], [(b)], [(c)], [(d)], [(e)], [(f)]),
  caption: [Six images with subcaptions.]
)
```

#img-grid(
  cols: 3, rows: 2, 
  imgs: (image("figures/image1.png", width:70%),) * 6,
  subcaps: ([(a)], [(b)], [(c)], [(d)], [(e)], [(f)]),
  caption: [Six images with subcaptions.]
)

```typst
#img-grid(
  cols: 4, rows: 3, 
  imgs: (image("figures/image1.png", width:70%),) * 12,
  subcaps: (
    [(a)], [(b)], [(c)], [(d)], [(e)], [(f)],
    [(g)], [(h)], [(i)], [(j)], [(k)], [(l)],
  ),
  caption: [Twelve images with subcaptions.]
)
```

#img-grid(
  cols: 4, rows: 3, 
  imgs: (image("figures/image1.png", width:70%),) * 12,
  subcaps: (
    [(a)], [(b)], [(c)], [(d)], [(e)], [(f)],
    [(g)], [(h)], [(i)], [(j)], [(k)], [(l)],
  ),
  caption: [Twelve images with subcaptions.]
)

= Table

```typst
#threee-line-table(
  columns: array, 
  align: auto, 
  headers: array, 
  bodies: array, 
  caption: content
)
```

== Simple three-line-table

ex: Symbols and notations are listed in the @SymbolDescription

```typst
Symbols and notations are listed in the @SymbolDescription

#threee-line-table(
  columns: (25%, 60%),  // Set colum width(auto/10%/1ft/1pt)
  headers: ([Symbol], [Explain]),
  bodies: (
    [$S_t$], [state of submersible],
    [$f_m$], [standard equation of motion],
    [$P_k^(\(t\))$], [probability of appearance],
    [$R$], [usability score],
    [$T_S$], [search mission point set],
    [$S_M$], [submersible set],
    [$T_D$], [assigned but uncompleted search mission point set],
    [$T_U$], [mission point set that violates the assignment]
  ),
  caption: "Symbol Description",
) <SymbolDescription>  //ref label
```

#threee-line-table(
  columns: (25%, 60%),
  headers: ([Symbol], [Explain]),
  // align: (left, right),
  bodies: (
    [$S_t$], [state of submersible],
    [$f_m$], [standard equation of motion],
    [$P_k^(\(t\))$], [probability of appearance],
    [$R$], [usability score],
    [$T_S$], [search mission point set],
    [$S_M$], [submersible set],
    [$T_D$], [assigned but uncompleted search mission point set],
    [$T_U$], [mission point set that violates the assignment]
  ),
  caption: "Symbol Description",
) <SymbolDescription>

== Width and alignment

```typst
Symbols and notations are listed in the @SymbolDescription

#threee-line-table(
  columns: (auto, 60%),
  align: (right, center),  // right/center/left
  headers: ([Symbol], [Explain]),
  bodies: (
    [$S_t$], [state of submersible],
    [$f_m$], [standard equation of motion],
    [$P_k^(\(t\))$], [probability of appearance],
    [$R$], [usability score],
    [$T_S$], [search mission point set],
    [$S_M$], [submersible set],
    [$T_D$], [assigned but uncompleted search mission point set],
    [$T_U$], [mission point set that violates the assignment]
  ),
  caption: "Symbol Description",
) <SymbolDescription>  //ref label
```

#threee-line-table(
  columns: (auto, 60%),
  align: (right, center),
  headers: ([Symbol], [Explain]),
  bodies: (
    [$S_t$], [state of submersible],
    [$f_m$], [standard equation of motion],
    [$P_k^(\(t\))$], [probability of appearance],
    [$R$], [usability score],
    [$T_S$], [search mission point set],
    [$S_M$], [submersible set],
    [$T_D$], [assigned but uncompleted search mission point set],
    [$T_U$], [mission point set that violates the assignment]
  ),
  caption: "Symbol Description",
) 

= Enum

```typst
#let enum-default = { set enum(numbering: "1.") }

#let enum-paren(content) = {
  set enum(numbering: "1)")
  content
  enum-default
}
```

== Tight and loose list

A tight enum would like this: 

```typst
+ item1
+ item2
+ item3
```

+ item1
+ item2
+ item3

To make it loose, add a blank line after the first line:

```typst
+ #lorem(30)

+ #lorem(30)

+ #lorem(30)
```

+ #lorem(30)

+ #lorem(30)

+ #lorem(30)

== Change numbering

```typst
#enum-paren()[
  + #lorem(20)
  + #lorem(20)
  + #lorem(20)
]
```

#enum-paren()[
  + #lorem(20)

  + #lorem(20)
  
  + #lorem(20)
]

= References

== bib

Put ``` references.bib ``` in your project file. and use ``` @<tag> ``` to ref them. @2017YOLO9000

```typst
For, emample. @2018YOLOv3
```

For, emample. @2018YOLOv3

== plain text(by yml)

If you want to use plaintext reference directory, there is a trick: Edit references.yml and replace publisher by reference text.

```yml
ref1:
    type: Article
    publisher: "ZygOS: Achieving Low Tail Latency for Microse"

ref2:
    type: Article
    publisher: "article title here"
```

= Appendix

```typ
#heading("Appendix A ", numbering: none, outlined: false)

`` `py
import ...
`` ` 


```

= Handful tools

== Paragraph with no indent

Paragraphs after figure, table or maths will be automatically with indent. Sometimes we don't need the indent.

```typst
#no-indent()
content below
```

For example, after a math block,

$ y = x^2 $

The aragraph after the block is with indent.

```typst
$ y = x^2 $

#no-indent
Paragraph with no indent.
```

$ y = x^2 $

#no-indent
Paragraph with no indent.

== Math without numbering

```typst
#math-no-number(
$ y = sqrt(x) $
)
```

#math-no-number(
$ y = sqrt(x) $
)

== Figures fly away? Place here!

Sometimes, images or tables will fly away and left a huge blank place. Use ``` #place-here() ``` to catch them back!

```typst
#place-here()[
#threee-line-table(
  columns: 7 * (10%, ),
  headers: ([a], [u], [v], [w], [p], [q], [r]),
  bodies: ([30], [10], [-8], [-2], [0.01], [0.004], [0.001]),
  caption: [A simpel table]
)
]
```

#place-here()[
#threee-line-table(
  columns: 7 * (10%, ),
  headers: ([a], [u], [v], [w], [p], [q], [r]),
  bodies: ([30], [10], [-8], [-2], [0.01], [0.004], [0.001]),
  caption: [A simpel table]
)
]

== Latex math eqaution

Support Mitex, ```typst #mitext('')```

```typst
#mitext(`
\begin{equation}
SSIM(x,y)=\frac{\left(2\mu_x\mu_y+c1\right)\left(\sigma_{xy}+c2\right)}
{\left(\mu_x^2+\mu_y^2+c1\right)\left(\sigma_x^2+\sigma_y^2+c2\right)}
\end{equation}
 
Where $\mu_x$ is the average of x, $\mu_y$ is the average of y, $\sigma_x^2$ is the variance of x, $\sigma_y^2$ is the variance of y, and $\sigma_{xy}$ is the covariance of x and y. C1=(k1L)2, C1=(k1L)2, is a constant used to maintain stability. L is the dynamic range of the pixel value. K1 = 0.01, k2 = 0.03. The structural similarity ranges from 0 to 1. When the two images are identical, the value of SSIM is equal to one.
`)
```

#mitext(`
\begin{equation}
SSIM(x,y)=\frac{\left(2\mu_x\mu_y+c1\right)\left(\sigma_{xy}+c2\right)}
{\left(\mu_x^2+\mu_y^2+c1\right)\left(\sigma_x^2+\sigma_y^2+c2\right)}
\end{equation}
 
Where $\mu_x$ is the average of x, $\mu_y$ is the average of y, $\sigma_x^2$ is the variance of x, $\sigma_y^2$ is the variance of y, and $\sigma_{xy}$ is the covariance of x and y. C1=(k1L)2, C1=(k1L)2, is a constant used to maintain stability. L is the dynamic range of the pixel value. K1 = 0.01, k2 = 0.03. The structural similarity ranges from 0 to 1. When the two images are identical, the value of SSIM is equal to one.
`)

#bibliography("references.bib")

#pagebreak()

#heading("Appendix A ", numbering: none, outlined: false)

```py
import cv2
import numpy as np
import matplotlib.pyplot as plt
from skimage import exposure
from skimage.exposure import match_histograms


def plot(img):
    plt.subplot(121)
    plt.imshow(img, 'gray')
    plt.subplot(122)
    plt.hist(img.ravel(), 256, [0, 256])
    plt.show()


if __name__ == '__main__':
    img = cv2.imread('img1.png', cv2.IMREAD_GRAYSCALE)
    hist = cv2.calcHist([img], [0], None, [256], [0, 256])
    plot(img)

    equ = cv2.equalizeHist(img)
    plot(equ)

    target = cv2.imread('mask.png', cv2.IMREAD_GRAYSCALE)
    target_hist = cv2.calcHist([target], [0], None, [256], [0, 256])
    plot(target)

    matched = match_histograms(img, target)
    plot(matched)
```
