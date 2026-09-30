#let repeat(
  copies: auto,
  duplex: false,
  back: none,
  back-rotation: 180deg,
  flip: "long-edge",
  body,
) = (
  kind: "repeat",
  copies: copies,
  duplex: duplex,
  back: back,
  back-rotation: back-rotation,
  flip: flip,
  body: body,
)

#let variants(
  items: auto,
  order: "forward",
  duplex: false,
  back-rotation: 180deg,
  flip: "long-edge",
) = (
  kind: "variants",
  items: items,
  order: order,
  duplex: duplex,
  back-rotation: back-rotation,
  flip: flip,
)

#let sequence(
  count: auto,
  item: auto,
  flow: "cut-stack",
  stack-flow: auto,
  order: "forward",
  stack-size: auto,
) = (
  kind: "sequence",
  count: count,
  item: item,
  flow: flow,
  stack-flow: stack-flow,
  order: order,
  stack-size: stack-size,
)

#let pdf(
  source,
  source-name: none,
  page: 1,
  fit: "stretch",
  alt: none,
  copies: auto,
  duplex: false,
  back-source: none,
  back-source-name: auto,
  back-page: 1,
  back-fit: auto,
  back-alt: none,
  back-rotation: 180deg,
  flip: "long-edge",
) = (
  kind: "pdf",
  source: source,
  source-name: source-name,
  page: page,
  fit: fit,
  alt: alt,
  copies: copies,
  duplex: duplex,
  back-source: back-source,
  back-source-name: back-source-name,
  back-page: back-page,
  back-fit: back-fit,
  back-alt: back-alt,
  back-rotation: back-rotation,
  flip: flip,
)

#let booklet(
  source,
  source-name: none,
  page-count: auto,
  fit: "stretch",
  alt: none,
  creep: 0pt,
  blank-policy: "error",
  binding: "left",
  reading-direction: "ltr",
  order: "forward",
) = (
  kind: "booklet",
  source: source,
  source-name: source-name,
  page-count: page-count,
  fit: fit,
  alt: alt,
  creep: creep,
  blank-policy: blank-policy,
  binding: binding,
  reading-direction: reading-direction,
  order: order,
)

#let marks-only(regions: auto) = (
  kind: "marks-only",
  regions: regions,
)

#let calibration(
  flip: "long-edge",
  back-rotation: 180deg,
) = (
  kind: "calibration",
  flip: flip,
  back-rotation: back-rotation,
)
