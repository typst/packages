# Bone for Typst

**Bone** 🦴 is a package to draw structural analysis and kinematic diagrams 🦾 in Typst. It is inspired from the LaTeX package `stanli` by [Jürgen Hackl](https://github.com/hackl/TikZ-StructuralAnalysis). It is driven by simplicity and easy-of-use.

[Documentation](https://bone.grangelouis.ch)

## Examples

A very simple example of the package's capabilities.

### Beams with distributed force

![Distributed force example](https://codeberg.org/grangelouis/bone/raw/commit/f4b613ba38b203e0853398022d9074372ad21d0d/examples/example1.svg)

## Quick usage

```typst
#import "@preview/bone:0.1.0"

#bone.diagram({
    import bone: *
    
    // Here is a minimalist example
    cardan("c1", (0, 0))
})
```

## Online documentation

You can find the full documentation 📚 [available online](https://bone.grangelouis.ch). It provides comprehensive guides, a detailed list of components, styling options and example codes to get you started easily.

## Contributing

I highly welcome contributions 🌱! Creating and maintaining this package takes time and love. If you'd like to help, check out the [contribution procedure](https://codeberg.org/grangelouis/bone/src/branch/main/CONTRIBUTING.md) and join the journey 🤩!
