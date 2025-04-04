# ucpc-solutions Documentation

ucpc-solutions is not rich in default style definitions. This is because the style definitions in the original LaTeX version of ucpc-solutions were like that, and many contest organizers interpreted and modified the overall style definitions of the template to create their own uniquely styled documents.

This ucpc-solutions also respects that meta, specifying a minimum of basic style definitions and providing various customizable document creation utilities.  

So, unlike other typst templates that create a document, you still need to use a utility function that provides styling.

For example, if you create a cover page from a general template as follows:

```typst
#import "<template.typ>": *
#show: <template>.with()
= Document Title
```

ucpc-solutions requires calling a somewhat complex function.

```typst
#import "@preview/ucpc-solutions:0.1.0" as ucpc

#ucpc.utils.make-hero(
  title: [Document Title]
)
```

One advantage of this approach is that if you don't like the creation utility provided by ucpc-solutions, you can define your own styles and use them.

```typst
#show ucpc.ucpc.with(
  title: "2024 GIST Algorithm Masters",
  hero: [
    // Title Page
    #set page(margin: 0%)
    #rect(fill: secondary_color, width: 100%, height: 70%, outset: 0%)[
      #align(horizon)[
        #rect(fill: none, stroke: none, inset: (left: 5em), outset: 0%)[
          #text(fill: rgb("#fff"), size: 32pt)[= #text(fill: rgb("#ff3e29"))[G]IST \ ALGORITHM \ MASTERS]
          
          #text(fill: rgb("#fff"), size: 20pt)[2024 Contest\
          Official Solutions Editorial]
        ]
      ]
    ]
    #align(center + horizon)[
      #text(fill: secondary_color)[
        #text(size: 2em)[GIST Algorithm Masters TF]
        \
      ]
    ]
  ],
)
```

## Definitions
- [ucpc.ucpc](#)
- [ucpc.colors](./colors.md)
- [ucpc.i18n](./i18n.md)
- [ucpc.presets](./presets.md)
- [ucpc.utils](./utils.md)
