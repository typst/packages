# na-arabox

`na-arabox` is a Typst package for creating Arabic boxes that support Right-to-Left (RTL) text direction.

## Features
- **RTL Support**: Designed specifically for Arabic content.
- **Customizable**: Control title, colors, radii, and more.
- **Shadow Effect**: Optional shadow to give depth to your boxes.

## Usage

```typst
#import "@preview/na-arabox:0.1.0": na-arabox

#na-arabox(
  title: "ملاحظة",
  [هذا محتوى الصندوق باللغة العربية.]
)

// With shadow effect:
#na-arabox(
  title: "تنبيه",
  shadow: true,
  [هذا صندوق مع تأثير ظل.]
)
