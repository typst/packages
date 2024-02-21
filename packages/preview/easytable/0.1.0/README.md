# Typst Easytable Package

A Typst library for writing simple tables.

## Usage

**WARNING: This library is not in `preview` namespace.**

```typst
#import "@preview/easytable:0.1.0": easytable, elem
#import elem: *
```

## Manual

See [manual](./manual.pdf).

## Examples

### A Simple Table

```typst
#easytable({
  th[Header 1 ][Header 2][Header 3  ]
  td[How      ][I       ][want      ]
  td[a        ][drink,  ][alcoholic ]
  td[of       ][course, ][after     ]
  td[the      ][heavy   ][lectures  ]
  td[involving][quantum ][mechanics.]
})
```

![image](https://github.com/monaqa/typst-easytable/assets/48883418/690b466b-56d9-4660-8ca5-25cc25e379f9)

### Setting Column Alignment and Width

```typst
#easytable({
  cwidth(100pt, 1fr, 20%)
  cstyle(left, center, right)
  th[Header 1 ][Header 2][Header 3  ]
  td[How      ][I       ][want      ]
  td[a        ][drink,  ][alcoholic ]
  td[of       ][course, ][after     ]
  td[the      ][heavy   ][lectures  ]
  td[involving][quantum ][mechanics.]
})
```

![image](https://github.com/monaqa/typst-easytable/assets/48883418/8ff574b4-bf1f-46ca-8a2d-584ab701a989)

### Customizing Styles

```typst
#easytable({
  let td = td.with(trans: pad.with(x: 3pt))

  th[Header 1][Header 2][Header 3]
  td[How][I][want]
  td[a][drink,][alcoholic]
  td[of][course,][after]
  td[the][heavy][lectures]
  td[involving][quantum][mechanics.]
})
```

![image](https://github.com/monaqa/typst-easytable/assets/48883418/8a1ed0d0-4a9e-4a28-a0ff-b8f7a09cb8a8)

```typst
#easytable({
  let th = th.with(trans: emph)
  let td = td.with(
    cell_style: (x: none, y: none)
      => (fill: if calc.even(y) {
        luma(95%)
      } else {
        none
      })
  )

  th[Header 1][Header 2][Header 3]
  td[How][I][want]
  td[a][drink,][alcoholic]
  td[of][course,][after]
  td[the][heavy][lectures]
  td[involving][quantum][mechanics.]
})
```

![image](https://github.com/monaqa/typst-easytable/assets/48883418/5f8bf796-b2bd-41c4-a79e-fd97c2824ecd)


```typst
#easytable({
  th[Header 1][Header 2][Header 3]
  td[How][I][want]
  hline(stroke: red)
  td[a][drink,][alcoholic]
  td[of][course,][after]
  td[the][heavy][lectures]
  td[involving][quantum][mechanics.]

  // Specifying the insertion point directly
  hline(stroke: 2pt + green, y: 4)
  vline(
    stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
    x: 2,
    start: 1,
    end: 5,
  )
})
```

![image](https://github.com/monaqa/typst-easytable/assets/48883418/cf400dad-a7fc-4f3a-991d-9611adab41c6)
