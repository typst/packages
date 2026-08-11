# Zap for Typst

**Zap** ⚡ is a Typst package that makes drawing electronic circuits simple and intuitive 💥. It's the first circuit library inspired by widely recognized standards 🧷 like **IEC** and **IEEE/ANSI**. Unlike circuitikz in LaTeX (2007), its design philosophy balances ease of use with powerful customization, avoiding any awkward syntax.

[Documentation](https://zap.grangelouis.ch) — [Examples](https://zap.grangelouis.ch/examples) — [Forum](https://github.com/l0uisgrange/zap/discussions/categories/q-a)

## Examples

You can find the full list of examples [here](https://zap.grangelouis.ch/examples).

### Operational amplifier

![Operational amplifier example](https://github.com/l0uisgrange/zap/blob/main/examples/example1.svg?raw=true)

### MicroController Unit
 
![MicroController Unit example](https://github.com/l0uisgrange/zap/blob/main/examples/example2.svg?raw=true)

### Logic circuit

![Logic circuit example](https://github.com/l0uisgrange/zap/blob/main/examples/example3.svg?raw=true)

## Quick usage

```typst
#import "@preview/zap:0.5.0"

#zap.circuit({
    import zap: *
    
    // Here is a minimalist example
    node("B", (0, 0))
    resistor("r1", "B", (rel: (0, 4)), i: $i_1$)
})
```

## Online documentation

You can find the full documentation 📚 [available online](https://zap.grangelouis.ch). It provides comprehensive guides, a detailed list of components, styling options and example codes to get you started easily.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining Zap takes time and love. If you'd like to help, check out the [contribution procedure](https://github.com/l0uisgrange/zap/blob/main/CONTRIBUTING.md) and join the journey 🤩!


