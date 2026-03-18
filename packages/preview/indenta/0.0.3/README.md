# Indenta

An attempt to fix the indentation of the first paragraph in typst.

It works.

## Usage

```typst
#set par(first-line-indent: 2em)
#import "@preview/indenta:0.0.3": fix-indent
#show: fix-indent()

```

## Demo

![image](https://github.com/flaribbit/indenta/assets/24885181/874df696-3277-4103-9166-a24639b0c7c6)

## Note

When you use `fix-indent()` with other show rules, make sure to call `fix-indent()` **after other show rules**. For example:

```typst
#show heading.where(level: 1): set text(size: 20pt)
#show: fix-indent()
```

If you want to process the content inside your custom block, you can call `fix-indent` inside your block. For example:

```typst
#block[#set text(fill: red)
#show: fix-indent()

Hello

#table()[table]

World
]
```

This package is in a very early stage and may not work as expected in some cases. Currently, there is no easy way to check if an element is inlined or not. If you got an unexpected result, you can try `fix-indent(unsafe: true)` to disable the check.

Minor fixes can be made at any time, but the package in typst universe may not be updated immediately. You can check the latest version on [GitHub](https://github.com/flaribbit/indenta) then copy and paste the code into your typst file.

If it still doesn't work as expected, you can try another solution (aka fake-par solution):

```typst
#let fakepar=context{box();v(-measure(block()+block()).height)}
#show heading: it=>it+fakepar
#show figure: it=>it+fakepar
#show math.equation.where(block: true): it=>it+fakepar
// ... other elements
```
