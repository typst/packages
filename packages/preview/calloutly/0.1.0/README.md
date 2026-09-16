# typst-callout
typst package to enable markdown-style callout blocks

This package defines a `callout` component that can be used to create styled callout boxes in your Typst documents. It supports different types of callouts (note, tip, important, warning, caution) with customizable colors and icons.

The icons are embedded directly as svgs in the package, removing any external dependencies. The package also includes two styles: "simple" and "quarto", which can be easily switched by changing the `style` parameter. Shortcut macros are provided for each callout type to simplify usage.

# Usage
To use the callout package, simply import it at the beginning of your Typst document:

```typst
#import "@preview/calloutly:0.1.0" : callout, note, tip, important, warning, caution
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

You can also customise the colours and icons by using the `callout` component directly with additional parameters.

# Planned Features
- Additional styles (e.g. "fancy", "minimal", "Edstem")
- Make the callout blocks referenceable with traditional Typst referencing
- Make callouts compatible with either `#show` or `#set` rules for easy customisation of the default styles