// # Outline entry. Entrada de sumário.

#let format_outline_entry = it => {
  link(
    it.element.location(),
    it.indented(
      it.prefix(),
      sym.dash.em + sym.space + it.inner(),
    ),
  )
}
