<div align="center">
  <h1>Template de Trabalhos Acadêmicos da UFPR<br><small>(Não Oficial)</small></h1>
  <p><a href="README.md">🇺🇸 English</a> | 🇧🇷 Português</p>
</div>

## Início Rápido
```typst
#import "@preview/ufpr-unofficial:2022.0.0": *

#show: template.with(
  // Parâmetros obrigatórios
  title: "Aplicação de Machine Learning para Classificação de Imagens de Satélite na Agricultura de Precisão",
  authors: ("Marina Silva Santos",),
  advisor: "Prof. Dr. Roberto Pereira Costa",
  city: "Curitiba",
  year: 2024,
  description: [
    Relatório técnico apresentado à disciplina de Metodologia Científica 
    do curso de Engenharia de Computação da Universidade Federal do Paraná, 
    como requisito parcial para aprovação na disciplina.
  ],
  references: bibliography("refs.bib"),
  // Parâmetros opcionais
  has-cover: true,
  glossary: (
    "Agricultura de Precisão", [Metodologia de produção agrícola que utiliza tecnologia para otimizar recursos e aumentar produtividade.],
    "Machine Learning", [Subárea da inteligência artificial que permite computadores aprenderem com dados sem serem explicitamente programados.],
    "Imagem de Satélite", [Representação digital de uma área da superfície terrestre capturada por sensores orbitais.],
  )
)

= Introdução
// ...
```

## Descrição
Um template Typst não oficial para trabalhos acadêmicos conforme as normas da ABNT, desenvolvido para estudantes da Universidade Federal do Paraná (UFPR). Suporta estruturas completas de documentos acadêmicos, incluindo teses, relatórios e dissertações, com formatação automática, ilustrações, tabelas, apêndices e gerenciamento de bibliografia.

## Normas e Versionamento
Este template é baseado no **Manual de Normalização de Documentos Científicos de Acordo com as Normas da ABNT**.

**Esquema de versionamento:**
Os números de versão seguem o padrão `[ano-manual].[major].[minor]`:
- `ano-manual`: Ano da edição do manual da ABNT
- `major`: Versão major (mudanças incompatíveis)
- `minor` número: Versão minor (recursos e correções)

Por exemplo, `2022.0.0` indica compatibilidade com a edição de 2022 do manual da ABNT.

## Referências

MACHADO, Vila; MENGATTO, Angela Pereira de Farias; UEZU, Denis; STROPARO, Eliane Maria; ASSUMPÇÃO, Fabrício Silva; GONÇALVES, Lucas; ARAÚJO, Paula Carina de; ZULPO, Suzana. **Manual de normalização de documentos científicos de acordo com as normas da ABNT**. Curitiba: Sistema de Bibliotecas da UFPR, 2022.

JUCA, Virgílio Nóbrega de. **csl-abnt**. GitHub. Disponível em: https://github.com/virgilinojuca/csl-abnt. Acesso em: 27 mar. 2026.

## Funções Adicionais

### `illustration(body, supplement: "figura", caption: "", source: _default-source)`
Renderiza ilustrações, figuras, gráficos ou anexos com legendas e atribuição de fonte.

**Parâmetros:**
- `body`: Conteúdo a ser exibido (geralmente uma imagem)
- `supplement`: Tipo de elemento: `"figura"`, `"gráfico"`, `"mapa"`, `"fotografia"` ou `"anexo"`
- `caption`: Título/descrição do elemento (obrigatório)
- `source`: Atribuição de fonte (padrão: "Autor (ano-atual)")

Quando `supplement` é `"anexo"`, o elemento é adiado e renderizado no final do documento, na seção de apêndices, em vez de aparecer em linha.

### `sheet(columns: 1, caption: "", source: _default-source, note: none, legend: none, ..children)`
Renderiza tabelas com legenda, atribuição de fonte, notas opcionais e legenda explicativa.

**Parâmetros:**
- `columns`: Número de colunas da tabela
- `caption`: Título da tabela (obrigatório)
- `source`: Atribuição de fonte (padrão: "Autor (ano-atual)")
- `note`: Nota opcional exibida abaixo da tabela
- `legend`: Legenda opcional exibida abaixo da tabela
- `..children`: Conteúdo das células da tabela