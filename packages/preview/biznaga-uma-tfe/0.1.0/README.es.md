# biznaga-uma-tfe

[English](README.md) · **Español**

Plantilla no oficial para TFG/TFM de la **Escuela Técnica Superior de Ingeniería de Telecomunicación (Universidad de Málaga)**, desarrollada en **Typst**.

## Uso

```sh
typst init @preview/biznaga-uma-tfe
```

Edita los parámetros en `main.typ`:

```typ
#show: thesis.with(
  title: "<TÍTULO DEL TRABAJO>",
  title-en: "<TÍTULO DEL TRABAJO EN INGLÉS>",
  author-name: "<AUTOR>",
  supervisor-name: "<TUTOR>",
  degree: "<TITULACIÓN>",
  year: "20XX",
  acronyms: csv("01-ini/acronyms.csv", row-type: dictionary),
  show-todos: true,
)
```

- **Acrónimos**: `01-ini/acronyms.csv` (`acronym,expansion,en`). Se citan con `@SIGLA` (primera vez: forma larga; luego, sigla). `en=1` pone el término en cursiva.
- **TODO**: `#TODO[texto]`; pon `show-todos: false` para ocultarlos. La lista se genera en `02-toc/todo.typ`.
- **Utilidades**: `minitoc()`, `xtable()`, `algorithm()`, `repo-qr-content()`, `chapterend()`.

## Estructura

```
├── main.typ
├── 01-ini/   portada, resúmenes, dedicatoria, agradecimientos, acrónimos
├── 02-toc/   índices (contenido, figuras, tablas y TODOs)
├── 03-cap/   capítulos
├── 04-ape/   apéndices
└── 05-bib/   bibliografía
```

## Fuentes

Usa *TeX Gyre Heros*. Instálala para obtener el aspecto previsto.

## Reconocimientos

Basada en la plantilla oficial en LaTeX:
[Plantilla TFE - ETSIT Universidad de Málaga](https://www.overleaf.com/latex/templates/plantilla-tfe-etsit-universidad-de-malaga/xgkpmrryzwxv)
