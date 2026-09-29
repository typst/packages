#import "utils.typ": apply-sans-font
#import "i18n.typ": i18n, i18n-translation

#show: apply-sans-font.with(other-fonts: ("Verdana",))
#set text(size: 10pt)
#show heading.where(level: 1): it => {
  set text(size: 11pt)
  show: strong
  set block(spacing: 2em, inset: 0pt)
  it
}
#set page(margin: (
  top: 3cm,
  left: 2.5cm,
  bottom: 2cm,
  right: 2.27cm,
))

#context heading(i18n-translation("declaration", text.lang))

#i18n("declaration-content")

#v(1.5cm)
#grid(
  columns: (2fr, 1fr),
  [#i18n("date")], [#i18n("signature")],
)
