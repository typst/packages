#import "@preview/touying:0.6.1": *
#import "@preview/shadowed:0.2.0": shadowed
#import "@preview/showybox:2.0.4"

// Colors definition
#let inerissemigreen   = rgb("#00AB8E")
#let inerissemiblue	= rgb("#003087")
#let inerissemiturq	= rgb("#1CA5D2")
#let inerissemipurple  = rgb("#8F6F95")
#let inerissemiorange  = rgb("#D87263")
#let theme-colors = (
	primary: inerissemiblue,
	primary-dark: inerissemiblue.darken(20%),
	primary-darker: inerissemiblue.darken(40%),
	primary-darkest: inerissemiblue.darken(60%),
	primary-light: inerissemiblue.lighten(20%),
	primary-lighter: inerissemiblue.lighten(40%),
	primary-lightest: inerissemiblue.lighten(60%),
	secondary: inerissemigreen,
	secondary-dark: inerissemigreen.darken(20%),
	secondary-darker: inerissemigreen.darken(40%),
	secondary-darkest: inerissemigreen.darken(60%),
	secondary-light: inerissemigreen.lighten(20%),
	secondary-lighter: inerissemigreen.lighten(40%),
	secondary-lightest: inerissemigreen.lighten(60%),
	tertiary: inerissemipurple,
	tertiary-dark: inerissemipurple.darken(20%),
	tertiary-darker: inerissemipurple.darken(40%),
	tertiary-darkest: inerissemipurple.darken(60%),
	tertiary-light: inerissemipurple.lighten(20%),
	tertiary-lighter: inerissemipurple.lighten(40%),
	tertiary-lightest: inerissemipurple.lighten(60%),
	neutral: rgb("#888888"),
	neutral-dark: rgb("#666666"),
	neutral-darker: rgb("#333333"),
	neutral-darkest: rgb("#000000"),
	neutral-light: rgb("#aaaaaa"),
	neutral-lighter: rgb("#cccccc"),
	neutral-lightest: rgb("#ffffff"),
)

//Tables
#let styled-table(..args) = {
	show table.cell.where(y:0): set text(fill:white, weight:"bold")
	align(center, table(
		..args.named(),
		inset: 0.5em,
		fill: (_,y) => if (y==0) {theme-colors.primary-darker} else if calc.odd(y) {theme-colors.primary-lightest} else {none},
		stroke: (_,y) => if (y==0) {(right: 0.1pt + theme-colors.primary-darker)} else if calc.odd(y) {(right: 0.1pt + theme-colors.primary-lightest)} else {none},
		align: horizon,
		rows: auto,
		table.hline(stroke: theme-colors.primary + 0.5pt),
		..args.pos(),
		table.hline(stroke: theme-colors.primary + 0.5pt),
	))
}

// Blocks
#let focus-block(mytitle,..args)={
	showybox.showybox(
		frame:(
			border-color: theme-colors.primary-darker,
			title-color: white,
			body-color: theme-colors.primary-lightest,
			width: 0.75pt,
		),
		title-style:(
			weight: "bold",
			boxed-style: (:),
			color: theme-colors.primary-darker,
		),
		body-style: (color: rgb("#666666")),
		sep: (dash: none),
		shadow: (offset: 3pt),
		breakable: true,
		title: mytitle,
		..args
	)
}

// Shadowed blocks
#let shadow-block(..args) = {
	layout(size => [
		#shadowed(block(width: size.width - 25pt, height: size.height - 25pt, ..args))
	])
}

// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#checkerboard[...][...]` stacks horizontally and `#checkerboard(columns: 1)[...][...]` stacks vertically.
#let checkerboard(columns: none, rows: none, colors: ((none, none), (none, none), (none, none)), ..bodies) = {
	let bodies = bodies.pos()
	let columns = if type(columns) == int {
		(1fr,) * columns
	} else if columns == none {
		(1fr,) * bodies.len()
	} else {
		columns
	}
	let num-cols = columns.len()
	let rows = if type(rows) == int {
		(1fr,) * rows
	} else if rows == none {
		let quotient = calc.quo(bodies.len(), num-cols)
		let correction = if calc.rem(bodies.len(), num-cols) == 0 {
			0
		} else {
			1
		}
		(1fr,) * (quotient + correction)
	} else {
		rows
	}
	let num-rows = rows.len()
	if num-rows * num-cols < bodies.len() {
		panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(
			bodies.len(),
		) + ")")
	}
	let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
	let color-body(idx-body) = {
		let (idx, body) = idx-body
		let (row, col) = cart-idx(idx)
		let (color, fcolor, scolor) = if calc.even(row + col) {
			(colors.at(0).at(0),colors.at(1).at(0), colors.at(2).at(0))
		} else {
			(colors.at(0).at(1),colors.at(1).at(1), colors.at(2).at(1))
		}
		rect(inset: .5em, width: 100%, height: 100%, stroke: none, fill: color, { 
			show strong: it => text(fill: scolor, weight: "bold", it)
			if fcolor != none {
				set text(fill: fcolor)
				body
			} else {
				body
			}}
		)
	}
	let body = grid(
		columns: columns, rows: rows,
		gutter: 0pt,
		..bodies.enumerate().map(color-body)
	)
	body
}

#let display-date(date) = {
	let week-days = ("dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi")
	let month-names = ("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre")
	[#utils.capitalize(week-days.at(calc.rem(date.weekday(), 7))) #(date.day()) #(month-names.at(date.month()-1)) #(date.year())]
}

#let slide-header(self) = {
	set align(top)
	pad(bottom: 1em,block(width: 100%, height: 100%, inset: 4pt, {
		box(height: 60%, baseline:50%, image("logo_marianne.png", height: 100%))
		h(10pt)
		box(height: 50%, baseline:50%, image("logo_ineris_e.png", height: 100%))
		v(0.2em)
		h(2em - 4pt)
		set text(size: 1.4em, weight: "black")
		if self.store.title != none {
			utils.call-or-display(self, self.store.title)
		} else {
			utils.display-current-heading(level: 2, numbered: false)
		}
	}))
}

#let slide-footer(self) = {
	set align(bottom)
	set text(size: .5em, weight: "bold")
	pad(bottom: 0.8em, x: 1cm, {
		[Institut national de l'environnement industriel et des risques]
		h(1fr)
		context utils.slide-counter.display() + " / " + utils.last-slide-number
	})
	place(bottom, dy: -2em, dx:1cm, line(length: 100% - 2cm))
	if self.store.footer-progress {
		place(bottom, components.progress-bar(height: 5pt, self.colors.primary-darker, self.colors.primary-lighter))
    }
}

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
	if title != auto {
		self.store.title = title
	}
	self = utils.merge-dicts(
		self,
		config-page(
			header: slide-header,
			footer: slide-footer,
		),
	)
	show strong: self.methods.alert.with(self: self)
	touying-slide(self: self, ..args)
})

#let title-slide(..args) = touying-slide-wrapper(self => {
	self = utils.merge-dicts(self,
		config-page(
			margin: (x: 0mm, y: 0mm),
			footer: slide-footer,
		),
	)
	let info = self.info + args.named()
	let body = {
		set align(top)
		v(-5cm)
		h(0.4cm)
		box(baseline: 50%, image("logo_marianne.png", width: 22%))
		h(1fr)
		box(baseline: 50%, image("logo_ineris_e.svg", width: 28%))
		h(0.4cm)
		v(0.6fr)
		block(inset: (x: 1cm), {
			text(size: 2em, weight: "black", info.title)
			if info.subtitle != none {
				v(-1cm)
				text(size: 1.5em, info.subtitle)
			}
		})
		v(1fr)
		block(width: 100%, inset: (x:1cm, bottom: 0.5em), {
			if info.author != none {
				text(size: 0.5em, display-date(info.date))
			}
			if info.date != none {
				h(1fr)
				text(size: 0.5em, info.author)
			}
		})
	}
	show strong: self.methods.alert.with(self: self)
	touying-slide(self: self, body)
})

#let new-section-slide(self: none, section) = touying-slide-wrapper(self => {
	self = utils.merge-dicts(
		self,
		config-page(
			margin: (left: 0em, right: 0mm, bottom: 1em),
			header: slide-header,
			footer: slide-footer,
		),
	)
	let body = {
		place(rect(fill: rgb("#aaaaaa"), width: 100%, height: 1fr))
		set align(left + horizon)
		set text(size: 1.5em, fill: white, weight: "black")
		h(1em)
		utils.display-current-heading(level: 1, numbered: true)
	}
	show strong: self.methods.alert.with(self: self)
	touying-slide(self: self, body)
})

#let focus-slide(body) = touying-slide-wrapper(self => {
	self = utils.merge-dicts(self,
		config-common(freeze-slide-counter: true),
		config-page(fill: self.colors.primary-dark, margin: 2em),
	)
	set text(fill: self.colors.neutral-lightest, size: 2em, weight: "black")
	show strong: it => text(fill: self.colors.neutral-lightest, style: "italic", it)
	touying-slide(self: self, align(horizon + center, body))
})

#let matrix-slide(title: auto, reversed: false, columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
	if title != auto {
		self.store.title = title
	}
	let cols = if (reversed) {
		((self.colors.primary-darker, none), (self.colors.neutral-lightest, none), (self.colors.neutral-lightest, self.colors.primary-darker))
	} else {
		((none, self.colors.primary-darker), (none, self.colors.neutral-lightest), (self.colors.primary-darker, self.colors.neutral-lightest))
	}
	self = utils.merge-dicts(self,
		config-page(
			margin: (x: 0em, bottom: 5pt),
			header: slide-header,
			footer: slide-footer,
		),
	)
	touying-slide(self:self, composer: checkerboard.with(colors: cols, columns: columns, rows: rows), ..bodies)
})

#let outline-slide(title: "Sommaire", ..args) = touying-slide-wrapper(self => {
	self.store.title = title
	self = utils.merge-dicts(
		self,
		config-page(
			header: slide-header,
			footer: slide-footer,
		),
	)
	show outline.entry.where(level: 1): it => {
		it.prefix() + " " + it.body()
		linebreak()
	}
	touying-slide(
		self: self,
		components.adaptive-columns(
			start: text(
				1.2em,
				fill: self.colors.primary-darker,
				weight: "bold",
				utils.call-or-display(self, title),
			  ),
			text(
				fill: self.colors.neutral-darkest,
				outline(title: none, indent: 1em, depth: self.slide-level - 1, ..args),
			),
		),
	)
})

#let ineris-slideshow(
	aspect-ratio: "16-9",
	footer-progress: true,
	..args,
	body,
) = {
	// Slides
	show: touying-slides.with(
		config-page(
			paper: "presentation-" + aspect-ratio,
			margin: (top: 7em, bottom: 1.5em, x: 2em),
			header-ascent: 0mm,
		),
		config-common(
			slide-fn: slide,
			new-section-slide-fn: new-section-slide,
		),
		config-colors(..theme-colors),
		config-methods(
			init: (self: none, body) => {
				// Main styling
				set text(font: ("Marianne", "Linux Biolinum"), size: 20pt, weight: "light", lang: "fr", region: "FR")

				// Lists
				set list(
					indent: 1em,
					tight: false,
					marker: ([#set text(fill: self.colors.primary-darker);▶],[#set text(fill: self.colors.secondary-darker);--],[#sym.star.filled]),
				)
				show list: it => {
					show list: set text(size: 0.8em)
					show enum: set text(size: 0.8em)
					it
				}
				set enum(
					indent: 1em,
					tight: false,
					numbering: n=>text(fill: self.colors.primary-darker, [#n.]),
				)
				show enum: it => {
					show list: set text(size: 0.8em)
					show enum: set text(size: 0.8em)
					it
				}
				set heading(numbering: "1.a")
				show heading.where(level: 1): set heading(numbering: "1.")

				body			
			},
			alert: (self: none, it) => text(fill: self.colors.primary-darker, weight: "bold", it),
		),
		config-store(
			title: none,
			footer-progress: footer-progress,
		),
		..args,
	)

	body
}
