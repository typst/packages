<h1 align="center">
  <img alt="Quantum Circuit" src="https://github.com/Mc-Zen/packages/assets/52877387/5d34c646-79a8-492b-8e49-9136d5881258" style="max-width: 100%; width: 300pt; padding: 10px 20px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; box-sizing: border-box; background: white">
</h1>


**Quill** is a package for
 creating quantum circuit diagrams in [Typst](https://typst.app/). 


_Note, that this package is in beta and may still be undergoing breaking changes. As new features like data types and scoped functions will be added to Typst, this package will be adapted to profit from the new paradigms._

_Meanwhile, we suggest importing everything from the package in a local scope to avoid polluting the global namespace (see example below)._


## Usage

Create circuit diagrams by calling the function `quantum-circuit()` with any number of positional arguments — just like the built-in Typst functions `table()` or `grid()`. A variety of different gate and instruction commands are available and plain numbers can be used to produce any number of empty cells just filled with the current wire mode. A new wire is started by adding the content item `[\ ]`. 

```java
#{
  import "@preview/quill:0.1.0": *
  quantum-circuit(
    lstick($|0〉$), gate($H$), ctrl(1), rstick($(|00〉+|11〉)/√2$, n: 2), [\ ],
    lstick($|0〉$), 1, targ(), 1
  )
}
```

<h3 align="center">
  <img alt="Bell circuit" src="https://github.com/Mc-Zen/packages/assets/52877387/0132e357-abeb-42b2-8b27-073e3d8b8063" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; background: white; box-sizing: border-box">
</h3>

Refer to the [user guide](https://github.com/Mc-Zen/quill/releases/download/v0.1.0/quill-guide.pdf) for full documentation.

## Gallery

<h3 align="center">
  <img alt="Gallery" src="https://github.com/Mc-Zen/packages/assets/52877387/fb9d887d-fab2-48dd-b5cb-02e120b76f30" style="background: white; padding: 10pt; box-sizing: border-box" />
</h3>

## Examples

Some show-off examples, loosely replicating figures from [Quantum Computation and Quantum Information by M. Nielsen and I. Chuang](https://www.cambridge.org/highereducation/books/quantum-computation-and-quantum-information/01E10196D0A682A6AEFFEA52D53BE9AE#overview).

<h3 align="center">
  <img alt="Quantum teleportation circuit" src="https://github.com/Mc-Zen/packages/assets/52877387/c923c68a-63b2-4377-a362-dfa06ffe66f4" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; background: white; box-sizing: border-box">
</h3>
<h3 align="center">
  <img alt="Quantum circuit for phase estimation" src="https://github.com/Mc-Zen/packages/assets/52877387/a875ac6f-9735-4136-96c0-99447a50695a" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; background: white; box-sizing: border-box">
</h3>
<h3 align="center">
  <img alt="Quantum fourier transformation circuit" src="https://github.com/Mc-Zen/packages/assets/52877387/a30ef089-e120-42bd-a698-dd6727d67e3c" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; background: white; box-sizing: border-box">
</h3>
