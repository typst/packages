# edgeframe (v0.1.0)

Custom margins and other components for page setup or layout.

## Usage

Add the package with the following code. Remember to add the asterisk `: *` at the end.

```typ
#include "@preview/edgeframe:0.1.0": *
```

```typ
#set page(margin: margin-normal)
```

## List of parameters

- margin-normal
- margin-narrow
- margin-moderate-x
- margin-moderate-y
- margin-wide-x
- margin-wide-y
- margin-a5-x
- margin-a5-y

> Parameters with `x` and `y` should to be used together
>
> ```
> #set page(margin: (x: margin-moderate-x, y: margin-moderate-y))
> ```
