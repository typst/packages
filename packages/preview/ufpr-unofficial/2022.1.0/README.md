<div align="center">
  <h1>UFPR Academic Work Template<br><small>(Unofficial)</small></h1>
  <p>🇺🇸 English | <a href="README.pt.md">🇧🇷 Português</a></p>
</div>

## Note
All code documentation of this package is in Brazilian Portuguese considering it is targeted at students from a
Brazilian university.

## Quick Start
```typst
#import "@preview/ufpr-unofficial:2022.1.0": *

#show: template.with(
  // Obligatory parameters
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
  // Optional parameters
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

## Description
An unofficial Typst template for academic work following ABNT standards, designed for students of the Federal University of Paraná (UFPR). Supports comprehensive academic document structures including theses, reports, and dissertations with automatic formatting, illustrations, tables, appendices, and bibliography management.

## Standards & Versioning
This template is based on the **ABNT Manual of Scientific Document Normalization** (Manual de Normalização de Documentos Científicos de Acordo com As Normas da ABNT).

**Versioning Scheme:**
Version numbers follow the pattern `[manual-year].[major].[minor]`:
- `manual-year`: Year of the ABNT manual edition
- `major`: Major version (breaking changes)
- `minor`: Minor version (features, bug fixes)

For example, `2022.0.0` indicates compatibility with the 2022 ABNT manual edition.

## References

MACHADO, Vila; MENGATTO, Angela Pereira de Farias; UEZU, Denis; STROPARO, Eliane Maria; ASSUMPÇÃO, Fabrício Silva; GONÇALVES, Lucas; ARAÚJO, Paula Carina de; ZULPO, Suzana. **Manual de normalização de documentos científicos de acordo com as normas da ABNT**. Curitiba: Sistema de Bibliotecas da UFPR, 2022.

JUCA, Virgílio Nóbrega de. **csl-abnt**. GitHub. Disponível em: https://github.com/virgilinojuca/csl-abnt. Acesso em: 27 mar. 2026.

## Additional Functions

### `illustration(body, supplement: "figura", caption: "", source: _default-source)`
Renders illustrations, figures, graphics, or annexes with captions and source attribution.

**Parameters:**
- `body`: The content to display (typically an image)
- `supplement`: Type of element: `"figura"`, `"gráfico"`, `"mapa"`, `"fotografia"`, or `"anexo"`
- `caption`: Title/description of the element (required)
- `source`: Source attribution (defaults to "Autor (current-year)")

When `supplement` is `"anexo"`, the element is deferred and rendered at the end of the document in the appendices section instead of inline.

### `sheet(columns: 1, caption: "", source: _default-source, breakable: false, note: none, legend: none, ..children)`
Renders tables with captions, source attribution, optional notes, and legends.

**Parameters:**
- `columns`: Number of columns in the table
- `caption`: Table title (required)
- `source`: Source attribution (defaults to "Autor (current-year)")
- `breakable`: Whether the table may split across pages when content is long
- `note`: Optional note displayed below the table
- `legend`: Optional legend displayed below the table
- `..children`: Table cells content