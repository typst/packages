# slate-geometry - Collection Of Tablet Specifications

This package provides information for tablets (e.g. Remarkable).
The information can be used to set up the page format.

The main intention is to not have to remember the device screen sizes when
creating documents for the paper tablet and still create files which perfectly
match the device.

## Usage

Use the `setup()` function to set the page size directly.
This changes the margin at the `top` to match the toolbar size.

```typst
#import "@preview/slate-geometry:0.1.0": setup

#show: setup.with(
  "remarkable",
  "paper-pro",
  toolbar-pos: "top",
)
```

But it is also possible to retrieve the values directly:

```typst
#import "@preview/slate-geometry:0.1.0": get-size

#let (width, height) = get-size("remarkable", "paper-pro-move")
#set page(width: width, height: height)

#width.mm() mm x #height.mm() mm
```

**Toolbar**

The database also stores the approximate size of the toolbar.
This can be used to prevent the area from being used so nothing is hidden behind
it.

```typst
#import "@preview/slate-geometry:0.1.0": get-toolbar

#let bar-width = get-toolbar("remarkable", "2")
```
