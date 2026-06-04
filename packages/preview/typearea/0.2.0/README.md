# typst-typearea

A KOMA-Script inspired package to better configure your typearea and margins.

```typst
#import "@preview/typearea:0.2.0": typearea

#show: typearea.with(
  paper: "a4",
  div: 9,
  binding-correction: 11mm,
)

= Hello World
```

## Reference

`typearea` accepts the following options:

### two-sided

Whether the document is two-sided. Defaults to `true`.

### binding-correction

Binding correction. Defaults to `0pt`. 

Additional margin on the inside of a page when two-sided is true. If two-sided is false it will be on the left or right side, depending on the value of `binding`. A `binding` value of `auto` will currently default to `left`.

Note: Before version 0.2.0 this was called `bcor`.

### div

How many equal parts to split the page into. Controls the margins. Defautls to `9`.

The top and bottom margin will always be one and two parts respectively. In two-sided mode the inside margin will be one part and the outside margin two parts, so the combined margins between the text on the left side and the text on the right side is the same as the margins from the outer edge of the text to the outer edge of the page.

In one-sided mode the left and right margin will take 1.5 parts each.

### header-height / footer-height

The height of the page header/footer.

### header-sep / footer-sep

The distance between the page header/footer and the text area.

### header-include / footer-include

Whether the header/footer should be counted as part of the text area when calculating the margins. Defaults to `false`.

### ..rest

All other arguments are passed on to `page()` as is. You can see which arguments `page()` accepts in the [typst reference for the page function](https://typst.app/docs/reference/layout/page/).

You should prefer this over calling or setting `page()` directly as doing so could break some of `typearea`'s functionality.

