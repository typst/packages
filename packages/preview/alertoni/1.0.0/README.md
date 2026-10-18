![The banner of the package, which says "Alertoni" with each syilable split up and put into separate callout boxes](docs/banner.svg)

# Alertoni

A Typst package that introduces callouts with three different styles and various types. In addition, the package also supports custom styles, types and icon sets.


- Read more on how to use it and other functionality in the [Manual](./docs/manual.pdf).

## Quick Examples

```typst
#import "@preview/alertoni:1.0.0" as at
```

### All Predefined Types

```typst
#at.callout(type: "info", [])
#at.callout(type: "warning", [])
#at.callout(type: "important", [])
#at.callout(type: "caution", [])
#at.callout(type: "tip", [])
#at.callout(type: "correct", [])
#at.callout(type: "incorrect", [])
#at.callout(type: "example", [])
```

![a collection of all types with the default style `"minimal"`](docs/images/all-types.png)

### All Predefined Styles

**Note**: you can add your own style. Refer to the manual.

```typst
#at.callout(
    style: "minimal", [Style `"minimal"`]
)

#at.callout(
    style: "quarto", [Style `"quarto"`]
)

#at.callout(
    style: "compact", [Style `"compact"`]
) -- it is also an inline style.
```

![a collection of all callout styles](docs/images/all-styles.png)

### A Custom Type

```typst
#at.new-type(
    name: "hey",
    color: olive,
    placeholder: "Hello There!",
    icon: emoji.hand.wave
)

#at.callout(type: "hey", [
    #lorem(20)
])
```


![a custom callout type called "hey", that adds a olive coloured callout with "Hello There!" as title and a wave emoji as icon](docs/images/new-type.png)

Types can also be langnuage specific and is explained in the manual.
