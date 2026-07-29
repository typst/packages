# mastermind

[![Package version 0.1.0](https://img.shields.io/badge/package-v0.1.0-239dad?logo=typst)](https://typst.app)
[![Gitlab Repo](https://img.shields.io/badge/gitlab-repo-blue?logo=gitlab)](https://gitlab.com/zani.manuel328/mastermind)
[![License: GPLv3](https://img.shields.io/badge/license-GPLv3-green)](https://www.gnu.org/licenses/gpl-3.0.html)

# Usage

- Import the package:

```typst
#import "@preview/class-diagram:0.1.0": *
```

- Create the list of classes:

```typst
#let classes = (
  animal: class(
    (0, 0),
    "Animal",
    type: "interface",
    attributes: ("+age: int", "+gender: String"),
    methods: ("+isMammal()", "+mate()"),
  ),
  // ...
)
```

- Create the list of relationships:

```typst
#let relationships = (
  inheritance(classes.animal, classes.duck),
  // ...
)
```

- Draw the diagram:

```typst
#draw-class-diagram(classes, relationships, themes.default)
```

Available relationships:
- `inheritance`
- `implementation`
- `association`
- `dependency`
- `aggregation`
- `composition`

# Showcase

*Theme inspired by Fairly OddParents pixies:*

<p align="center">
  <img src="thumbnails/pixies.png" alt="UML diagram with a theme inspired by Fairly OddParents pixies"/>
</p>
<details>
  <summary>See the source code</summary>
  
```typ
#import "@local/class-diagram:0.1.0": *

#set page(width: auto, height: auto)

#let classes = (
  order: class(
    (0, 0),
    "Order",
    attributes: ("+id: String", "+status: OrderStatus"),
    methods: ("+total()", "+submit()"),
  ),
  order-line: class(
    (-5, 0),
    "OrderLine",
    attributes: ("+quantity: int", "+unitPrice: Money"),
    methods: ("+subtotal()",),
  ),
  product: class(
    (-10, 0),
    "Product",
    attributes: ("+sku: String", "+name: String"),
    methods: ("+rename(name)",),
  ),
  customer: class(
    (0, 6),
    "Customer",
    attributes: ("+id: String", "+email: String"),
    methods: ("+placeOrder()",),
  ),
  payment: class(
    (0, -5),
    "Payment",
    type: "abstract",
    attributes: ("+amount: Money",),
    methods: ("+authorize()", "+capture()"),
  ),
  card-payment: class(
    (5, -5),
    "CardPayment",
    attributes: ("-last: String",),
    methods: ("+authorize()",),
  ),
  invoice: class(
    (6, 0),
    "Invoice",
    attributes: ("+number: String", "+issuedAt: Date"),
    methods: ("+markPaid()",),
  ),
)

#let relationships = (
  composition(classes.order, classes.order-line),
  association(classes.order-line, classes.product),
  aggregation(classes.customer, classes.order),
  dependency(classes.order, classes.payment),
  inheritance(classes.payment, classes.card-payment),
  association(classes.order, classes.invoice),
)

#draw-class-diagram(classes, relationships, themes.pixies)
```
</details>

*You can also build your own custom theme:*

<p align="center">
  <img src="thumbnails/custom-theme.png" alt="UML diagram with a custom theme"/>
</p>
<details>
  <summary>See the source code</summary>
  
```typ
#import "@local/class-diagram:0.1.0": *

#set page(width: auto, height: auto)

#let custom-theme = theme(
  fill: orange,
  inset: 10pt,
  radius: 20pt,
  type-fill: yellow,
  type-radius: 20pt,
)

#let classes = (
  order: class(
    (0, 0),
    "Order",
    attributes: ("+id: String", "+status: OrderStatus"),
    methods: ("+total()", "+submit()"),
  ),
  customer: class(
    (0, 6),
    "Customer",
    attributes: ("+id: String", "+email: String"),
    methods: ("+placeOrder()",),
  ),
  payment: class(
    (-5, 0),
    "Payment",
    type: "abstract",
    attributes: ("+amount: Money",),
    methods: ("+authorize()", "+capture()"),
  ),
  card-payment: class(
    (-5, -5),
    "CardPayment",
    attributes: ("-last: String",),
    methods: ("+authorize()",),
  ),
  invoice: class(
    (6, 0),
    "Invoice",
    attributes: ("+number: String", "+issuedAt: Date"),
    methods: ("+markPaid()",),
  ),
)

#let relationships = (
  aggregation(classes.customer, classes.order),
  dependency(classes.order, classes.payment),
  inheritance(classes.payment, classes.card-payment),
  association(classes.order, classes.invoice),
)

#draw-class-diagram(classes, relationships, custom-theme)
```
</details>
