# Calloutly

typst package to enable markdown-style callout blocks

This package defines a `callout` component that can be used to create styled callout boxes in your Typst documents. It supports seven types of callout (note, tip, important, warning, caution, success, error) with customizable colors and icons.

The icons are embedded directly as svgs in the package, removing any external dependencies. The package includes four styles -- "simple", "quarto", "github" and "edstem" -- which can be easily switched by changing the `style` parameter. Shortcut macros are provided for each callout type to simplify usage.

## Usage

To use the callout package, simply import it at the beginning of your Typst document:

```typst
#import "@preview/calloutly:1.2.0" : calloutly, callout-style, callout, note, tip, important, warning, caution, success, error, code-block-style
```

Then you can create callouts like this:

```typst
#note[This is a note callout.]
#tip[This is a tip callout.]
#success[This is a success callout.]
#error[This is an error callout.]
#callout(type: "important")[This is an important callout with the default style.]
#callout(style: "quarto", type: "warning")[This is a warning callout with the quarto style.]
#caution[This is a caution callout using the shortcut macro.]
```

To specify a custom title, you can use the `title` parameter:

```typst
#callout(type: "note", title: "Custom Note")[This is a note callout with a custom title.]
```

You can also customise the colours and icons by using the `callout` component directly with additional parameters. E.g. to set a custom colour and icon for a tip callout:

```typst
#callout(type: "tip", color: rgb("#000000"), icon: "💡")[This is a tip callout with a custom colour and icon.]
```

There are 4 styles for the callout blocks: "simple", "quarto", "github" and "edstem". Should the style not be one of these 4, it will default to "simple".

- **simple** -- an accent bar down the left, title above the body.
- **quarto** -- a rounded, outlined box with a tinted header strip.
- **github** -- GitHub's alert palette, with a thick accent bar.
- **edstem** -- EdStem's alert pallette, with a ribbon header and a tiled background.

Callouts render on their own, so `#note[...]` looks right in a document with no show rule at all -- import the package and start typing. The show rules below are only needed to force one style across the whole document, to switch numbering on, or to style code blocks.

## Show Rules

The quickest setup is `calloutly`, which turns on callout styling and code-block styling together:

```typst
#show: calloutly.with(style: "edstem", numbering: "1", line-numbers: true)
```

Note this is simply a wrapper for `callout-style` and `code-block-style`; use them individually if you want to fine-tune the settings.

> [!NOTE]
> To show code blocks, you must apply the show rule.

To set the style for all callouts in the document, you can use the `callout-style` with a show rule at the beginning of your document:

```typst
#show: callout-style.with(style: "quarto")
```

The show rule sets the *default* style for callouts in its scope. This can be individually overridden on a per-callout basis by specifying the `style` parameter in the callout macro:

```typst
#show: callout-style.with(style: "quarto")
#note[This one is quarto.]
#note(style: "edstem")[This one stays edstem.]
```

The order of precedence is: the style on the block, then the style on the nearest `callout-style` show rule, then the package default (`"simple"`). Raw code fences are the exception -- there is nowhere to hang an argument on a ``` fence, so code blocks always take whatever `code-block-style` sets.

You can also set a numbering rule in the same way, but this will also apply to all callouts in the document and override any numbering rules specified in individual callouts. This is done exactly the same way as the style, but with `numbering` instead of `style`:

```typst
#show: callout-style.with(numbering: "1")
```

When numbering is enabled, the callout headers will be automatically numbered according to the specified numbering format. For example, if you set `numbering: "1."`, the callouts will be numbered as "Note 1.", "Tip 2.", etc. If you set `numbering: "A."`, they will be numbered as "Note A.", "Tip B.", etc.

Callout blocks are also referenceable! You can give them an id and refer to them using `@` syntax, and they will be numbered according to the numbering rules specified in the callout style. Note that for the time being this only makes sense for numbered callouts. For example:

```typst
#show: callout-style.with(numbering: "1")
#note[This is a note callout that can be referenced.]<my-ref>
@my-ref
```

## Code Blocks

You can also automatically format your raw code blocks as callout boxes with language-specific icons!

To enable this globally, apply the `code-block-style` show rule at the beginning of your document:

```typst
#show: code-block-style.with(style: "github", line-numbers: true)
```

Parameters available for `code-block-style`:

- `style` (string): The visual style applied to code callouts (`"simple"`, `"quarto"`, `"github"` or `"edstem"`). Defaults to `"simple"`.
- `line-numbers` (boolean): Set to `true` to display line numbers.

When enabled, standard code blocks will be seamlessly transformed with the corresponding syntax-highlighting icon, inner shading, and border outlines matching the active style. Fence languages are matched case-insensitively and common aliases are understood, so ```` ```Python ````, ```` ```py ```` and ```` ```python ```` all get the same icon and the same `Python` header label.

### Copying the code

Because the gutter is its own grid cell, the numbers are written into the PDF as one contiguous run *before* the code, instead of being interleaved line by line. This means that you can now select/highlight the code without accidentally selecting the line numbers, which is a common annoyance in other PDF viewers. 

## Planned Features

- Additional styles (e.g. "fancy", "minimal")

## Submit an issue or pull request if you have any suggestions for improvements or new features

Go to my linked GitHub repository to submit an issue or pull request, and I will happily review it and merge it if it's a good addition to the package. I am open to any suggestions for improvements or new features, so please don't hesitate to reach out!
