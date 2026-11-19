# Student guide

## Start a report

Follow the [README environment setup](../README.md#local-environment), then
compile root `main.typ`. Work in a separate copy for each project and keep it in
version control. Commit the editable Typst sources and assets; `build/` is ignored.

Edit `template/project.typ` first. Each student is a dictionary with `name` and
`id`; keep IDs in quotes to preserve leading zeros. Arrays with one item require
a trailing comma:

```typst
students: (
  (name: "Your Name", id: "011234567"),
  (name: "Teammate Name", id: "011234568"),
),
date: [November 2026],
supervisors: ([Supervisor Name, Assistant Professor],),
```

These fields go inside the existing `project` dictionary. Use an explicit date
instead of today's date so that later rebuilds keep the original submission date.

## Write chapters

Edit the corresponding file in `template/chapters/`. Every chapter should start
with one or two sentences describing its scope. Replace instructional paragraphs
with your own work and fill empty sections only where relevant.

| LaTeX | Typst |
| --- | --- |
| `\chapter{Introduction}` | `= Introduction` |
| `\section{Objectives}` | `== Objectives` |
| `\subsection{Scope}` | `=== Scope` |
| `\textbf{bold}` | `*bold*` |
| `\textit{italic}` | `_italic_` |
| `\cite{key}` | `@key` |
| `\label{fig:design}` | `<fig:design>` after the figure |
| `Figure~\ref{fig:design}` | `@fig:design` |

Typst automatically supplies “Figure”, “Table”, “Chapter”, or “Equation” when
referencing a numbered element. Do not write `Figure @fig:design`.

Use `-` for bullets and `+` for numbered list items. A blank line starts a new
paragraph. Use `$ ... $` for mathematics and fenced code blocks for code listings.
The [Typst tutorial](https://typst.app/docs/tutorial/) covers the full syntax.

## Figures, tables, and citations

The project design chapter includes a working figure, equation, and references.
Figure paths are relative to the file containing the image call. From a chapter:

```typst
#figure(
  image("../assets/context.svg", width: 100%, alt: "Describe the diagram."),
  caption: [System context.],
) <fig:system>

The system boundary is shown in @fig:system.
```

Wrap tables in `figure(..., kind: table, caption: [...])` so they appear in the
List of Tables. The standards chapter provides two examples. Replace dashes with
your actual assessment and explain every selected mapping. Do not copy example
mapping claims without evidence.

Add BibTeX entries to `template/references.bib` and cite them using `@key`. Typst
builds the IEEE numeric bibliography in citation order; no BibTeX command or
repeated compile passes are needed. The inherited algorithm-design book is a
syntax example; remove it and its citation if it is irrelevant to your work.

## FYDP-1 and final reports

```sh
python3 scripts/project.py build --stage fydp-1
python3 scripts/project.py build --stage final
```

Outputs are `build/fydp-1.pdf` and `build/fydp.pdf`. In `template/content.typ`,
change the `default: "final"` value to `default: "fydp-1"` to select the stage
for editor/web previews. The CLI argument takes priority.

FYDP-1 omits implementation and results. You may include a preliminary version by
editing that conditional include, with your educator's guidance. Introduction,
background, project design, standards and constraints, and conclusion are in both
versions. Renumbering is automatic.

## Front matter and logo

Abstract and acknowledgements are enabled by default. Edit their files in
`template/front-matter/`. Uncomment the `publications` entry in `project.typ` to
enable that page, and include only actual publications with accurate status.
Use `abstract: none` or `acknowledgements: none` to omit a page if permitted.

Reports do not require a logo. For local source checkouts, put an approved logo in
`local-assets/` and run `python3 scripts/project.py build --logo local-assets/uiu.png`.
That directory is ignored by Git and omitted from the package. To add an approved
logo to a project initialized from the package, place it in `assets/` and change its show rule:

```typst
#show: fydp-report.with(..project, logo: image("assets/my-logo.png", width: 28mm))
```

Do not add a second `logo` argument if one is already present in your dictionary.

## Before submission

- Replace all example names, IDs, dates, diagrams, prose, and table dashes.
- Check that every citation is real and every claim is supported.
- Verify stage-specific requirements with your supervisor.
- Review the contents, Roman/Arabic numbering, captions, engineering mappings,
  bibliography, and all page breaks in the exported PDF.
- Retain the template attribution when distributing adapted material. Your
  project content remains your own work.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `package not found` before publication | Compile root `main.typ`; `template/main.typ` is the future package starter. |
| File outside project root | Open the full repository and compile with `--root .`. |
| Missing image | Check the path relative to the chapter file, including capitalization. |
| Unknown citation or reference | Check the BibTeX key or `<label>` spelling. |
| Font differs between machines | Use the pinned compiler and `--ignore-system-fonts`. |
| Changes do not appear in the PDF | Rebuild and open `build/fydp.pdf`, or `build/fydp-1.pdf` for FYDP-1. |
| Empty List of Figures/Tables | Add captioned figures or set the relevant `show-…-list` option to `false`. |
| Typst syntax error | Check commas in dictionaries, matching brackets, and the first compiler diagnostic. |
