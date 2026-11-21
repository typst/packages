# nexum-apa-core

Shared composition and APA styling engine used by `nexum-apa-paper` and
`nexum-apa-lab-report`.

This package is published first because both template packages import it:

```typst
#import "@preview/nexum-apa-core:0.1.0": compose-document
```

The monorepo stores this package in `packages/core/`; the published Typst
package identifier remains `nexum-apa-core`, as declared in `typst.toml`.

This is a library package, not a starter template.
