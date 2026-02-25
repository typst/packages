#import "@preview/touying:0.6.1": *

/// format affiliations number
#let format-affiliations-number(affiliations) = {
    text(
	tracking: 1pt
    )[
	#super[
	    #affiliations.map(
		affiliation => [#affiliation]
	    ).join(",")
	]
    ]
}

/// format a single author 
#let format-author(author, affiliation: true) = {
    if affiliation {
        [#author.name#format-affiliations-number(author.affiliations) \
	    #link("mailto:" + author.email)]
    }else{
        [#author.name \
	    #link("mailto:" + author.email)]
    }
}

/// format authors
#let format-authors(authors, affiliation: true) = {
    layout(size => [
	#let column-gutter = 10pt
	// We compute the maximum width of an authors to know
	// how many columns we should have
	// this is done thanks to `measure` function
	#let author-max-width = calc.max(..authors.map(author => measure(
	    block(format-author(author, affiliation: affiliation))
	).width))
			
	// Do the actual computation (do not take the `column-gutter` into account, otherwise it fails?)
	#let n-authors-per-row = calc.floor(size.width / (author-max-width))
	#let count = authors.len() // total number of authors
	#let modulus = calc.rem-euclid(count, n-authors-per-row) // how many authors in the last line
	#let ncols = calc.min(count, n-authors-per-row)


	#if modulus > 0 { // if we have a remainder
	    // we display the first rows with `ncols`
	    grid(
		columns: (auto,) * ncols,
		column-gutter: column-gutter,
		row-gutter: 24pt,
		..authors.slice(0,-modulus).map(author => format-author(author, affiliation: affiliation)),
	    )
	    // we display the last row
	    grid(
		columns: (auto,) * modulus,
		column-gutter: column-gutter,
		row-gutter: 24pt,
		..authors.slice(-modulus).map(author => format-author(author, affiliation: affiliation)),
	    )
	}else{ // no remainder
	    // we display all authors directly, its a perfect fit!
	    grid(
		columns: (auto,) * ncols,
		column-gutter: column-gutter,
		row-gutter: 24pt,
		..authors.map(author => format-author(author, affiliation: affiliation)),
	    )
	}
    ])
}



#let toc-progress-get-headings(depth: 1) = {
    let result = ()
    for h in query(heading).filter(h => h.outlined == true){
	if(h.depth == 1){
	    result.push(
		(
		    heading: h,
		    children: ()
		)
	    )
	}else{
	    result.last().at("children").push(h)
	}
    }
    return result
}
#let toc-progress() = {
    //return toc-progress-get-headings()
    let current-page = here().page()
    let headings = toc-progress-get-headings()
    stack(
	dir: ltr,
	spacing: 1fr,
	..headings.map(h => {
	    stack(
		dir: ttb,
		stack(
		    dir: ltr,
		    ..h.children.map(c =>{
			if c.location().page() == current-page {
			    sym.square.filled
			}else{
			    sym.square.stroked
			}
		    })
		),
		h.heading.body,
	    )
	})
    )
    //return headings

}
// propose a wrapper for the outline
#let uge-outline(..args) = {
    components.adaptive-columns(outline(..args))
}

#let alert(body, fill: blue) = {
    set text(white, weight: "bold")
    box(
        fill: fill,
        inset: (x: 8pt, y:0pt),
        outset: (y: 8pt),
        radius: 4pt,
        body
    )
}

#let result-box(body) = [
    #box(
        inset: 8pt,
        outset: 8pt,
        width: 100%,
        stroke: 3pt + gradient.linear(
            rgb("#0097d7"),
            rgb("#8b4a97"),
            rgb("#d2213c"),
        )
    )[
        #set align(center)
        #body
    ]
]
// This theme is inspired by https://github.com/matze/mtheme
// The origin code was written by https://github.com/Enivex
#let _typst-builtin-align = align

/// Default slide function for the presentation.
///
/// - `title` is the title of the slide. Default is `auto`.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
    title: auto,
    align: auto,
    config: (:),
    repeat: auto,
    setting: body => body,
    composer: auto,
    ..bodies,
) = touying-slide-wrapper(self => {
    if align != auto {
	self.store.align = align
    }
    // restore typst builtin align function
    let align = _typst-builtin-align
    let header(self) = {
	set align(top)
	show: components.cell.with(fill: self.colors.primary, inset: 1em)
	set align(horizon)
	set text(fill: self.colors.neutral-lightest, weight: "medium", size: 1.2em)
	components.left-and-right(
	    {
		if title != auto {		    
		    utils.fit-to-width.with(grow: false, 100%, title)
		} else {
		    utils.call-or-display(self, self.store.header)
		}
	    },
	    utils.call-or-display(self, self.store.header-right),
	)
	if self.store.toc-progress {
	    set text(size: 10pt)
	    context toc-progress()
	}
	
    }
    let footer(self) = {
	set align(bottom)
	set text(size: 0.8em)
	pad(
	    .5em,
	    components.left-and-right(
		text(fill: self.colors.neutral-darkest.lighten(40%), utils.call-or-display(self, self.store.footer)),
		text(fill: self.colors.neutral-darkest, utils.call-or-display(self, self.store.footer-right)),
	    ),
	)
	if self.store.footer-progress {
	    place(bottom, components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light))
	}
    }
    let self = utils.merge-dicts(
	self,
	config-page(
	    fill: self.colors.neutral-lightest,
	    header: header,
	    footer: footer,
	),
    )
    let new-setting = body => {
	show: align.with(self.store.align)
	set text(fill: self.colors.neutral-darkest)
	show: setting
	body
    }
    touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - `extra` is the extra information you want to display on the title slide.
#let title-slide(
    extra: none,
    ..args,
) = touying-slide-wrapper(self => {
    let info = self.info + args.named()
    let body = {
	set page(
	    background: grid(
		columns: (80%, auto),
		rows: (auto),
		gutter: 0pt,
		block(
		    width: 100%, 
		    height: 100%, 
		    fill: self.colors.primary
		),
		image(
		    "assets/pattern-titlepage.svg",
		    width: 100%,
		    height: 100%,
		    fit: "cover"
		)
	    )
	)
	set text(
	    fill: self.colors.neutral-lightest,
	    
	)
	set align(horizon)
	block(
	    fill: self.colors.primary,
	    width: 80%,
	    inset: 1.5em,
	    {

		align(center, text(size: 1.3em, weight: "bold", info.title))
		if info.subtitle != none {
		    align(center, text(size: 0.9em, info.subtitle))
		}

		line(length: 100%, stroke: .1em + self.colors.primary-light)

		set align(center)
		set text(size: .8em)

		if info.authors != none {
		    format-authors(info.authors)
		    v(1em)
		    align(left, 
			text(
			    size: .8em,
			    info.institutions.enumerate().map(((index, institute)) => [
				#super[#(index+1)] #institute\
			    ]).join()
			)
		    )
		}
		set text(size: .8em)
		if info.institution != none {
		    block(spacing: 1em, info.institution)
		}
		if extra != none {
		    block(spacing: 1em, extra)
		}
		v(1fr)
		components.left-and-right(
		    if info.date != none {
			block(spacing: 2em, text(
			    size: .8em, 
			    style: "italic", 
			    [
                                #utils.display-info-date(self)
                                #if "location" in info.keys() {
                                    [-- #text(self.info.location)]
                                }
                            ]
			))
		    },
		    text(2em, utils.call-or-display(self, info.logo))
		)

	    },
	)
    }
    self = utils.merge-dicts(
	self,
	config-common(freeze-slide-counter: true),
	config-page(fill: self.colors.neutral-lightest),
    )
    touying-slide(self: self, body)
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `level` is the level of the heading.
///
/// - `numbered` is whether the heading is numbered.
///
/// - `title` is the title of the section. It will be pass by touying automatically.
#let new-section-slide(level: 1, numbered: true, title) = touying-slide-wrapper(self => {
    let body = {
	set align(horizon)
	show: pad.with(20%)
	set text(size: 1.5em, weight: "bold", fill: self.colors.primary)
	stack(
	    dir: ttb,
	    spacing: 1em,
	    utils.display-current-heading(level: level, numbered: numbered),
	    block(
		height: 2pt,
		width: 100%,
		spacing: 0pt,
		components.progress-bar(height: 2pt, self.colors.primary-light, self.colors.neutral-dark),
	    ),
	)
    }

    let section-pattern-width = 100pt
    let place-pattern(position: top+left, angle: 0deg) = {
	place(position,
	    rotate(
		angle,
		image(
		    "assets/pattern-section.svg",
		    width: section-pattern-width,
		    height: section-pattern-width,
		)
	    )
	);
    }
    self = utils.merge-dicts(
	self,
	config-page(
	    background: if self.info.variant [
		// Nice rendering too!
		#image(
		    "assets/pattern-section.svg",
		    width: 100%,
		    height: 110%,
		),
	    ]else{
		place-pattern(position: top+left, angle: 0deg);
		place-pattern(position: top+right, angle: 90deg);
		place-pattern(position: bottom+left, angle: 270deg);
		place-pattern(position: bottom+right, angle: 180deg);
	    },
	    fill: self.colors.neutral-lightest
	),
    )
    touying-slide(self: self, body)
})

#let thanks-slide(body) = touying-slide-wrapper(self => {
    let _body = {
        set align(left)
        stack(
            dir: ttb,
            spacing: .5em,
            text(size: 1.5em, weight: "bold", fill: self.colors.primary, self.info.title),
            text(size: .6em, weight: "bold", fill: self.colors.primary, self.info.subtitle),
            if "location" in self.info.keys() {
                text(size: .5em, fill: self.colors.primary, self.info.location)
            },
            align(right, [
                #text(size: .5em, fill: self.colors.primary, utils.display-info-date(self))
                #h(8.3cm)
            ]),

        )
        v(3cm)
        align(center)[
            #text(size: 1.5em, weight: "bold", fill: self.colors.primary, body)
        ]

	set align(bottom + right)
	set text(size: .6em, fill: self.colors.primary)
        box(
            width: 14cm,
            {
                format-authors(self.info.authors, affiliation: false)   
            }
        )
    }

    let section-pattern-width = 100pt
    let place-pattern(position: top+left, angle: 0deg) = {
	place(position,
	    rotate(
		angle,
		image(
		    "assets/pattern-section.svg",
		    width: section-pattern-width,
		    height: section-pattern-width,
		)
	    )
	);
    }
    self = utils.merge-dicts(
	self,
	config-page(
	    background: if self.info.variant [
		// Nice rendering too!
		#image(
		    "assets/pattern-section.svg",
		    width: 100%,
		    height: 110%,
		),
	    ]else{
		place-pattern(position: top+left, angle: 0deg);
		place-pattern(position: top+right, angle: 90deg);
		place-pattern(position: bottom+left, angle: 270deg);
		place-pattern(position: bottom+right, angle: 180deg);
	    },
	    fill: self.colors.neutral-lightest
	),
    )
    touying-slide(self: self, _body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - `align` is the alignment of the content. Default is `horizon + center`.
#let focus-slide(align: horizon + center, body) = touying-slide-wrapper(self => {
    let _align = align
    let align = _typst-builtin-align
    self = utils.merge-dicts(
	self,
	config-common(freeze-slide-counter: true),
	config-page(fill: self.colors.primary-light, margin: 2em),
    )
    set text(fill: self.colors.neutral-lightest, size: 1.5em)
    touying-slide(self: self, align(_align, body))
})

#let uge-box(
    color: none, 
    title: none, 
    icon: none,
    ..args,
    body,
) = {
    box(
	fill: color,
	width: 100%,
	inset: 1em,
	radius: 5pt,
	{
	    set text(size: 1em, fill: black)
	    stack(
		dir: ttb,
		spacing: 15pt,
		[#icon #h(5pt) | #h(10pt) #title],
		line(length: 100%, stroke: 1pt + rgb(0,0,0,100)),
		body,
	    )
	}
    )
}

#let info-box(
    title: "Info",
    icon: emoji.info,
    body
) = uge-box(
    color: rgb("#00A5CC").lighten(80%),
    title: title,
    icon: icon,
    body
)

#let warning-box(
    title: "Warning",
    icon: emoji.warning,
    body
) = uge-box(
    color: rgb("#F4A44D").lighten(50%),
    title: title,
    icon: icon,
    body
)

#let danger-box(
    title: "Danger",
    icon: emoji.prohibited,
    body
) = uge-box(
    color: rgb("#D95E61").lighten(30%),
    title: title,
    icon: icon,
    body
)

/// Touying UGE theme
///
/// Example:
///
/// ```typst
/// #show: uge-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `align` is the alignment of the content. Default is `horizon`.
///
/// - `header` is the header of the slide. Default is `self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level)`.
///
/// - `header-right` is the right part of the header. Default is `self => self.info.logo`.
///
/// - `footer` is the footer of the slide. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `footer-progress` is whether to show the progress bar in the footer. Default is `true`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#eb811b"),
///   primary-light: rgb("#d6c6b7"),
///   secondary: rgb("#23373b"),
///   neutral-lightest: rgb("#fafafa"),
///   neutral-dark: rgb("#23373b"),
///   neutral-darkest: rgb("#23373b"),
/// )
/// ```

#let uge-theme(
    aspect-ratio: "16-9",
    align: horizon,
    header: self => utils.display-current-heading(setting: utils.fit-to-width.with(grow: false, 100%), depth: self.slide-level),
    header-right: self => self.info.logo,
    footer: none,
    footer-right: self => {
	if not self.at("appendix"){
	    context utils.slide-counter.display() + " / " + utils.last-slide-number
	}
    },
    footer-progress: true,
    toc-progress: false,
    ..args,
    body,
) = {
    set text(size: 20pt)

    show: touying-slides.with(
	config-page(
	    paper: "presentation-" + aspect-ratio,
	    header-ascent: 30%,
	    footer-descent: 30%,
	    margin: (top: 3em, bottom: 1.5em, x: 2em, right: 3em),
	),
	config-common(
	    slide-fn: slide,
	    new-section-slide-fn: new-section-slide,
	),
	config-methods(
	    alert: utils.alert-with-primary-color,
	),
	config-colors(
	    primary: rgb("#2f2a85"),
	    primary-light: rgb("#0097d7"),
	    secondary: rgb("#0f273b"),
	    neutral-lightest: rgb("#fafafa"),
	    neutral-dark: rgb("#353d5f"),
	    neutral-darkest: rgb("#353d5f"),
	    blue: rgb("#2f2a85"),
	    pink: rgb("#e83583"),
	    purple: rgb("#8b4a97"),
	    green: rgb("#00936e"),
	    positive: rgb("#92c56e"),
	    negative: rgb("#d2213c"),
	    orange: rgb("#ef7d00"),
	    warning: rgb("#fbba00"),
	    cyan: rgb("#1eafd0"),
	),
	// save the variables for later use
	config-store(
	    align: align,
	    header: header,
	    header-right: header-right,
	    footer: footer,
	    footer-right: footer-right,
	    footer-progress: footer-progress,
	    toc-progress: toc-progress
	),
	config-info(
	    title: [Title],
	    subtitle: [],
	    authors: (),
	    date: datetime.today(),
	    institutions: (),
	    logo: emoji.city,
	    variant: false,
	),
	..args,
    )

    body
}

// Local Variables:
// tp--master-file: "/home/toullier/Documents/Misc/git/touying-uge/main.typ"
// End:
