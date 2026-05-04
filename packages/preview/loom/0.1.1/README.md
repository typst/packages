# Loom

**Reactive Documents for Typst**

Loom transforms Typst from a linear typesetting system into a **reactive engine**. It enables bidirectional data flow, allowing your document to "think" before it renders.

📖 **[Read the Documentation](https://leonieziechmann.github.io/loom/)**

---

## Why Loom?

Typst's linear execution makes complex architectural patterns difficult. Loom solves two primary headaches:

- **Aggregation:** Children emit **Signals** that bubble up, allowing parents to calculate data (like total prices or calories) _before_ rendering the final output.
- **Global Dependencies:** Through a **Weave Loop** (multiple passes), a component at the end of the document can update a summary or counter on page one.

---

## Installation

Import Loom **v0.1.1** from the package preview:

```typ
#import "@preview/loom:0.1.1"

// 1. Construct a unique instance for your project.
// The key (<my-project>) isolates your components from other libraries.
#let (weave, motif, prebuild-motif) = loom.construct-loom(<my-project>)

// 2. Export the specific tools you want to use.
// This keeps your API clean for the rest of your document.

// The Engine
#let weave = weave

// The Component Constructors
#let managed-motif = motif.managed
#let compute-motif = motif.compute
#let content-motif = motif.content
#let data-motif = motif.data
#let motif = motif.plain

// Prebuild Motifs
#let apply = prebuild-motif.apply
#let debug = prebuild-motif.debug
#let static = prebuild-motif.static
```

---

## Quick Start

```typ
#import "@preview/loom:0.1.1"

// 1. Initialize Loom
#let (weave, motif) = loom.construct-loom(<my-project>)

// 2. Define a data-emitting component
#let ingredient(price) = (motif.data)("ing", measure: _ => (price: price))

// 3. Define a parent that sums child data
#let recipe(name, body) = (motif.plain)(
  measure: (ctx, children) => {
    let total = loom.query.sum-signals(children, "price")
    (none, (price: total))
  },
  draw: (ctx, public, view, body) => block[
    *#name* (Total: \$#view.price) \ #body
  ],
  body
)

#show: weave.with()

#recipe("Tomato Soup")[
  #ingredient(2.50)
  #ingredient(1.50)
  Ingredients listed here...
]
```

---

## Real-World Usage

For a complex implementation, see **[invoice-pro](https://github.com/leonieziechmann/invoice-pro)**, an invoicing template that utilizes Loom for heavy data aggregation.

---

## Core Concepts

Detailed explanations are available in the **[Concepts Documentation](https://leonieziechmann.github.io/loom/concepts)**.

| Concept                                                                       | Direction | Description                                                                    |
| :---------------------------------------------------------------------------- | :-------- | :----------------------------------------------------------------------------- |
| **[Scope](https://leonieziechmann.github.io/loom/concepts/state-management)** | ⬇️ Down   | **Context.** Parents inject variables inherited by all descendants.            |
| **[Signals](https://leonieziechmann.github.io/loom/concepts/data-flow)**      | ⬆️ Up     | **Aggregation.** Children emit data "frames" that bubble up for summarization. |
| **[Weave](https://leonieziechmann.github.io/loom/concepts/mental-model)**     | 🔄 Loop   | **Convergence.** The engine runs multiple passes until data stabilizes.        |

---

## Limitations

Loom operates within the specific boundaries of the Typst runtime. Review the full **[Limitations Guide](https://leonieziechmann.github.io/loom/advanced/limitations)** for more details.

- **Vertical-Only Flow:** Data flows `Child -> Parent`. Sibling components cannot see each other in the same pass.
- **Stack Depth:** Recursion is limited to approximately **50 levels**.
- **Opaque Fields:** Loom cannot see inside named arguments like `figure(caption: [...])`.
- **Show Rules:** Standard `#show` rules run _after_ Loom's logic and cannot transform text into Loom components.

## License

MIT License
