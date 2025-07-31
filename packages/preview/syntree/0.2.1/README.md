# typst-syntree

**syntree** is a typst package for rendering syntax trees / parse trees (the kind linguists use).

The name and syntax are inspired by Miles Shang's [syntree](https://github.com/mshang/syntree). Here's an example to get started:

<table>
<tr>
<td>

```typ
#import "@preview/syntree:0.2.0": syntree

#syntree(
  nonterminal: (font: "Linux Biolinum"),
  terminal: (fill: blue),
  child-spacing: 3em, // default 1em
  layer-spacing: 2em, // default 2.3em
  "[S [NP This] [VP [V is] [^NP a wug]]]"
)
```

</td>
<td>

![Output tree for "This is a wug"](https://github.com/lynn/typst-syntree/assets/16232127/d0c680b2-4fd0-420f-b350-9e9c96ac37f3)

</td>
</tr>
</table>


There's limited support for formulas inside nodes; try `#syntree("[DP$zws_i$ this]")` or `#syntree("[C $diameter$]")`.

For more flexible tree-drawing, use `tree`:

<table>
<tr>
<td>

```typ
#import "@preview/syntree:0.2.0": tree

#let bx(col) = box(fill: col, width: 1em, height: 1em)
#tree("colors",
  tree("warm", bx(red), bx(orange)),
  tree("cool", bx(blue), bx(teal)))
```

</td>
<td>

![Output tree of colors](https://github.com/lynn/typst-syntree/assets/16232127/bc979614-e2ce-4616-97d1-1584788fc71f)

</td>
</tr>
</table>
