# Control Blocks

Draw Control Blocks using [fletcher](https://github.com/Jollywatt/typst-fletcher) and [CeTZ](https://github.com/cetz-package/cetz).

## Usage

![example](https://raw.githubusercontent.com/ivaquero/typst-control-block/refs/heads/main/0.1.0/example.png)

For more details, see [examples.typ](examples/example.typ).

## Get the Package

### Clone Official Repository

To compile, please refer to the guide on [typst-packages](https://github.com/typst/packages) and clone this repository to your `@local` workspace:

- Linux：
  - `$XDG_DATA_HOME/typst/packages/local`
  - `~/.local/share/typst/packages/local`
- macOS：`~/Library/Application\ Support/typst/packages/local`
- Windows：`%APPDATA%/typst/packages/local`

### Import the Package

Clone the [control-block](https://github.com/ivaquero/typst-control-block) repository in the above path

```bash
git clone https://github.com/ivaquero/typst-control-block control-block
```

and then import it in the document

```typst
#import "@local/control-block:0.1.0": *
```
