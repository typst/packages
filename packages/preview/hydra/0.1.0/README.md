# hydra
Hydra is a [typst] package allowing you to easily display the current section anywhere in your
document. By default, it will assume that it is used in the header of your document and display
the last heading if and only if it is numbered and the next heading is not the first on the current
page.

By default hydra also assumes that you use `a4` page size, see the FAQ if you use different page
size or margins.

## Note on API
The current API is subject to change in the next version when new features for general handling of
headings is added.

## Example
```typst
#import "@preview/hydra:0.1.0": hydra

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

## Non-default behavior
Changing the default behavior can be done using its keyword arguments:
```typst
#let hydra(
  sel: heading,                     // the elements to consider
  getter: default.get-adjacent,     // gets the neighboring elements according to sel
  prev-filter: default.prev-filter, // checks if the last element is valid
  next-filter: default.next-filter, // checks if the next element is valid
  display: default.display,         // displays the last element
  resolve: default.resolve,         // contains the glue code combining the other given args
  is-footer: false,                 // whether this is used from a footer
) = {
  ...
}
```
These functions generally take a queried element and sometimes the current location, see the source
for more info. The defaults assume only headings and fail if another element type is provided.

The `sel` argument can be an element function or selector, or either an array containing either
of those and an addiitonal filter function. The additional filter function is applied before the
adjacent arguments are selected from the result of the queries.

### Configuring filter and display
By default hydra will display `[#numbering #body]` of the heading and this reject unnumbered
ones. This filtering can be configured using `prev-filter` and `next-filter`.
```typst
#set page(header: hydra(prev-filter: (_, _) => true))
```

Keep in mind that `next-filter` is also responsible for checking that the next heading is on the
current page.

### In the footer
To use the hydra functon in the footer of your doc, pass `is-footer: true` and place a
`#metadata(()) <hydra>` somewhere in your header, or before your headings. Hydra will use the
location of this label to search for the correct headings instead of searching from the footer.

```typst
#set page(header: [#metadata(()) <hydra>], footer: hydra(is-footer: true))
```

Using it outside of footer or header should work as expected.

### Different heading levels or custom heading types
If you use a `figure`-based element for special 0-level chapters or you wish to only consider
specific levels of headings, pass the appropriate selector.

```typst
// only consider level 1
#set page(header: hydra(sel: heading.where(level: 1)))

// only consider level 1 - 3
#set page(header: hydra(sel: (heading, (h, _) => h.level <= 3)))

// consider also figures with this kind, must likely override all default functions other than
// resolve, or resolve directly, see source
#set page(header: hydra(sel: figure.where(kind: "chapter").or(heading), display: ...)
```

In short, `sel` can be a selector, or a selector and a filter function. When using anything other
than headings only, consider setting `display` too.

## FAQ
**Q:** Why does hydra display the previous heading if there is a heading at the top of my page?

**A:** If you use non `a4` page margins make sure to pass
`next-filter: default.next-filter.with(top-margin: ...)`. This margin must be known for the default
implementation. If it does but you are using `a4`, then you found a bug.

[ex1]: examples/example1.png
[ex2]: examples/example2.png
[ex3]: examples/example3.png
[ex4]: examples/example4.png
[ex5]: examples/example5.png
[typst]: https://github.com/typst/typst
