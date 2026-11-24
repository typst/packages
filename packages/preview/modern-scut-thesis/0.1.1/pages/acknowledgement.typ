// SCUT 致谢页
#import "../utils/section-break.typ": section-break

#let acknowledgement(
  open-right: false,
  title: "致　谢",
  outlined: true,
  body,
) = {
  section-break(open-right: open-right)

  heading(level: 1, numbering: none, outlined: outlined, title)

  body
}
