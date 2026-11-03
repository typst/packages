Trompet is a package for drawing [Tromp lambda diagrams](https://tromp.github.io/cl/diagrams.html), a representation of lambda calculus expressions, built on top of [Lambdabus](https://typst.app/universe/package/lambdabus/).

## Examples

<table>
<tr>
<td>
    <a href="example/example1.typ">
        <img src="example/example1.png" alt="Many colored Tromp diagrams showing the normalization process of the factorial of 2" title="Colorful Factorial Reduction"/>
    </a>
</td>
<td>
    <a href="example/example2.typ">
        <img src="example/example2.png" alt="A Tromp diagram of the Church numeral 3 with blue labels" title="Three"/>
    </a>
</td>
</tr>
</table>

## Usage

For more information, check the [manual](doc/manual.pdf).

To use this package, simply add the following code to your document:

```typ
#import "@preview/trompet:0.1.0": *

#tromp("\\f.\\n.f (f (f n))")
```
