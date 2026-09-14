# Slipst

Slipst is a package for creating dynamic presentations in Typst, inspired by [slipshow](https://slipshow.org).

It introduces a novel way of structuring presentations using "slips" that scroll from top to bottom, instead of relying on fixed-size slides. This frees presenters from the constraints of slide dimensions.

Slipst works with Typst's HTML export feature to create interactive presentations in web browsers.
For current version (0.14) of Typst, extra flags are needed to enable HTML export:

```bash
typst compile your-presentation.typ --format html --features html
```

## Quick Start

```typst
#import "@preview/slipst:0.2.0": *
#show: slipst

= First Slip

The document flows from top to bottom.
Whenever a `#pause` is encountered, the presentation will pause here,
waiting for the presenter to navigate to the next slip.

#pause

= Second Slip

The second slip appears after navigating down.
```

Refer to the [tutorial](https://slipst.wybxc.cc/tutorial.html) for a more comprehensive guide.

## References

### Setup

To turn your Typst document into a slipst presentation, apply the `slipst` show rule:

```typst
#show: slipst
```

You can customize the presentation using the `slipst.with()` function:

```typst
#show: slipst.with(
  width: 16cm,
  spacing: auto,
  margin: 0.5cm,
  show-fn: it => it
)
```

**Parameters:**

- `width`: The width of the presentation area.
- `spacing`: Vertical spacing between slips. Default is `auto` (same as `par.spacing`).
- `margin`: Margin between the presentation area and the viewport edges.
- `show-fn`: A function that takes slip content and returns the displayed content, allowing custom decorations or wrappers.

> **Note:** The values for `width`, `spacing`, and `margin` are _logical lengths_. They scale proportionally with screen size to maintain consistent relative spacing across different devices.

### Animations

Use `#pause` to define where one slip ends and the next begins. It takes no parameters.

```typst
#pause
```

The `#up` command makes the selected slip slide upward out of view when the current slip is displayed. It accepts a [selector](https://typst.app/docs/reference/foundations/selector/) as its argument.

```typst
#up(<label>)
```

A common pattern is to label a `#pause` and reference it in `#up`:

```typst
#pause <first-slip>
...
#up(<first-slip>)
```

You can also provide an `offset` to `#up` to select a slip relative to the chosen selector. For example, to slide up the slip immediately before the selected one:

```typst
#up(<label>, offset: -1)
```

For dynamic selections, `#up` can also accept a function that returns a selector. This is useful with context-aware selectors like [`here()`](https://typst.app/docs/reference/introspection/here/). Combined with `offset`, you can slide up the previous slip without an explicit label:

```typst
#up(it => here(), offset: -1)
```

## Roadmap

- Basic slip functionality with up/down navigation.
- Persistent state across sessions.
- (TODO) Slips replacement animations, as well as Cetz and Flether animations.
- (TODO) Custom aspect ratios for the visual area.
- (TODO) Visual structure for subslips.
- (TODO) Whiteboard mode for live drawing.
- (TODO) Advanced navigation.
- (TODO) PDF handout export.

## Changelog

### 0.2.0

- The generated HTML no longer depends on CDN resources, enabling fully offline use.
- Progress is now controlled and persisted via the URL hash instead of session storage.
- Spacing between slips and page margins now scale with the screen size and can be customized in the `show` rule.
- Added support for gesture navigation (swipe up/down) on touch devices.

### 0.1.0

- Initial release with basic slip presentation functionality.
