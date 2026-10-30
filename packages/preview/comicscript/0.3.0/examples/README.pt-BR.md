# Exemplos de saída

[English](README.md) | Português

Todos os exemplos usam o pacote local. Esquema, produção e relatórios importam
as mesmas páginas fictícias 1 e 2 utilizadas no exemplo completo.

| Saída | O que mostra | PDF | Fonte |
| --- | --- | --- | --- |
| API em inglês | Exemplo dos comandos e parâmetros em inglês | [english.pdf](english.pdf) | [example-english.typ](example-english.typ) |
| Roteiro | Descrições, composição, referências e textos | [roteiro.pdf](roteiro.pdf) | [exemplo-completo.typ](exemplo-completo.typ), com `modo=roteiro` |
| Editorial | Roteiro com objetivos, estados, IDs, notas e avisos | [editorial.pdf](editorial.pdf) | [exemplo-completo.typ](exemplo-completo.typ) |
| Editorial: abertas | Mesmo roteiro, com notas abertas | [pendencias.pdf](pendencias.pdf) | [exemplo-completo.typ](exemplo-completo.typ), com `modo=editorial` e `notas=abertas` |
| Esquema | Composição geométrica e proporções dos quadrinhos | [esquema.pdf](esquema.pdf) | [exemplo-esquema.typ](exemplo-esquema.typ) |
| Produção | Orientações para desenhar, com notas técnicas selecionadas | [producao.pdf](producao.pdf) | [exemplo-producao.typ](exemplo-producao.typ) |
| Relatórios | Mapa, pendências, diálogos, diálogos de Sam e contagem de palavras | [relatorios.pdf](relatorios.pdf) | [exemplo-relatorios.typ](exemplo-relatorios.typ) |
| Mínimo | Uma página sem metadados opcionais | [minimo.pdf](minimo.pdf) | [exemplo-minimo.typ](exemplo-minimo.typ) |

No PDF de relatórios, as cinco folhas correspondem respectivamente a mapa,
pendências, diálogos de todos, diálogos de Sam e contagem de palavras.
O relatório de pendências contém somente as notas abertas; o PDF
`pendencias.pdf` contém o roteiro completo com esse mesmo filtro de notas.

Compile a partir de a pasta do pacote, por exemplo:

```sh
typst compile --root . examples/exemplo-esquema.typ examples/esquema.pdf
typst compile --root . examples/exemplo-producao.typ examples/producao.pdf
typst compile --root . examples/exemplo-relatorios.typ examples/relatorios.pdf
```
