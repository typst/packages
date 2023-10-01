# Codetastic (v0.2.2)

**Codetastic** is a [Typst](https://github.com/typst/typst) package for drawing barcodes and 2d codes.

## Usage

For Typst 0.6.0 or later, import the package from the Typst preview repository:

```typst
#import "@preview/codetastic:0.2.2"
```

After importing the package call any of the code generation functions:
```typst
#import "@preview/codetastic:0.2.2": ean13, qrcode

#ean13(4012345678901)

#qrcode("https://github.com/typst/typst")
```

The output should look like this:
![Example for codes drawn with Codetastic](assets/example.png)

## Further documentation

See `manual.pdf` for a full manual of the package.

## Development

The documentation is created using [Mantys](https://github.com/jneug/typst-mantys), a Typst template for creating package documentation.

To compile the manual, Mantys needs to be available as a local package. Refer to Mantys' manual for instructions on how to do so.

## Changelog

### Version 0.2.2
- qrcodes:
	- Fixed issue with alignment pattern placement.
	- Removed minimal borders around modules for sharper edges with small module sizes.

### Version 0.2.1

- qrcodes:
	- Fixed wrong sizing for `width` key.
		- The code didn't take the quiet zone into account.
	- Moved debug information into quiet zone.

### Version 0.2.0

- Removed CeTZ as a dependecy.
	- Now using native Typst drawing functions.
- Hugh speed improvements for large QR-Codes.
- Fixed issue with checksum calculation for gtin/ean codes.

### Version 0.1.0

- Initial release submitted to [typst/packages](https://github.com/typst/packages).
