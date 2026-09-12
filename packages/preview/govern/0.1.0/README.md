# govern

A clean, traditional Typst template for formal governance documents, bylaws, and articles.

## Usage

```typst
#import "@preview/govern:0.1.0": govern

#set document(title: "Serious Bylaws", author: "The General Assembly")

#show: govern.with(adoption-date: datetime(year: 1970, month: 1, day: 1), draft: false)

= Organization

== Name
#lorem(10)

== Object
#lorem(15)

= Officers

== Officers and Duties
+ #lorem(20)
+ #lorem(25)

== Elections
+ #lorem(10)
+ #lorem(5)
+ #lorem(20)
```

| Parameter       | Type                 | Default            | Description                                              |
|:----------------|:---------------------|:-------------------|:---------------------------------------------------------|
| `adoption-date` | `datetime` or `none` | `datetime.today()` | The official date of adoption displayed on the document. |
| `draft`         | `boolean`            | `false`            | Places a "DRAFT" watermark across all pages.             |

It also utilizes and requires `document.title` and `document.author`.
