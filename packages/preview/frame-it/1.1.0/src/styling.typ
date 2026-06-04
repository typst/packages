/*
 * This file exports functionality needed when writing your own styling function.
 */

#let dividers-as(divider-element) = (
  it => {
    import "bundled-layout.typ": DIVIDE-IDENTIFIER
    show figure.where(kind: DIVIDE-IDENTIFIER): divider-element

    it
  }
)
