# pequi-ic-ufg

Modelo **não oficial** de Relatório Final de Iniciação Científica (IC) da
Universidade Federal de Goiás (UFG), feito em [Typst](https://typst.app).

## Uso

No web app, clique em *Start from template* e procure por `pequi-ic-ufg`.
Pela linha de comando:

```sh
typst init @preview/pequi-ic-ufg
```

Ou, em um documento existente:

```typst
#import "@preview/pequi-ic-ufg:0.1.0": *

#show: report.with(
  title: "Título do relatório",
  authors: (
    (name: "Autor(a) A", email: "estudante@discente.ufg.br", affiliation: "Unidade Acadêmica", role: "Estudante"),
    (name: "Autor(a) B", email: "orientador@ufg.br", affiliation: "Unidade Acadêmica", role: "Orientador(a)"),
  ),
  font: none
)

= Resumo
...

// Apêndices
#show: appendix
= Textos
```

## Parâmetros de `report`

| Parâmetro | Descrição |
| --- | --- |
| `title` | Título do relatório. |
| `authors` | Lista de autores, cada um com `name`, `email`, `affiliation` e `role`. |
| `font` | Fonte do texto. Padrão: `("Arial", "Liberation Sans")`. |

## Fonte Arial

A Arial é proprietária e **não** é distribuída com este pacote. Se ela não estiver
instalada, o Typst usa a Liberation Sans (métricas equivalentes) e pode exibir o
aviso `unknown font family: arial`. Para silenciá-lo, passe `font: "Liberation Sans"`
ou instale a Arial e use `typst compile --font-path <pasta> main.typ`.

## Dependências

O exemplo usa [`codly`](https://typst.app/universe/package/codly) para blocos de código.

## Licenças

- Código do template: MIT-0 (arquivo `LICENSE`).
- `template/references/sbc.csl`: estilo CSL "Sociedade Brasileira de Computação",
  de Maurício de Paulo, sob [CC BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/).
