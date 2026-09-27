# Zap for Typst

**Zap** ⚡ is a Typst package that makes drawing electronic circuits simple and intuitive 💥. It's the first circuit library inspired by widely recognized standards 🧷 like **IEC** and **IEEE/ANSI**. Unlike circuitikz in LaTeX (2007), its design philosophy balances ease of use with powerful customization, avoiding any awkward syntax.

[Repository](https://codeberg.org/grangelouis/zap) – [Documentation](https://zap.grangelouis.ch) – [Examples](https://codeberg.org/grangelouis/zap/src/branch/main/examples)

## Examples

You can find the full list of examples [here](https://codeberg.org/grangelouis/zap/src/branch/main/examples).

### Operational amplifier

![Operational amplifier example](https://codeberg.org/grangelouis/zap/raw/branch/main/examples/example1.svg)

### MicroController Unit
 
![MicroController Unit example](https://codeberg.org/grangelouis/zap/raw/branch/main/examples/example2.svg)

### Logic circuit

![Logic circuit example](https://codeberg.org/grangelouis/zap/raw/branch/main/examples/example3.svg)

## Quick usage

```typst
#import "@preview/zap:0.6.0"

#zap.circuit({
    import zap: *
    
    // Here is a minimalist example
    node("B", (0, 0))
    resistor("r1", "B", (rel: (0, 4)), i: $i_1$)
})
```

## Online documentation

You can find the full documentation 📚 [available online](https://zap.grangelouis.ch). It provides comprehensive guides, a detailed list of components, styling options, and example codes to get you started easily.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining Zap takes time and love. If you'd like to help, check out the [contribution procedure](https://codeberg.org/grangelouis/zap/src/branch/main/CONTRIBUTING.md) and join the journey 🤩!

## Legal disclaimer

This project is an independent, open-source library licensed under [MIT](https://codeberg.org/grangelouis/zap/src/branch/main/LICENSE) with symbols generated algorithmically from scratch. While inspired by international conventions (IEC, IEEE) for compatibility, Zap is **not affiliated with or certified by** any standards body. These are stylistic approximations for illustration. For safety-critical or regulatory compliance, please consult official standards and [create custom symbols](https://zap.grangelouis.ch/#custom).