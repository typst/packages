# rustycure - fast QR codes in typst

rustycure generates QR codes in typst.
The implementation is written in Rust and compiled to WASM.

## Usage

### Simple QR code

```typst
#import "@preview/rustycure:0.1.0": qr-code

#qr-code("https://typst.app/")

https://typst.app/ // Remember to always have a human readable representation of your qr code!
```

### Image options

rustycure proxies every (non image-encoding) option of the `image` function:

```typst
#qr-code(
  "Bier",
  width: 40%,
  height: 20%,
  alt: "A QR code that shows the german word for beer.",
  fit: "contain"
)
```

`alt` additionally can be set to `auto` (this is the default value). In this case, the alt text will be set to the string representation of your QR code data.

### QR code options

rustycure lets you configure some QR code options:

```typst
#qr-code(
  "Wir können die Bürde unserer Freiheit nicht auf andere übertragen.",
  quiet-zone: false,
  dark-color: "#0000ff",
  light-color: "#ff0000"
)
```

- The **quiet zone** is from the QR code spec: It defines a padding of (at least) 4 modules around the QR code. If you'd rather define padding by yourself, then set `quiet-zone` to `false`. Remember that your QR code may become less scannable if you provide too few space around it!
- The **dark** and **light color** control the look of the QR code. Set it to some hex string like in the example above or leave it to get a standard black and white QR code.

### Raw SVG data

Lastly, if (for some use case I don't know) you need the raw QR code SVG data, you can import the `qr-svg` function for that:

```typst
#import "@preview/rustycure:0.1.0": qr-code, qr-svg

// Both of these functions do the same:
#qr-code("https://en.wikipedia.org/wiki/QR_code") 
#image(qr-svg("https://en.wikipedia.org/wiki/QR_code"))
```

It takes the same QR code options listed above.
Please let me know if you have found some valid use case for this - I am curious!
