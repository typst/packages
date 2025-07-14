# Architecture

The source code is organized as follows:

- `rust_tools`: Rust wrappers of existing libraries or utility functions
- `src`: Typst source

The file structure:

```mermaid
graph BT
src -- "WASM plugin" --> rust_tools

subgraph src
    direction BT
    components --> config.typ
    components --> utils.typ
    
    config.typ --> themes.typ
    lib.typ --> components
end
```

The content of Typst files and directories:

- `utils/`: wrappers and data processing logic
- `components/`: visual components, mostly `content` type
- `config.typ`: configurations
- `lib.typ`: entrypoint, exposes public functions
- `themes.typ`: color themes

The dependency graph of components:

```mermaid
graph LR
invoice --> header
invoice --> item-list
invoice --> vat-section
invoice --> payment-info

header --> legal-entity

item-list --> item-row

vat-section --> vat-row

payment-info --> bank-barcode
payment-info --> bank-qrcode
```
