# Navigator

**Navigator** is a navigation engine for Typst. It provides a modular suite of tools to generate dynamic tables of contents (progressive outlines), progress bars (miniframes), and automated transition slides. It should be compatible with any presentation framework (e.g., Polylux, Presentate, Typslides). All tools can also be used for any native Typst documents (particularly the `progressive-outline` function), but they are especially useful when used within a structured presentation.

## Key Features

- **Progressive Outline**: A roadmap component that adapts to the current position in the document, with smart state management (active, completed, future).
- **Flexible Miniframes**: Configurable progress markers (compact vs. grid modes, alignment, vertical positioning).
- **Transition Engine**: Automatically generates "roadmap" slides during section changes via simple show rules.

## Installation

Import the package from the Typst Universe:

```typ
#import "@preview/navigator:0.1.0": *
```

## Core Components

### Progressive Outline (`progressive-outline`)
The `progressive-outline` function inserts a table of contents that reflects the document's progression. See [detailed documentation](docs/progressive-outline.typ) ($\Rightarrow$ [pdf](https://github.com/eusebe/typst-navigator/blob/main/docs/progressive-outline.pdf)).

```typ
#progressive-outline(
  level-1-mode: "all",
  level-2-mode: "current-parent",
  text-styles: (
    level-1: (active: (weight: "bold", fill: navy), inactive: 0.5),
  ),
  spacing: (v-between-1-2: 1em)
)
```

### Navigation Bars (`render-miniframes`)
Generates a bar of dots (miniframes) representing the logical structure of a presentation. See [detailed documentation](docs/miniframes.typ) ([pdf](https://github.com/eusebe/typst-navigator/blob/main/docs/miniframes.pdf)).

```typ
#render-miniframes(
  structure,            // Extracted via get-structure()
  current-slide-num,    // Current active slide index
  style: "compact",
  navigation-pos: "top",
  active-color: blue
)
```

### Transition Engine (`render-transition`)
Automates the creation of roadmap slides using a show rule on structural headings. See [detailed documentation](docs/transition.typ) ([pdf](https://github.com/eusebe/typst-navigator/blob/main/docs/transition.pdf)).

```typ
#show heading.where(level: 1): h => render-transition(
  h,
  mapping: (section: 1, subsection: 2),
  slide-func: my-slide-wrapper, // A function (fill, body) => content
  transitions: (background: navy)
)
```

## Demos

Integration examples using different slide engines are available in the `examples/` directory:

-  [**Presentate**](https://typst.app/universe/package/presentate/): [Miniframes + Progressive Outline & Transitions](examples/presentate_integration.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/presentate_integration.pdf))
- [**Polylux**](https://typst.app/universe/package/polylux): [Miniframes only](examples/polylux_miniframes.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/polylux_miniframes.pdf)), [Progressive Outline & Transitions only](examples/polylux_progressive_ouline.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/polylux_progressive_ouline.pdf))
- [**Typslides**](https://typst.app/universe/package/typslides): [Miniframes only](examples/typslides_miniframes.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/typslides_miniframes.pdf))
- **Standard Documents**: [Report with local roadmaps](examples/report.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/report.pdf)), [Customizable markers](examples/markers.typ) ($\Rightarrow$ [pdf results](https://github.com/eusebe/typst-navigator/blob/main/examples/markers.pdf))

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgement 

Thanks to the [presentate package author](https://github.com/pacaunt/typst-presentate) for his constructive feedback and valuable insights during the development of these tools.
