# ABNTyp

**ABNTyp** is a [Typst](https://typst.app) package for formatting Brazilian academic and technical documents in compliance with ABNT standards (Associação Brasileira de Normas Técnicas). It provides templates for theses, dissertations, articles, reports, books, and more — with author-date and numeric citation systems per NBR 10520:2023.

---

**ABNTyp — Base Normativa Typst** — Formatação de documentos técnicos e científicos brasileiros conforme normas ABNT para [Typst](https://typst.app).

---

## Sobre o Projeto

O **ABNTyp** é um pacote Typst para formatação de documentos acadêmicos e técnicos em conformidade com as normas da ABNT (Associação Brasileira de Normas Técnicas).

Este projeto está sendo escrito via Claude Code a partir das minhas orientações, fruto da experiência que tive com LaTeX, que começou na USP de São Carlos em 2000, por influência
principalmente do Prof. Dr. Sadao Massago. Também neste período e local pude conhecer o Prof. Dr. Miguel Vinicius Santini Frasson, um dos criadores do abnTeX original, bem como o famoso texto "Uma introdução ao LaTeX 2e" do Prof. Dr. Lenimar Nunes de Andrade. Anos mais tarde, tive contato com o excelente abnTeX2, do Prof. Dr. Lauro César Araujo. Todo o mérito deste projeto, portanto, deve ir para as pessoas e projetos citados acima, bem como criadores e comunidades do LaTeX e do Typst.

O objetivo aqui é adaptar o projeto abnTeX2 para o caso do Typst, para servir como base na disciplina "Software Livre para Edição de Textos Matemáticos" em 2026 (Núcleo Livre). A parte de matemática, caixas decorativas e ambientes de teoremas — adaptada do trabalho do Prof. Lenimar — está no pacote companheiro **[FerrMat](https://github.com/3sdras/ferrmat)**.

---

## Instalação

### Via Typst Universe (recomendado)

```typst
#import "@preview/abntyp:0.7.0": *
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
| [`docs/manual-implementacao.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/manual-implementacao.typ) | Manual completo da classe e funções |
| [`docs/introducao-abntyp.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/introducao-abntyp.typ) | Introdução ao Typst e ao ABNTyp, em formato de livro (tutorial) |
| [`docs/guia-rapido.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/guia-rapido.typ) | Guia rápido para começar |

### Modelos Canônicos (Exemplos)

| Arquivo                                 | Tipo de Documento                           | Norma Principal |
| --------------------------------------- | ------------------------------------------- | --------------- |
| [`examples/tcc-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/tcc-exemplo.typ) | Trabalho acadêmico (tese, dissertação, TCC) | NBR 14724:2024 |
| [`examples/artigo-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/artigo-exemplo.typ) | Artigo científico | NBR 6022:2018 |
| [`examples/relatorio-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/relatorio-exemplo.typ) | Relatório técnico | NBR 10719:2015 |
| [`examples/projeto-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/projeto-exemplo.typ) | Projeto de pesquisa | NBR 15287:2025 |
| [`examples/livro-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/livro-exemplo.typ) | Livro | NBR 6029:2023 |
| [`examples/periodico-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/periodico-exemplo.typ) | Publicação periódica | NBR 6021:2015 |
| [`examples/poster-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/poster-exemplo.typ) | Pôster científico | NBR 15437:2006 |
| [`examples/slides-defesa-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/slides-defesa-exemplo.typ) | Apresentação de slides | Boas práticas\* |
| [`examples/citacao-numerica-exemplo.typ`](https://github.com/3sdras/abntyp/blob/v0.7.0/examples/citacao-numerica-exemplo.typ) | Sistema numérico de citações | NBR 10520:2023 |

_\* A ABNT não possui norma específica para slides. O template segue boas práticas acadêmicas._

### Arquivos de Referência

| Arquivo                    | Descrição                             |
| -------------------------- | ------------------------------------- |
| `examples/referencias.bib` | Referências bibliográficas de exemplo |
| `src/references/abnt.csl`  | Estilo CSL para formatação ABNT       |

---

## Normas Implementadas

O ABNTyp implementa as seguintes normas ABNT (edições de 1989 a 2025, conforme a tabela):

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
#import "@preview/abntyp:0.7.0": *

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
#show: normas-abnt.with(
  fonte: "Times New Roman",
  // arquivo-bibliografia: read("referencias.bib"),  // gera REFERÊNCIAS ao final, automaticamente
  // paginacao: "auto",    // ABNT (padrão); "todas" ou "nenhuma" para mudar
  // enumeracao: "abnt",  // alíneas a), b) e subalíneas –; ou "latex": 1., a), i), A.
  // frente-verso: true,   // margens espelhadas, número alternado, capítulos em página ímpar
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

### Numeração de páginas

A numeração é automática (NBR 14724:2024): a contagem começa na folha de rosto, o número aparece no canto superior direito a partir da Introdução e segue até as Referências. Para alterar:

- `normas-abnt.with(paginacao: "todas")` — número visível desde a folha de rosto
- `normas-abnt.with(paginacao: "nenhuma")` — sem numeração automática (use `#set page(...)`)
- `normas-abnt.with(frente-verso: true)` — impressão frente-verso: margens espelhadas, número à esquerda nas páginas pares e capítulos iniciando em página ímpar

O template `relatorio` (NBR 10719) aceita as mesmas opções (`paginacao`, `frente-verso`). O `livro` (NBR 6029) conta desde a primeira folha do miolo e mostra o número, no rodapé centralizado, após o sumário; aceita `paginacao` e `frente-verso` (margens espelhadas; folha de rosto, errata, dedicatória, agradecimentos, epígrafe, prefácio, sumário, glossário, posfácio, partes e capítulos em página ímpar).

Em frente-verso, a ficha catalográfica (no verso da folha de rosto) não é contada (NBR 14724, 5.3): a Introdução abre em página ímpar do PDF e pode receber número par. A posição do número segue a página física.

### Artigo Científico

```typst
#import "@preview/abntyp:0.7.0": *

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

`artigo` e `relatorio` usam espaçamento simples por padrão (NBR 6022, 6.1; NBR 10719, 5.1). Para 1,5: `espacamento: "1,5"`. O trabalho acadêmico (NBR 14724) fica sempre em 1,5.

---

## Sistemas de Citação

O ABNTyp suporta os dois sistemas de chamada permitidos pela NBR 10520:2023:

### Sistema Autor-Data (padrão)

```typst
// Citação entre parênteses
#citar("Silva", 2023, pagina: 45)  // (Silva, 2023, p. 45)

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
#import "@preview/abntyp:0.7.0": *

#show: citacao-num-config

O resultado foi positivo #citar-num("silva2023", pagina: 45).
Outros autores #citar-num-multiplos(("santos2022", "costa2021")) confirmam.

#bibliografia-numerica((
  ("silva2023", [SILVA, J. *Título*. São Paulo: Editora, 2023.]),
  ("santos2022", [SANTOS, M. Artigo. *Revista*, v. 1, 2022.]),
))
```

**Nota:** Conforme NBR 10520:2023, o sistema numérico NÃO pode ser usado quando houver notas de rodapé. A chamada sai com vírgula entre números, como na norma: `(1, 2)`. Em `citar-num-apud`, o primeiro argumento é o texto da chamada original (`"Freire, 1994"`), não uma chave.

---

## Referências bibliográficas (NBR 6023)

As referências saem de um arquivo `.bib` com o estilo CSL ABNT incluído no pacote (`#referencias(read("referencias.bib"))`) ou são escritas à mão. O caminho precisa vir dentro de `read(...)`; texto puro dá erro. A lista sai alinhada à margem esquerda, sem recuo, em espaço simples e com uma linha em branco entre as entradas (NBR 6023, 6.3).

**Como cadastrar no `.bib`.** Capítulo de livro: `@inbook`, não `@incollection` (que perde o "In:" e o título da obra). Dissertação e tese: `@thesis` com `publisher` (a instituição) e `type` completo, por exemplo `{Tese (Doutorado em Psicologia)}`; `institution` e `school` são ignorados. Trabalho em evento: `@inproceedings` com `booktitle` (por exemplo `{Anais}`) e `eventtitle`. Subtítulo: `title = {Título: subtítulo}`; o campo `subtitle` é descartado. Detalhes e limites por versão do Typst estão na [introdução](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/introducao-abntyp.typ) e no [manual](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/manual-implementacao.typ).

**Tipos de documento sem entrada no Typst.** Partitura (NBR 6023, 7.14), jurisprudência (7.11.3 e 7.11.4), atos administrativos normativos (7.11.5 e 7.11.6) e documentos civis e de cartórios (7.12) não têm tipo de entrada no Typst: não há como cadastrá-los no `.bib`, e o estilo do ABNTyp não os formata. Escreva essas referências à mão, conforme a norma. Veja a seção "Limitações do CSL e soluções manuais" do [documento de introdução](https://github.com/3sdras/abntyp/blob/v0.7.0/docs/introducao-abntyp.typ).

---

## Notas de uso

- **Fonte Arial.** `normas-abnt.with(fonte: "Arial")` gera 1 aviso `unknown font family: liberation sans` fora do Linux. É de propósito: sem "Liberation Sans" na pilha, o texto cairia em fonte serifada onde só há essa família, sem nenhum aviso. Com `fonte: "Times New Roman"` (padrão) não há aviso.
- **Entrelinha.** O passo de linha é calibrado pelo Word: 1,5 = 20,7 pt em corpo 12 pt (igual em Times e Arial), simples = 13,8 pt, e o espaço entre parágrafos é igual à entrelinha.
- **Títulos primários.** O título de nível 1 abre a página no topo da mancha; o vão antes dele (51,01 pt) é maior que o do nível 2 (42,30 pt).
- **Atalho `#sublinhado`.** `#sub[...]` é o subscrito nativo do Typst (`H#sub[2]O`); o sublinhado do pacote é `#sublinhado[...]` (até a 0.6.0 se chamava `#sub`).
- **Funções `abnt-*-setup`.** Recebem o corpo do documento: use `#show: abnt-page-setup.with(margem-esquerda: 3cm)`. Chamadas antigas `#abnt-page-setup()` dão `missing argument: body`.
- **`container()`** exige `fonte:` (NBR 14724, 5.8); `fonte: none` dispensa de propósito. ISBN em texto precisa ser válido; para livro sem número, passe conteúdo (`isbn: [em obtenção]`).
- **Slides.** A ABNT não tem norma de slides. A fonte padrão é Arial sem reserva (para não gerar aviso em todo Mac). `--pdf-standard ua-1` reprova os exemplos de slides porque o Touying exige um título de nível 1 primeiro. Sumário com mais de 6 itens e referências com mais de 5 passam da lâmina.
- **Exemplos.** Compile da raiz do pacote com `typst compile --root . examples/tcc-exemplo.typ` (os exemplos importam `../lib.typ`). Ao copiar um exemplo para outro projeto, leve também `referencias.bib` e `docs/figuras/placeholder.svg` e troque o `import` por `@preview/abntyp:<versão>`. Os exemplos não vão no pacote do Universe: estão no repositório.

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

## Suporte

- **Issues:** https://github.com/3sdras/abntyp/issues
- **Discussões:** https://github.com/3sdras/abntyp/discussions

---

_ABNTyp — Base Normativa Typst. Documentos técnicos e científicos brasileiros em Typst, compatíveis com as normas ABNT._
