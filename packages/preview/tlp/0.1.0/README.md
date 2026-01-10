# TLP (Traffic Light Protocol) Package for Typst

A Typst package to easily add Traffic Light Protocol (TLP) markings to your documents, fully compliant with **TLP v2.0 Standards** (CISA/FIRST).

## features

- **Header/Footer Support**: Easily mark every page of your document.
- **Content Blocks**: Distinct boxes for sensitive sections.
- **Inline Labels**: Insert TLP labels directly within text.

## Installation

Import the package:

```typst
#import "@preview/tlp:0.1.0"
```

## Usage

### 1. Document-Wide Marking (Recommended)

To mark the header and footer of every page (as required by standard for TLP documents):

```typst
#import "@preview/tlp:0.1.0"

// Set the whole document to TLP:AMBER
#show: tlp-setup.with("amber")

= My Sensitive Document
Content...
```

### 2. Specific Content Blocks

If you need to mark specific sections:

```typst
#tlp-red[
  This is highly sensitive TLP:RED info.
]

#tlp-green[
  This is TLP:GREEN info.
]
```

### 3. Inline Labels

```typst
This paragraph refers to #tlp-label("red") material.
```

## Available Levels

The following string keys are supported:
- `"red"` -> **TLP:RED**
- `"amber"` -> **TLP:AMBER**
- `"amber-strict"` -> **TLP:AMBER+STRICT**
- `"green"` -> **TLP:GREEN**
- `"clear"` -> **TLP:CLEAR**

## License

MIT
