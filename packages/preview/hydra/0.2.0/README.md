# hydra
Hydra is a [typst] package allowing you to easily display the current section anywhere in your
document. In short it will show you the current section only when you need to know it, that is
when the last section still has remainig text but it's heading is nowhere to be seen.

By default hydra also assumes that you use `a4` page size and margin, see its named parameters
to adjust this.

## Note on API
The current API is subject to change in the next version when new features for general handling of
headings is added.

## Example
```typst
#import "@preview/hydra:0.2.0": hydra

#set page(header: hydra() + line(length: 100%))
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it

= Introduction
#lorem(750)

= Content
== First Section
#lorem(500)
== Second Section
#lorem(250)
== Third Section
#lorem(500)

= Annex
#lorem(10)
```
![ex1]
![ex2]
![ex3]
![ex4]
![ex5]

## Documentation
Changing the default behavior can be done using the various named parameters:
```typst
#let hydra(
  sel: heading,                     // the elements to consider
  prev-filter: (ctx, p, n) => true, // check if the last element is eligible
  next-filter: (ctx, p, n) => true, // check if the next element is eligible
  display: core.display,            // displays the eligible element
  is-book: false,                   // whether the redundancy check should be book aware
  paper: "a4",                      // the paper size to use
  page-size: auto,                  // the smaller page size if set
  top-margin: auto,                 // the top margin is set
  loc: none,                        // a location from which to search
) = {
  ...
}
```

`sel` can be a `selector`/`element`, or a tuple of (`selector`/`element`, `function`), where the
function is used in querying this is mainly useful for selecting ranges of headings without building
a complicated selector `(heading, h => h.level in (1, 2, 3))`. This function is executed for each
matching element in your document.

`loc` can be used in contexts where location is already known, this avoids a call to `locate`,
allowing you to inspect the result of `display` directly.

`prev-filter` and `next-filter` are used to check if an element is eligible for being displayed.
They receive the `context`, the previous and next element relative to the given `loc`, the element
that is checked for is not `none`, but the other may be. These fucntions are executed at most once.

If `is-book` is set to `true`, it will not display the element if it is visible on the previous
open page. This means for a book with `left` binding, if hydra is used on the right page while the
previous section is visible on the left page, it will display nothing.

Of `paper`, `page-size` and `top-margin` exactly one must be given. `paper` and `page-size` are for
convenience and will be used to calculate the `top-margin` for you. Use them as follows:

1. If you use a custom top margin, pass it to `top-margin`
2. If you use no custom top margin but a custom page size, pass the *smaller* page size to
   `page-size`
3. If you use no custom top margin or page size, but a custom paper, pass it `paper`

### Anywhere but the header
To use the hydra function out side of the header of your doc while retaining its behavior, place the
`hydra-anchor()` in the header of your document, it'll use this to search as if it was used in the
header itself.

[ex1]: examples/example1.png
[ex2]: examples/example2.png
[ex3]: examples/example3.png
[ex4]: examples/example4.png
[ex5]: examples/example5.png
[typst]: https://github.com/typst/typst
