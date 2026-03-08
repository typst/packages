![](https://badgers.space/github/release/l0uisgrange/zap?theme=tailwind)
![](https://badgers.space/github/checks/l0uisgrange/zap?theme=tailwind)
![](https://badgers.space/github/contributors/l0uisgrange/zap?theme=tailwind)
![](https://badgers.space/github/open-issues/l0uisgrange/zap?theme=tailwind)

# ⚡️ Zap for Typst

**Zap** is a lightweight 🪶 Typst package that makes drawing electronic circuits simple and intuitive. It's the first Typst library designed to align with widely recognized standards like **IEC** and **IEEE/ANSI** 📜.

[Documentation](https://l0uisgrange.github.io/zap/) — [Examples](https://l0uisgrange.github.io/zap/examples) — [Forum](https://github.com/l0uisgrange/zap/discussions/categories/q-a)

## Simple examples

You can find the full list of examples [here](https://l0uisgrange.github.io/zap/examples).

<table>
<tr>
  <td>
    <img alt="Example 1" src="https://github.com/l0uisgrange/zap/blob/21f34b7cebb3c59629d7a5c1b02b9a6db60e8f8e/examples/example1.png?raw=true" width="250px">
  </td>
  <td>
    <img alt="Example 2" src="https://github.com/l0uisgrange/zap/blob/21f34b7cebb3c59629d7a5c1b02b9a6db60e8f8e/examples/example2.png?raw=true" width="250px">
  </td>
</tr>
<tr>
  <td>Simple example</td>
  <td>Wheatstone bridge</td>
</tr>
</table>


## Quick usage

```typst
#import "@preview/zap:0.2.1"

#zap.canvas({
    import zap: *

    isource("i1", (0,0), (5,0))
    resistor("r1", (5,5), (0,5))
    wire("r1.out", "i1.out")
})
```

## Online documentation

You can find the full documentation 📚 [available online](https://l0uisgrange.github.io/zap/). It provides comprehensive guides, a detailed list of components, full API references, and example codes to get you started easily.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining Zap takes time and love. If you'd like to help, check out the [contribution procedure](https://github.com/l0uisgrange/zap/blob/main/CONTRIBUTING.md) and join the journey 🤩!
