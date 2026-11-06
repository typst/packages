#import "../config/constants.typ": special-chapter-titles-default-value, thesis-info-default-value, digital-signature-option-default-value

#let default-header-text-state = state(
  "default-header-text",
  "哈尔滨工业大学学位论文"
)

#let special-chapter-titles-state = state(
  "special-chapter-titles",
  special-chapter-titles-default-value
)

#let bibliography-state = state("bibliography")

#let thesis-info-state = state(
  "thesis-info",
  thesis-info-default-value,
)

#let digital-signature-option-state = state(
  "digital-signature",
  digital-signature-option-default-value,
)