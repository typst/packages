Modelos de trabalhos acadêmicos em [Typst](https://typst.app) (com case, paper e projeto de pesquisa) seguindo as normas ABNT, inspirado no [Abntyp](https://typst.app/universe/package/abntyp/)

---

## Estrutura

```
facsur-typst/
├── src/
│   ├── core.typ        # Página, texto, parágrafo e títulos
│   ├── elements.typ    # Capa, folha de rosto, sumário, rodapé, alíneas
│   ├── citation.typ    # Citação longa, idem e seção de referências
│   └── templates.typ   # Templates completos: projeto, paper e case
│
└── exemplos/
    ├── projeto.typ     # Projeto de pesquisa
    ├── paper.typ       # Artigo científico
    └── case.typ        # Relatório parcial (case)
```

---

## Pré-requisitos

- [Typst](https://typst.app) instalado; 
- Fonte **Arial** ou **Times New Roman** instalada no sistema.

---

## Como compilar

```bash
typst compile exemplos/paper.typ
typst compile exemplos/projeto.typ
typst compile exemplos/case.typ
```

Para compilar com recarga automática ao salvar:

```bash
typst watch exemplos/paper.typ
```

---

## Como criar um novo documento

Copie o exemplo correspondente ao tipo de documento desejado e edite os metadados no topo:

```typst
#import "../src/templates.typ": template-paper
#import "../src/citation.typ": citacao-longa, idem, referencias

#show: template-paper.with(
  titulo: "SEU TÍTULO:",
  subtitulo: "seu subtítulo, se houver",
  autor: "Seu Nome",
  nota-autor: "Acadêmico do curso de Direito – FACSUR.",
  email-autor: "seu@email.com",
  orientador: "Prof. Me. Nome do Orientador",
  nota-orientador: "Professor da Faculdade Supremo Redentor – FACSUR.",
  email-orientador: "orientador@facsur.com.br",
  resumo: [Seu resumo aqui.],
  palavras-chave: "Palavra. Palavra. Palavra.",
)

= INTRODUÇÃO

Seu texto aqui.
```

---

## Referência dos módulos

### `src/core.typ`

Configura página, texto e parágrafos globalmente, e define a formatação de títulos conforme ABNT. Deve ser ativado via `#show: configurar.with(...)`.

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `numeracao` | `"1"` | Formato da numeração de página |
| `pagina-inicial` | `none` | Número da primeira página do corpo |

### `src/elements.typ`

Funções para elementos pré-textuais e configurações de listas.

| Função | Descrição |
|---|---|
| `capa(...)` | Capa padrão FACSUR |
| `folha-de-rosto(...)` | Folha de rosto com bloco de natureza |
| `sumario()` | Sumário automático |
| `configurar-rodape` | Notas de rodapé em 10pt, espaço simples |
| `configurar-alineas` | Listas no formato `a)`, `b)`, `c)` |

### `src/citation.typ`

| Função/variável | Descrição |
|---|---|
| `idem` | Substitui autor repetido nas referências (`______`) |
| `citacao-longa(corpo)` | Bloco de citação direta longa (recuo 4 cm, 10pt) |
| `referencias(conteudo)` | Seção de referências com quebra de página e tipografia ABNT |

### `src/templates.typ`

| Template | Uso |
|---|---|
| `template-projeto` | Projeto de pesquisa com capa, folha de rosto e sumário |
| `template-paper`   | Artigo científico com título, autores e resumo         |
| `template-case`    | Relatório parcial (case) com título e identificação    |
