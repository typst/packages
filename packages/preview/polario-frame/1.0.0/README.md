## Polario Frame
**`polario-frame`** is an easy-to-use photo frame package for Typst. It provides multiple themes and image cropping utilities to create your photo frames. `polario` is derived from **Polaroid**, reflecting the aspiration for this tool to deliver desired photos as quickly as a Polaroid camera.

## Simple Usage
1. Import the `polario-frame` package:

```typst
#import "@preview/polario-frame:1.0.0": *
```

2. Use the crop utility to crop the image:

```typst
#let img = crop(bytes(read("simple.jpg", encoding: none)), start: (25%, 25%), resize: 75%)
```

3. Use `polario-frame` to render the photo frame:

```typst
#let ext-info = (
    "first": image("logo/apple.svg"),
    "second": text(size: 22pt)[This is the title],
    "third": text(size: 8pt)[Kunming\ Lijiang],
    "extend-middle-ratio": 65%,
    "background": rgb("#ffffffee"),
)
#render((width, height), flipped: false, theme: "classic-bottom-three", img: img, ext-info: ext-info)
```

This makes it easy to add the `classic-bottom-three` frame to the photo.

Rendering result
![A page displaying the same photograph with four different frames, showing the camera settings, brand and the date in different styles](https://raw.githubusercontent.com/NPCRay/polario-frame/bca5fb6752e4784827d455ada1442364c0f43d37/example/example.png)

If you need other theme frames, check the [example](https://github.com/NPCRay/photo-frame/blob/master/example). It contains default themes, custom themes, and examples of popular smartphone brand frames. If you find that the basic themes don't cover your needs, please submit an issue or PR.

## Basic Theme Parameters
### Render Parameters
- `size`: Can be passed as a tuple like `(width, height)`, or standard paper names like `A1`~`A11`
- `flipped`: Whether to flip, default is false
- `theme`: Frame theme, available values `classic-bottom-two` `classic-bottom-three` `classic-right-two` `classic-right-three` `polaroid-bottom-two` `polaroid-bottom-three` `polaroid-right-two` `polaroid-right-three`
- `img`: Image, should be cropped before passing
- `ext-info`: Frame extended information, determined according to theme

### Supported ext-info Properties
- `first`: The first element from left to right or top to bottom, empty by default
- `second`: The second element from left to right or top to bottom, empty by default
- `third`: The third element from left to right or top to bottom, empty by default (only supported by *-three themes)
- `extend-ratio`: Extended white border width ratio, default 10%
- `extend-half-ratio`: Extended white border first element ratio, default 50% (only supported by *-two themes)
- `extend-middle-ratio`: Extended middle element ratio, default 20% (only supported by *-three themes)
- `background`: Background color, none by default
- `inset-ratio`: Padding ratio, no inset by default 3% (only supported by polaroid-* themes)

## Versions

### 1.0.0
- Official version
- Provides 8 basic theme styles `classic-bottom-two` `classic-bottom-three` `classic-right-two` `classic-right-three` `polaroid-bottom-two` `polaroid-bottom-three` `polaroid-right-two` `polaroid-right-three` frames
- Provides cropping tool `crop`
- Added more examples in example folder

### 0.1.0
- Initial release