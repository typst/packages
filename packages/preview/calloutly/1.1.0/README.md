# typst-callout
typst package to enable markdown-style callout blocks

This package defines a `callout` component that can be used to create styled callout boxes in your Typst documents. It supports different types of callouts (note, tip, important, warning, caution) with customizable colors and icons.

The icons are embedded directly as svgs in the package, removing any external dependencies. The package also includes two styles: "simple" and "quarto", which can be easily switched by changing the `style` parameter. Shortcut macros are provided for each callout type to simplify usage.

## Usage
To use the callout package, simply import it at the beginning of your Typst document:

```typst
#import "@preview/calloutly:1.1.0" : callout-style, callout, note, tip, important, warning, caution, code-block-style
```

Then you can create callouts like this:

```typst
#note[This is a note callout.]
#tip[This is a tip callout.]
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

There are 3 main styles for the callout blocks: "simple", "quarto", and "Github". Should the style be not one of these 3, it will default to "simple". 

## Show Rules
To set the style for all callouts in the document, you can use the `callout-style` with a show rule at the beginning of your document:
```typst
#show: callout-style.with(style: "quarto")
```
The shortcoming with this option is that it applies the style to all callouts in the document, and any callout that specifies a style will be ignored. This is because the show rule overrides the default rendering rules for callouts, so any callout that does not specify a style will use the style defined in the show rule, and any callout that does specify a style will be ignored because the show rule takes precedence. 

You can also set a numbering rule in the same way, but this will also apply to all callouts in the document and override any numbering rules specified in individual callouts. This is done exactly the same way as the style, but with `numbering` instead of `style`:
```typst
#show: callout-style.with(numbering: "1")
```
When numbering is enabled, the callout headers will be automatically numbered according to the specified numbering format. For example, if you set `numbering: "1."`, the callouts will be numbered as "Note 1.", "Tip 2.", etc. If you set `numbering: "A."`, they will be numbered as "Note A.", "Tip B.", etc.

Callout blocks are now also referenceable! You can give them an id and refer to them using `@` syntax, and they will be numbered according to the numbering rules specified in the callout style. Note that for the time being this only makes sense for numbered callouts. For example:
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
- `style` (string): The visual style applied to code callouts (e.g. `"simple"`, `"quarto"`, `"github"`). Defaults to `"simple"`.
- `line-numbers` (boolean): Set to `true` to display line numbers. Because they are rendered in a separate layout grid, you can select and copy the code text naturally without inadvertently selecting the line numbers alongside it.

When enabled, standard code blocks will be seamlessly transformed with the corresponding syntax-highlighting icon, inner shading, and border outlines matching the active style.

## Planned Features
- Additional styles (e.g. "fancy", "minimal", "Edstem")
- Stable line numbering with code blocks with excessively long lines.


## Submit an issue or pull request if you have any suggestions for improvements or new features!
Go to my linked GitHub repository to submit an issue or pull request, and I will happily review it and merge it if it's a good addition to the package. I am open to any suggestions for improvements or new features, so please don't hesitate to reach out!
