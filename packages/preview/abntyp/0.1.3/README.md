# ABNTyp

**ABNTyp — Base Normativa Typst** — Formatação de documentos técnicos e científicos brasileiros conforme normas ABNT para [Typst](https://typst.app).

---

## Sobre o Projeto

O **ABNTyp** é um pacote Typst para formatação de documentos acadêmicos e técnicos em conformidade com as normas da ABNT (Associação Brasileira de Normas Técnicas).

Este projeto está sendo escrito via Claude Code a partir das minhas orientações, fruto da experiência que tive com LaTeX, que começou na USP de São Carlos em 2000, por influência
principalmente do Prof. Dr. Sadao Massago. Também neste período e local pude conhecer o Prof. Dr. Miguel Vinicius Santini Frasson, um dos criadores do abnTeX original, bem como o famoso texto "Uma introdução ao LaTeX 2e" do Prof. Dr. Lenimar Nunes Andrade. Anos mais tarde, tive contato com o excelente abnTeX2, do Prof. Dr. Lauro César Araujo. Todo o mérito deste projeto, portanto, deve ir para as pessoas e projetos citados acima, bem como criadores e comunidades do LaTeX e do Typst.

O objetivo aqui é adaptar o projeto abnTeX2 para o caso do Typst, para servir como base na disciplina "Software Livre para Edição de Textos Matemáticos" em 2026 (Núcleo Livre). A parte de matemática, caixas decorativas e ambientes de teoremas — adaptada do trabalho do Prof. Lenimar — está no pacote companheiro **[FerrMat](https://github.com/3sdras/ferrmat)**.

---

## Instalação

### Via Typst Universe (recomendado)

```typst
#import "@preview/abntyp:0.1.3": *
```

### Via Clone Local

```bash
git clone https://github.com/3sdras/abntyp.git
```

```typst
#import "caminho/para/abntyp/lib.typ": *
```

---

## Documentação

A documentação do ABNTyp consiste nos seguintes arquivos:

### Manuais

| Arquivo                | Descrição                           |
| ---------------------- | ----------------------------------- |
| `docs/manual.typ`      | Manual completo da classe e funções |
| `docs/guia-rapido.typ` | Guia rápido para começar            |

### Modelos Canônicos (Exemplos)

| Arquivo                                 | Tipo de Documento                           | Norma Principal |
| --------------------------------------- | ------------------------------------------- | --------------- |
| `examples/tcc-exemplo.typ`              | Trabalho acadêmico (tese, dissertação, TCC) | NBR 14724:2024  |
| `examples/artigo-exemplo.typ`           | Artigo científico                           | NBR 6022:2018   |
| `examples/relatorio-exemplo.typ`        | Relatório técnico                           | NBR 10719:2015  |
| `examples/projeto-exemplo.typ`          | Projeto de pesquisa                         | NBR 15287:2025  |
| `examples/livro-exemplo.typ`            | Livro                                       | NBR 6029:2023   |
| `examples/periodico-exemplo.typ`        | Publicação periódica                        | NBR 6021:2015   |
| `examples/poster-exemplo.typ`           | Pôster científico                           | NBR 15437:2006  |
| `examples/slides-defesa-exemplo.typ`    | Apresentação de slides                      | Boas práticas\* |
| `examples/citacao-numerica-exemplo.typ` | Sistema numérico de citações                | NBR 10520:2023  |

_\* A ABNT não possui norma específica para slides. O template segue boas práticas acadêmicas._

### Arquivos de Referência

| Arquivo                    | Descrição                             |
| -------------------------- | ------------------------------------- |
| `examples/referencias.bib` | Referências bibliográficas de exemplo |
| `src/references/abnt.csl`  | Estilo CSL para formatação ABNT       |

---

## Normas Implementadas

O ABNTyp implementa as seguintes normas ABNT (versões atualizadas):

### Normas Principais

| Norma     | Título                                    | Versão   |
| --------- | ----------------------------------------- | -------- |
| NBR 14724 | Trabalhos acadêmicos — Apresentação       | **2024** |
| NBR 6023  | Referências — Elaboração                  | **2018** |
| NBR 10520 | Citações em documentos — Apresentação     | **2023** |
| NBR 6024  | Numeração progressiva das seções          | 2012     |
| NBR 6027  | Sumário — Apresentação                    | 2012     |
| NBR 6028  | Resumo, resenha e recensão — Apresentação | **2021** |

### Normas para Tipos Específicos

| Norma     | Título                                                      | Versão   |
| --------- | ----------------------------------------------------------- | -------- |
| NBR 6022  | Artigo em publicação periódica técnica e/ou científica      | 2018     |
| NBR 6021  | Publicação periódica técnica e/ou científica — Apresentação | 2015     |
| NBR 6029  | Livros e folhetos — Apresentação                            | **2023** |
| NBR 10719 | Relatório técnico e/ou científico — Apresentação            | 2015     |
| NBR 15287 | Projeto de pesquisa — Apresentação                          | **2025** |
| NBR 15437 | Pôsteres técnicos e científicos — Apresentação              | 2006     |

### Normas Complementares

| Norma        | Título                                                     | Versão   |
| ------------ | ---------------------------------------------------------- | -------- |
| NBR 6032     | Abreviação de títulos de periódicos e publicações seriadas | 1989     |
| NBR 6033     | Ordem alfabética                                           | 1989     |
| NBR 6034     | Índice — Apresentação                                      | 2004     |
| NBR 6025     | Revisão de originais e provas                              | 2002     |
| NBR 12225    | Lombada — Apresentação                                     | 2004     |
| NBR 5892     | Representação de datas e horas                             | **2019** |
| NBR ISO 2108 | ISBN (Número Padrão Internacional de Livro)                | 2006     |
| NBR 10525    | ISSN (Número Padrão Internacional para Publicação Seriada) | 2005     |
| IBGE         | Normas de apresentação tabular                             | 1993     |

---

## Uso Rápido

### Trabalho Acadêmico (Tese/Dissertação/TCC)

```typst
#import "@preview/abntyp:0.1.3": *

// Metadados do trabalho — definidos uma única vez
#show: dados.with(
  titulo: "Uma proposta de pacote para normas ABNT em Typst",
  subtitulo: [Material didático para a disciplina \ Software Livre para Edição de Textos Matemáticos],
  autor: "Cláudio Código",
  instituicao: "Universidade Federal de Jataí",
  faculdade: "Instituto de Ciências Exatas e Tecnológicas",
  programa: "PROFMAT - Programa de Mestrado Profissional em Rede em Matemática",
  local: "Jataí",
  ano: 2026,
  natureza: "Dissertação",
  objetivo: "Obtenção do título de Mestre",
  orientador: "Prof. Dr. Esdras Teixeira Costa",
  palavras-chave: ("ABNT", "Typst", "formatação"),
  palavras-chave-en: ("ABNT", "Typst", "formatting"),
)

// Formatação ABNT (fonte, margens, headings, etc.)
#show: normasABNT.with(
  fonte: "Times New Roman",
  // arquivo-bibliografia: "referencias.bib",
)

// Elementos pré-textuais — dados vêm automaticamente
#capa()
#folha-rosto()
#resumo[Texto do resumo...]
#resumo-en[Abstract text...]
#sumario()

// Elementos textuais
= Introdução

Texto da introdução...

= Desenvolvimento

Texto do desenvolvimento...
```

### Artigo Científico

```typst
#import "@preview/abntyp:0.1.3": *

#show: artigo.with(
  titulo: "Título do Artigo",
  autores: (
    (name: "Autor Um", affiliation: "Universidade A", email: "autor1@exemplo.com"),
    (name: "Autor Dois", affiliation: "Universidade B", email: "autor2@exemplo.com"),
  ),
  resumo: [Resumo em português...],
  palavras-chave: ("palavra 1", "palavra 2"),
  resumo-en: [Abstract in English...],
  palavras-chave-en: ("keyword 1", "keyword 2"),
)

= Introdução

Texto do artigo...
```

---

## Sistemas de Citação

O ABNTyp suporta os dois sistemas de chamada permitidos pela NBR 10520:2023:

### Sistema Autor-Data (padrão)

```typst
// Citação entre parênteses
#citar("Silva", 2023, pagina: 45)  // (SILVA, 2023, p. 45)

// Autor no texto
#citar-autor("Silva", 2023)  // Silva (2023)

// Citação direta curta (posicional ou nomeada)
#citacao-curta("Silva", 2023, 45)[Texto da citação]

// Citação direta longa (recuo de 4cm, fonte 10pt)
#citacao-longa("Silva", 2023, "45-46")[
  Texto longo da citação com mais de três linhas...
]

// Citação sem referência (apenas aspas)
#citacao-curta()[sic transit gloria mundi]
```

### Sistema Numérico

O sistema numérico foi implementado inspirado no `abntex2-num.bst` do abnTeX2.

```typst
#import "@preview/abntyp:0.1.3": *

#show: citacao-num-config

O resultado foi positivo #citar-num("silva2023", pagina: 45).
Outros autores #citar-num-multiplos(("santos2022", "costa2021")) confirmam.

#bibliografia-numerica((
  ("silva2023", [SILVA, J. *Título*. São Paulo: Editora, 2023.]),
  ("santos2022", [SANTOS, M. Artigo. *Revista*, v. 1, 2022.]),
))
```

**Nota:** Conforme NBR 10520:2023, o sistema numérico NÃO pode ser usado quando houver notas de rodapé.

---

## Aliases (nomes curtos)

Todas as funções principais possuem aliases curtos. Ambas as formas são equivalentes — use a que preferir:

| Função completa | Alias |
| --- | --- |
| `citacao-curta` | `ccurta` |
| `citacao-longa` | `clonga` |
| `citar-autor` | `cautor` |
| `citar-indireto` | `cindireto` |
| `citar-apud` | `capud` |
| `citar-multiplos` | `cmultiplos` |
| `citar-etal` | `cetal` |
| `citar-entidade` | `centidade` |
| `citar-titulo` | `ctitulo` |
| `folha-rosto` | `rosto` |
| `ficha-catalografica` | `ficha` |
| `dedicatoria` | `dedica` |
| `agradecimentos` | `agradece` |
| `lista-siglas` | `siglas` |
| `lista-simbolos` | `simbolos` |
| `interpolacao` | `interp` |
| `grifo-nosso` | `gnosso` |
| `grifo-do-autor` | `gautor` |
| `citar-num` | `cnum` |
| `citar-num-linha` | `cnlinha` |
| `citar-num-multiplos` | `cnmultiplos` |
| `citar-num-apud` | `cnapud` |
| `citacao-num-curta` | `cncurta` |
| `citacao-num-longa` | `cnlonga` |
| `bibliografia-numerica` | `bibnum` |

---

## Estrutura de Arquivos

```txt
abntyp/
├── lib.typ                 # Ponto de entrada principal
├── README.md               # Este arquivo
├── typst.toml              # Metadados do pacote
├── LICENSE                 # Licença MIT
├── CREDITS.md              # Créditos e agradecimentos
│
├── src/
│   ├── core/               # Configurações fundamentais
│   │   ├── page.typ        # Página (A4, margens)
│   │   ├── fonts.typ       # Fontes (Times/Arial, 12pt)
│   │   ├── spacing.typ     # Espaçamentos (1,5 linhas)
│   │   ├── dates.typ       # Formatação de datas (NBR 5892)
│   │   ├── identifiers.typ # ISBN/ISSN (NBR ISO 2108, NBR 10525)
│   │   ├── sorting.typ     # Ordenação alfabética (NBR 6033)
│   │   ├── proofreading.typ# Marcas de revisão (NBR 6025)
│   │   └── metadata.typ    # Metadados compartilhados (dados())
│   │
│   ├── elements/           # Elementos estruturais
│   │   ├── cover.typ       # Capa
│   │   ├── title-page.typ  # Folha de rosto
│   │   ├── abstract.typ    # Resumo/Abstract
│   │   ├── toc.typ         # Sumário e listas
│   │   ├── index.typ       # Índice remissivo (NBR 6034)
│   │   └── spine.typ       # Lombada (NBR 12225)
│   │
│   ├── text/               # Elementos textuais
│   │   ├── headings.typ    # Seções (NBR 6024)
│   │   ├── quotes.typ      # Citações (NBR 10520)
│   │   ├── figures.typ     # Figuras, quadros, gráficos
│   │   └── tables.typ      # Tabelas (IBGE)
│   │
│   ├── references/         # Sistema de referências
│   │   ├── citation.typ    # Sistema autor-data
│   │   ├── numeric.typ     # Sistema numérico
│   │   ├── bibliography.typ# Bibliografia
│   │   ├── abbreviations.typ# Abreviação de títulos (NBR 6032)
│   │   └── abnt.csl        # Estilo CSL
│   │
│   └── templates/          # Templates de documentos
│       ├── thesis.typ      # Trabalho acadêmico (NBR 14724)
│       ├── article.typ     # Artigo científico (NBR 6022)
│       ├── book.typ        # Livro (NBR 6029)
│       ├── technical-report.typ # Relatório técnico (NBR 10719)
│       ├── research-project.typ # Projeto de pesquisa (NBR 15287)
│       ├── periodical.typ  # Publicação periódica (NBR 6021)
│       ├── poster.typ      # Pôster científico (NBR 15437)
│       └── slides.typ      # Apresentação de slides
│
├── docs/                   # Documentação
│   ├── manual.typ          # Manual completo
│   └── guia-rapido.typ     # Guia rápido
│
└── examples/               # Exemplos canônicos
    ├── tcc-exemplo.typ     # Trabalho acadêmico
    ├── artigo-exemplo.typ  # Artigo científico
    ├── slides-defesa-exemplo.typ # Slides para defesa
    └── referencias.bib     # Referências de exemplo
```

---

## Licença

Este projeto é distribuído sob a licença **MIT**.

O arquivo `abnt.csl` foi adaptado do projeto [csl-abnt](https://github.com/virgilinojuca/csl-abnt) (CC0/domínio público) por @virgilinojuca e @AAguiarCAM.

---

## Créditos e Agradecimentos

Este projeto é quase um fork do **[abnTeX2](https://github.com/abntex/abntex2)**, o pacote LaTeX para formatação de documentos conforme normas ABNT, mantido por Lauro César Araujo e a equipe abnTeX2.

A estrutura de documentação, os modelos canônicos de exemplos, e várias decisões de design são simples "ports" do excelente trabalho do abnTeX2, que há mais de uma década auxilia a comunidade acadêmica brasileira na produção de documentos em conformidade com as normas ABNT.

Agradecemos especialmente:

- **Lauro César Araujo** e a **equipe abnTeX2** - pelo trabalho pioneiro e contínua manutenção do abnTeX2
- **Gerald Weber, Miguel Frasson, Leslie H. Watter** e demais integrantes do projeto abnTeX original
- A **comunidade abnTeX** no Google Groups pelas discussões e contribuições

### Recursos Utilizados

- **Typst** - Sistema de tipografia moderno (https://typst.app)
- **csl-abnt** - Estilo CSL para ABNT por @virgilinojuca e @AAguiarCAM
- **Touying** - Pacote Typst para apresentações

---

## Contribuindo

Contribuições são bem-vindas! Por favor:

1. Abra uma issue para discutir a mudança proposta
2. Faça um fork do repositório
3. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
4. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
5. Push para a branch (`git push origin feature/nova-funcionalidade`)
6. Abra um Pull Request

---

## Suporte

- **Issues:** https://github.com/3sdras/abntyp/issues
- **Discussões:** https://github.com/3sdras/abntyp/discussions

---

_ABNTyp — Base Normativa Typst. Documentos técnicos e científicos brasileiros em Typst, compatíveis com as normas ABNT._
