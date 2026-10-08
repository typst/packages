# Contributing to the project

Commits messages and PR titles must follow [Conventional Commits Specification](https://www.conventionalcommits.org/).


## Formatter setup
We use [typstyle](https://typstyle-rs.github.io/typstyle/), with a line width of 80.

To format:
```bash
typstyle -i -l 80 .
```

In VS-Code with [Tynimist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist), add the following configuration to your `settings.json`:
```json
{
  "tinymist.formatterMode": "typstyle",
  "tinymist.formatterPrintWidth": 80,
  "tinymist.formatterProseWrap": true
}
```

## How to check before release
```
just install-preview
typst init @preview/uc3m-thesis:1.0.0 mitfg
cd mitfg
typst compile report.typ
```
