Pedigrypst is a package for drawing [pedigrees](https://en.wikipedia.org/wiki/Pedigree_chart).

## Examples

<table>
<tr>
<td>
    <a href="example/example1.typ">
        <img src="example/example1.png" alt="A pedigree showing six generations with two consanguineous, cross-generation unions." title="Consanguinuity"/>
    </a>
</td>
<td>
    <a href="example/example2.typ">
        <img src="example/example2.png" alt="A pedigree showing the relationship described in the song 'I'm My Own Grandpa' by Dwight Latham and Moe Jaffe." title="I'm My Own Grandpa"/>
    </a>
</td>
</tr>
</table>

## Usage

For information, check the [manual](docs/manual.pdf).

To use this package, simply add the following code to your document:

```typ
#import "@preview/pedigrypst:0.1.0" as pedigrypst: pedigree

#pedigree({
  import pedigrypst: *
  // Pedigree data here
  individual(1, 1, "male")
})
```
