# Consketcher

Draws Control Sketches using [fletcher](https://github.com/Jollywatt/typst-fletcher) and [CeTZ](https://github.com/cetz-package/cetz).

## Get Started

Import `consketcher` from the `@preview` namespace.

```typst
#import "@preview/consketcher:0.1.0": *
```

![example](https://raw.githubusercontent.com/ivaquero/typst-consketcher/refs/heads/main/0.1.0/example.png)
![example2](https://raw.githubusercontent.com/ivaquero/typst-consketcher/refs/heads/main/0.1.0/example2.png)

For more details, see [examples.typ](https://github.com/ivaquero/typst-consketcher/blob/main/0.1.0/examples/example.typ).

## Clone Official Repository

To compile, please refer to the guide on [typst-packages](https://github.com/typst/packages) and clone this repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

Clone the [consketcher](https://github.com/ivaquero/typst-consketcher) repository in the above path

```bash
git clone https://github.com/ivaquero/typst-consketcher consketcher
```

and then import it in the document

```typst
#import "@local/consketcher:0.1.0": *
```
