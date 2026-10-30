# Examples

English | [Português](README.pt-BR.md)

Run commands from the package folder. The Portuguese
examples share synthetic pages 1 and 2. The English example uses a small independent
scene demonstrating translated commands and options.

All scenes and editorial notes in this directory are synthetic examples.

| Output | PDF | Source |
| --- | --- | --- |
| English API, editorial view | [english.pdf](english.pdf) | [example-english.typ](example-english.typ) |
| English API, script view | [english-script.pdf](english-script.pdf) | [example-english.typ](example-english.typ), `mode=script` |
| English API, layout view | [english-layout.pdf](english-layout.pdf) | [example-english.typ](example-english.typ), `mode=layout` |
| English API, production view | [english-production.pdf](english-production.pdf) | [example-english.typ](example-english.typ), `mode=production` |
| Reading script | [roteiro.pdf](roteiro.pdf) | [exemplo-completo.typ](exemplo-completo.typ), `modo=roteiro` |
| Editorial draft | [editorial.pdf](editorial.pdf) | [exemplo-completo.typ](exemplo-completo.typ) |
| Editorial draft, open notes | [pendencias.pdf](pendencias.pdf) | [exemplo-completo.typ](exemplo-completo.typ), `modo=editorial`, `notas=abertas` |
| Geometric layout | [esquema.pdf](esquema.pdf) | [exemplo-esquema.typ](exemplo-esquema.typ) |
| Art production | [producao.pdf](producao.pdf) | [exemplo-producao.typ](exemplo-producao.typ) |
| Reports | [relatorios.pdf](relatorios.pdf) | [exemplo-relatorios.typ](exemplo-relatorios.typ) |
| Minimal script | [minimo.pdf](minimo.pdf) | [exemplo-minimo.typ](exemplo-minimo.typ) |

The report PDF has five sections: narrative map, pending notes, all dialogues,
Sam's dialogues, and text counts. `pendencias.pdf` is a full editorial script
with open notes; the pending-notes report contains only those notes.

```sh
typst compile --root . examples/example-english.typ examples/english.pdf
typst compile --root . examples/example-english.typ examples/english-layout.pdf --input mode=layout
typst compile --root . examples/exemplo-completo.typ examples/editorial.pdf --input modo=editorial
typst compile --root . examples/exemplo-esquema.typ examples/esquema.pdf
typst compile --root . examples/exemplo-producao.typ examples/producao.pdf
typst compile --root . examples/exemplo-relatorios.typ examples/relatorios.pdf
```

English aliases do not translate the PDF interface. Printed labels remain
Portuguese. See the [user guide](../docs/manual.md) and [API reference](../docs/api.md).
