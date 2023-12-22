# [Cades](https://github.com/Midbin/cades)

Draw QR codes in typst.

```typ
#import "@preview/cades:0.2.0": qr-code

= QR Code for `typst.app`:
#qr-code("https://typst.app", width: 3cm)

```

## Documentation

### `qr-code`

Draw a qr code to an image.

#### Arguments

* `content`: `str` - the content of the qr code
* `width`: `length`|`auto` - the width of the qr code, default is `auto`
* `height`: `length`|`auto` - the height of the qr code, default is `auto`
* `color`: `color` - the color of the qrcode, default is `black`
* `background`: `color` - the background color behind the qrcode, default is `white`

#### Returns

The image, of type `content`.

## Acknowledgements

This package uses [Jogs](https://github.com/Enter-tainer/jogs) by [Wenzhuo Liu](https://github.com/Enter-tainer) and the qr code rendering code is based on [qrcode-svg](https://github.com/papnkukn/qrcode-svg/) by [papnkukn](https://github.com/papnkukn).