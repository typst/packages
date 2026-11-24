# Calepin

**Documentation, installation, and tutorials: <https://vincentarelbundock.github.io/calepin>**

Calepin turns standard Typst documents into computational notebooks and static websites. Write prose, executable code chunks, and inline computations in a single `.typ` file; figures, tables, and numbers are computed at render time instead of pasted in by hand. Calepin supports Python, R, Julia, and shell code, along with diagram tools such as Mermaid, Graphviz, TikZ, and D2. It renders single documents to PDF or HTML, and builds entire websites, from a simple blog to a multi-section documentation site with themes, layouts, and navigation.

## This package is a compatibility shim

Typst deliberately sandboxes packages, so no Typst package can run Python, R, or any other external program by itself. Code execution requires the `calepin` command-line application, which is what users will want in most cases:

```sh
calepin compile paper.typ
```

This package exists so that the *same document* also degrades gracefully when compiled with the plain `typst` application (the CLI, the web app, or a collaborator's machine without Calepin). In that case, nothing is executed: code chunks render as static highlighted listings, cross-references and page listings resolve to placeholders instead of breaking the compile, and a one-time banner explains that results are missing.

When you compile with the `calepin` application, this shim is never loaded: the CLI transparently swaps the import below for its own generated runtime, and chunks execute for real.

## Minimal example

````typst
#import "@preview/calepin:0.1.0" as calepin
#show: calepin.document

= My analysis

```python
x = 21
print(x * 2)
```
````

The same import line works with both `typst compile` (static fallback) and `calepin compile` (executed results).

To suppress the fallback banner under plain `typst`:

```typst
#calepin.setup(fallback-warning: false)
```

## Versioning

This package tracks Calepin's public Typst API (`document`, `setup`, `chunk`, `inline`, `results`, `store`, `pages`, `elements`), not the CLI release cadence. New versions are published only when that API surface changes.
