# ZetTypst Core

The minimal, policy-free core for expressing knowledge semantics in Typst, with an editable notebook template [Kickstart](https://github.com/Project-ZetTypst/ZetTypst/tree/main/kickstart).

Import:

```typ
#import "@preview/zettyp-core:0.1.0": (
  eval, graph, knowledge, observation, policy, semantic, vocabulary,
)
```

Using Kickstart template:

```sh
typst init @preview/zettyp-core:0.1.0 my-notes
cd my-notes
typst compile index.typ
```

[MIT](LICENSE).
