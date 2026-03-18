# clatter - PDF417 Barcode Generator

clatter is a simple Typst package for generating PDF417 barcodes, utilizing the [rxing](https://github.com/rxing-core/rxing) library.

## Features

- **Easy to Use**: The package provides a single, intuitive function to generate barcodes.
- **Flexible Sizing**: Control the size of the barcode with optional width and height parameters.
- **Customizable Orientation**: Barcodes can be rendered horizontally or vertically, with automatic adjustment based on size.

## Usage

The primary function provided by this package is `pdf417`. 

### Parameters

- `text` (required): The text to encode in the barcode.
- `width` (optional): The desired width of the barcode.
- `height` (optional): The desired height of the barcode.
- `direction` (optional): Sets the orientation of the barcode, either `"horizontal"` or `"vertical"`. If not specified, the orientation is automatically determined based on the provided dimensions.

### Sizing Behavior

- By default, the barcode is rendered horizontally at a reasonable size.
- If both `width` and `height` are provided, the barcode will fit within the specified dimensions (i.e. `fit: "contain"`).
- If the `height` is greater than the `width`, the barcode will automatically switch to vertical orientation unless `direction` is manually set.

### Example Usage

```typst
#import "@preview/clatter:0.1.0": pdf417

// Generate a sized horizontal PDF417 barcode 
// Note: The specified size may not be exact, as the barcode will fit within the box, maintaining its aspect ratio.
#pdf417("sized-barcode", width: 50mm, height: 20mm)

// Generate a vertical barcode
#pdf417("vertical-barcode", direction: "vertical")

// Generate a barcode and position it on the page
#place(top + right, pdf417("absolutely-positioned-barcode", width: 50mm), dx: -5mm, dy: 5mm)
```

---

<small>Of course, such a lengthy README can't be written without the help of ChatGPT.</small>
