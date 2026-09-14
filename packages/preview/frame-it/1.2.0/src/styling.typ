/*
 * This file mainly exports functionality needed when writing your own styling function.
 */
#let divide() = metadata("THIS-IS-METADATA-TO-BE-REPLACED-BY-CUSTOM-STYLING-PER-STYLING-FUNCTION")

#let dividers-as(divider-element) = (
  document => {
    show metadata: it => if it == divide() {
      divider-element
    } else {
      it
    }
    document
  }
)
