# uepg-tcc-unofficial

An unofficial [Typst](https://typst.app) template for monographs (undergraduate thesis) at Universidade Estadual de Ponta Grossa (UEPG), Brazil. It follows the ABNT (Brazilian Association of Technical Standards) formatting rules as specified in NBR 14724, including cover page, title page, abstract, table of contents, and all required pre-textual elements.

Template [Typst](https://typst.app) para monografias da Universidade Estadual de Ponta Grossa (UEPG), seguindo as normas da ABNT (NBR 14724).

## Uso

```bash
typst init @preview/uepg-tcc-unofficial
```

Ou importe diretamente no seu documento:

```typst
#import "@preview/uepg-tcc-unofficial:0.1.0": monografia, citacao-longa

#show: monografia.with(
  titulo: "TÍTULO DO TRABALHO",
  autor: "NOME DO AUTOR",
  orientadores: ("Prof. Dr. Nome do Orientador",),
  nota-apresentacao: "Trabalho de Conclusão de Curso apresentado para obtenção do título de ...",
  curso: "BACHARELADO EM ...",
  departamento: "DEPARTAMENTO DE ...",
  ano: "2026",
  resumo: [Texto do resumo...],
  palavras-chave: ("Palavra 1", "Palavra 2"),
  abstract: [Abstract text...],
  keywords: ("Keyword 1", "Keyword 2"),
)

= Introdução

Seu conteúdo aqui...

#bibliography("refs.bib", title: "REFERÊNCIAS", style: "associacao-brasileira-de-normas-tecnicas")
```

## Parâmetros

### Obrigatórios

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `titulo` | `str` | Título do trabalho |
| `autor` | `str` | Nome do autor |
| `orientadores` | `array` | Lista de orientadores (primeiro = orientador, demais = coorientadores) |
| `nota-apresentacao` | `str` | Texto da nota de apresentação na folha de rosto |
| `curso` | `str` | Nome do curso |
| `departamento` | `str` | Nome do departamento |
| `ano` | `str` | Ano de apresentação |

### Opcionais

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `setor` | `str` | `"SETOR DE ENGENHARIAS, CIÊNCIAS AGRÁRIAS E TECNOLOGIA"` | Nome do setor |
| `local` | `str` | `"PONTA GROSSA"` | Cidade |
| `resumo` | `content` | `none` | Texto do resumo |
| `palavras-chave` | `array` | `()` | Lista de palavras-chave |
| `abstract` | `content` | `none` | Texto do abstract |
| `keywords` | `array` | `()` | Lista de keywords |
| `dedicatoria` | `content` | `none` | Texto da dedicatória |
| `agradecimentos` | `content` | `none` | Texto dos agradecimentos |
| `epigrafe` | `content` | `none` | Texto da epígrafe |
| `lista-abreviaturas` | `array` | `none` | Pares `(sigla, significado)` |
| `lista-ilustracoes` | `auto/bool` | `auto` | Controle da lista de ilustrações |
| `lista-quadros` | `auto/bool` | `auto` | Controle da lista de quadros |
| `lista-tabelas` | `auto/bool` | `auto` | Controle da lista de tabelas |
| `fonte-padrao` | `str` | `"O autor"` | Texto padrão de fonte em figuras/tabelas |

## Funções exportadas

### `citacao-longa`

Formata citações longas (mais de 3 linhas) conforme ABNT: recuo de 4cm, fonte 10pt, espaçamento simples.

```typst
#citacao-longa[
  Texto da citação longa aqui...
]
```

## Quadros

Para criar quadros (informações qualitativas, bordas fechadas), use `kind: "quadro"`:

```typst
#figure(
  table(
    columns: (auto, auto),
    stroke: 1pt + black,
    inset: 10pt,
    table.header([*Coluna 1*], [*Coluna 2*]),
    [Dado 1], [Dado 2],
  ),
  caption: [Título do quadro],
  kind: "quadro",
  supplement: [Quadro],
) <quadro-label>
```

## Conformidade ABNT

- Papel A4 (21cm x 29,7cm)
- Margens: superior 3cm, inferior 2cm, esquerda 3cm, direita 2cm
- Fonte: Times New Roman 12pt (com fallback para TeX Gyre Termes e Liberation Serif)
- Espaçamento entre linhas: 1,5
- Recuo de primeira linha: 1,25cm
- Citações longas: recuo 4cm, fonte 10pt, espaçamento simples
- Legendas e fontes: 10pt
- Notas de rodapé: 10pt, espaçamento simples
- Numeração de páginas: canto superior direito
- Seções de nível 1: negrito, caixa alta
- Elementos pré-textuais na ordem correta conforme NBR 14724

## Licença

MIT
