// pequi-ic-ufg: relatório final de Iniciação Científica (IC) da UFG (não oficial).

// Formata o relatório final de IC (UFG).
//
// - title (str): título do relatório.
// - authors (array): dicionários com `name`, `email`, `affiliation` e `role`.
// - font (str, array): fonte(s) do texto. O padrão é Arial, com Liberation Sans
//   (métricas equivalentes e licença livre) como alternativa.
#let report(
	title: "",
	authors: (),
	font: ("Arial", "Liberation Sans"),
	body,
) = {
	set document(author: authors.map(a => a.name), title: title)
	set page(
		paper: "a4",
		margin: (left: 20mm, right: 20mm, top: 20mm, bottom: 20mm),
		numbering: "1",
		number-align: end,
	)
	set text(
		font: font,
		lang: "pt",
		region: "br",
		size: 12pt,
		hyphenate: false,
	)
	set heading(numbering: "1.1.")

	// Links e URLs
	show link: underline
	show link: set text(fill: blue)

	// Referências e citações
	show ref: it => {
		strong[#it]
	}
	show cite: it => {
		box[#it]
	}

	// Figuras
	show figure: it => pad(rest: 0.5em, it)

	// Centralizar título e autores
	set align(center)
	
	// Linha do título
	block(text(weight: 700, 1.75em, title))

	// Informação do(s) autor(es)
	pad(
		rest: 0.5em,
		{ 
			for (index, author) in authors.enumerate(start: 1) [
				*#author.name*#super[#index]#if index < authors.len() [,]
			]

			[ \ ]
			
			for (index, author) in authors.enumerate(start: 1) [
				#super[#index]#author.role, #author.affiliation, #link("mailto:" + author.email)\
			]
		}
	)

	// Alinhar texto novamente à esquerda
	set align(left)

	// Corpo do texto
	set par(justify: true, spacing: 1.5em, leading: 0.5em)

	body
}

// Seção de apêndices: página com margens reduzidas, índice e numeração A1.
#let appendix(body) = {
	set page(
		paper: "a4",
		margin: (left: 10mm, right: 10mm, top: 10mm, bottom: 10mm),
	)

	set heading(numbering: none)
	[
		= Apêndice <apendice>
	]
	
	outline(target: heading.where(supplement: [Apêndice]), title: none)
	set heading(numbering: "A1.", supplement: [Apêndice])
	counter(heading).update(0)
	
	body
}