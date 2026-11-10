# unified-uia-thesis
Unified thesis template for bachelor and master theses. It supports both english and norwegian:
```toml
[format]
lang = "no" # or "en"
type = "bachelor" # or "master"
```

## Usage
```typ
#show: report.with(
  // define static metadata in meta.toml
  meta: toml("meta.toml"),

  // anything that goes before the table of contents, like an abstract, acknowledgements, or the group declaration
  frontmatter: include "/frontmatter.typ",

  references: bibliography("references.yml"),

  // anything that comes after the bibliography
  appendices: include "/appendices.typ",

  // to hide the table of contents
  // contents: false,

  // to hide the listings
  // listings: false,
)
// then do anything
```



It's basically a 1:1 copy of the "Bachelor & Master's Thesis" LaTeX template, with the addition of a glossary.