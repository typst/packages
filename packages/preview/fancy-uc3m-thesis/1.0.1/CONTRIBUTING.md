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


## Before release
1. Ensure you've updated the package version inside `typst.toml`. It must follow the conventions in [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
2. Update the changelog in `docs/manual.typ`
3. Test the package locally:
  ```
  just install-preview
  typst init @preview/fancy-uc3m-thesis mythesis
  cd mythesis
  typst compile report.typ
  ```
4. Compile the documentation:
   ```
   just doc
   ```
