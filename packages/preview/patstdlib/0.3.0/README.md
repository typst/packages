<h1 align='center'>patstdlib</h1>

Some standard pieces I find useful: fonts, subfigures, algorithms, labeled enums, etc.

## Documentation

Please see the inline documentation attached to each object. A full list of all available functionality can be found in [`src/lib.typ`](https://github.com/patrick-kidger/patstdlib/blob/main/src/lib.typ).

## Functionality

Here's a few highlights:

**Labeled enums**

```typst
#show: enable-referable-enums

#referable-enum("step")[
  + Foo
  + Bar
  + Baz <step:baz>
]

In @step:baz then ...
// Renders as 'In step 3 then ...'
```

**Subfigures**

```typst
#show: enable-referable-subfigures
#set enum(full: true)

#figure(
  caption: [Main caption],
  grid(
    columns: 2,
    subfigure(
      caption: [Caption for subfigure '(a)'],
      image(...)
    ),
    subfigure(
      caption: [Caption for subfigure '(b)'],
      image(...)
    ),
  )
)
```

**Significant figures**

```typst
#sigfig(3.141592653, digits: 3)  // 3.14 as a `decimal`
```
