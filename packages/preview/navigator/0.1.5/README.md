# Navigator

**Navigator** is a navigation engine for Typst. It provides a modular suite of tools to generate dynamic tables of contents (progressive outlines), progress bars (miniframes), and automated transition slides. It is compatible with any presentation framework (e.g., Polylux, Presentate, Typslides) and standard Typst documents.

## Key Features

- *Global Configuration*: Centralize your theme settings (colors, mapping, slide function) in one place.
- *Progressive Outline*: A roadmap component that adapts to the current position, with smart state management.
- *Flexible Miniframes*: Configurable progress markers (compact vs. grid modes).
- *Transition Engine*: Automatically generates "roadmap" slides via simple show rules.

## Installation

Import the package from the Typst Universe:

```typ
#import "@preview/navigator:0.1.5": *
```

## Global Configuration

Navigator 0.1.4 introduces a centralized configuration state. Setting this once at the beginning of your document allows you to use all other functions without arguments.

```typ
#navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: navy, accent: orange)
  c.slide-func = my-engine.slide
  c
})
```

## Core Components

### Progressive Outline (`progressive-outline`)

The `progressive-outline` function inserts a table of contents that reflects the document's progression. See [detailed documentation](docs/progressive-outline.typ) (⇒ [pdf](https://github.com/eusebe/typst-navigator/blob/0.1.5/docs/progressive-outline.pdf)).

```typ
// Respects global config automatically
#progressive-outline()

// Or manual override
#progressive-outline(level-1-mode: "current", text-styles: (level-1: (fill: red)))
```

### Miniframes (`render-miniframes`)

Generates a bar of dots representing the logical structure of a presentation. See [detailed documentation](docs/miniframes.typ) (⇒ [pdf](https://github.com/eusebe/typst-navigator/blob/0.1.5/docs/miniframes.pdf)).

```typ
// Simplest usage (context required for auto-resolution)
#set page(header: context render-miniframes())
```

### Transition Engine (`render-transition`)

Automates the creation of roadmap slides using a show rule. See [detailed documentation](docs/transition.typ) (⇒ [pdf](https://github.com/eusebe/typst-navigator/blob/0.1.5/docs/transition.pdf)).

```typ
// Clean one-liner using global configuration
#show heading: render-transition
```

## Demos

Integration examples are available in the `examples/` directory:

- [**Presentate**](https://typst.app/universe/package/presentate/): [Full Integration](examples/presentate_integration.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/presentate_integration.pdf))
- [**Polylux**](https://typst.app/universe/package/polylux): [Miniframes](examples/polylux_miniframes.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/polylux_miniframes.pdf)), [Progressive Outline & Transitions](examples/polylux_progressive_ouline.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/polylux_progressive_ouline.pdf))
- [**Typslides**](https://typst.app/universe/package/typslides): [Miniframes](examples/typslides_miniframes.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/typslides_miniframes.pdf))
- [**Diatypst**](https://github.com/OrangeX4/diatypst): [Full Integration](examples/diatypst_integration.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/diatypst_integration.pdf))
- [**Touying**](https://typst.app/universe/package/touying): [Structural Transitions with per-slide titles](examples/touying_transitions.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/touying_transitions.pdf))
- **Standard Documents**: [Report with local roadmaps](examples/report.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/report.pdf)), [Customizable markers](examples/markers.typ) (⇒ [pdf results](https://github.com/eusebe/typst-navigator/blob/0.1.5/examples/markers.pdf))

## Acknowledgement 

Thanks to the [presentate package author](https://github.com/pacaunt/typst-presentate) for his constructive feedback and insights.

## Changelog

### 0.1.5
- **Bug fix**: Replaced the `context`+`measure()` approach introduced in 0.1.4 with the original `hide(grid(...))` trick. The `measure()` inside a nested `context` block caused "layout did not converge within 5 attempts" warnings when `progressive-outline` was called from within an existing `context` block (e.g. headers, footers, breadcrumbs). The `hide(grid)` approach handles both fixed-width and `auto`-width cases without triggering extra layout passes.

### 0.1.4
- **New example**: Touying 0.7.3 integration using `new-section-slide-fn`/`new-subsection-slide-fn` hooks with `slide-level: 3` for heading-driven slide creation and per-slide titles.
- **Bug fix**: Fixed horizontal layout in `progressive-outline` where items would overlap when `width: auto` (out-of-flow `place()` was collapsing the block width to zero).
- **Improved anti-jitter**: Replaced the internal `grid`/`0pt` ghost-row trick with a `measure()`-based approach that explicitly reserves the maximum height and width across all states.
- **Better error messages**: `render-transition` now panics with two concrete fix examples when `slide-func` is missing.
- **Docstrings**: Added comprehensive docstrings for `get-structure`, `render-miniframes`, `render-transition`, and `progressive-outline`.

### 0.1.3
- **Global Configuration**: Introduced `navigator-config` to centralize mapping, colors, slide functions, and component defaults.
- **Automation**: `render-transition`, `render-miniframes`, and `progressive-outline` now automatically resolve parameters from the global configuration.
- **Visual Stability**: Standardized font weights and improved the "anti-jitter" mechanism in `progressive-outline` to prevent overlaps and jumping when titles change state.
- **Title Management**: Full support for manual **Short Titles** (via `#metadata("...") <short>`) and automatic truncation across all components.
- **Visibility & Contrast**: Improved default opacities and colors for inactive items to ensure readability on dark backgrounds.
- **Robustness**: Enhanced dictionary merging and secured internal state access.

### 0.1.2
- **Transition improvements**: Added `content-padding`, `content-align`, and `content-wrapper` for total layout control.
- Added `format-heading` and `headings` filtering.

### 0.1.1
- Added `top-padding` to `render-transition`.

### 0.1.0
- First release.
