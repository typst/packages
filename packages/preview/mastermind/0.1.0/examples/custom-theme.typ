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
