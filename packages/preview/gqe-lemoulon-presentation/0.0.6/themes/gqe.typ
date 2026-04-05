// This theme contains ideas from the former "bristol" theme, contributed by
// https://github.com/MarkBlyth

#import "@preview/touying:0.6.1": *

#let gqe-color= rgb("#006600")



/// Alert content with a primary color.
///
/// Example: `config-methods(alert: utils.alert-with-primary-color)`
///
/// -> content

#let alert-with-alert-color(self: none, body) = text(fill: self.colors.alert, body)

/// Default slide function for the presentation.
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
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set align(top)
    grid(
      rows: (auto, auto),
      row-gutter: 3mm,
      if self.store.progress-bar {
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.tertiary)
      },
      block(
        inset: (x: .5em),
        components.left-and-right(
          text(fill: self.colors.primary, weight: "bold", size: 1em, utils.call-or-display(self, self.store.header)),
          text(fill: self.colors.primary.lighten(65%), utils.call-or-display(self, self.store.header-right)),
        ),
      ),
    )
  }
  
  
  let footer(self) = {
    v(10pt)
    set align(center + horizon)
    set text(size: .4em)
    {
      let cell(..args, it) = components.cell(
        ..args,
        inset: 1mm,
        align(horizon, text(fill: black, it)),
      )
      show: block.with(width: 90%, height: 30pt, stroke: ( top: 0.9pt + rgb(self.colors.primary) ))
      grid(
        columns: self.store.footer-columns,
        rows: 1.5em,
        cell( utils.call-or-display(self, self.store.footer-a)),
        cell(utils.call-or-display(self, self.store.footer-b)),
        cell(utils.call-or-display(self, self.store.footer-c)),
      )
    }
  }
  
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
      margin: (top: 2em, bottom: 40pt),
    ),
  )
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})



/// Title slide for the presentation. You should update the information in the @gqe-config-info function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: gqe-lemoulon-presentation-theme.with(
///  gqe-config-info(
///   title: none,
///   short-title: auto,
///   subtitle: none,
///   short-subtitle: auto,
///   author: none,
///   date: "HCERES – GQE-Le Moulon, 14-15/11/2024",
///   institution: none,
///   logo: image("../assets/logo_gqe.svg"),
///   logo2: image("../assets/logo_ideev_couleur.svg"),
///   equipe: none,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - `extra` is the extra information of the slide. You can pass the extra information to the `title-slide` function.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  
  let header(self) = {
    set align(center + bottom)
    grid(columns: (5%, 1fr, 1fr, 5%),
      [],{
        set align(bottom + left)
        set image(height: 60pt)
        self.info.logo
        },{
        set align(bottom + right)
        set image(height: 60pt)
        self.info.logo2
      } ,
      []
    )
  }
    
  
  let footer(self) = align(bottom, {
    set align(center)
    set text(size: 0.5em, fill:self.colors.neutral-darkest)
    

	    block(
	      height: 50pt,
	      stroke: ( top: 0.9pt + rgb(self.colors.primary) ), width: 90%, inset: ( y: 0.8em ),
	      grid(columns: (60%,40%),{
	      
	      self.info.brochette
	      
	      }, {
	      	set align(horizon + center)
	      	info.date
	      	}  )
	    )
    
  })
  let body = {
    align(
      center + horizon,
      {
        block(
          inset: 0em,
          breakable: false,
          {
            text(size: 1.3em, fill: self.colors.neutral-darkest, strong(info.title))
            if info.subtitle != none {
              parbreak()
              text(size: 0.9em, fill: self.colors.neutral-darkest, info.subtitle)
            }
          },
        )
        set text(size: .8em)
        grid(
          columns: (1fr,) * calc.min(info.authors.len(), 3),
          column-gutter: 1em,
          row-gutter: 1em,
          ..info.authors.map(author => text(fill: self.colors.neutral-darkest, author))
        )
        v(1em)
        if info.institution != none {
          parbreak()
          text(size: .9em, info.institution)
        }
      },
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest),
    config-page(
      header: header,
      footer: footer,
      margin: (top: 90pt,bottom: 60pt, y: 2.8em),
    ),
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
/// - `body` is the body of the section. It will be pass by touying automatically.
#let new-section-slide(level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set align(horizon)
    show: pad.with(20%)
    set text(size: 1.5em, fill: self.colors.primary, weight: "bold")
    stack(
      dir: ttb,
      spacing: .65em,
      utils.display-current-heading(level: level, numbered: numbered),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.primary-light),
      ),
    )
    body
  }
  self = utils.merge-dicts(
    self,
    config-page(fill: self.colors.neutral-lightest),
  )
  touying-slide(self: self, slide-body)
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
#let focus-slide(
    /// background color of the slide. Default is the primary color. *Optional*.
    /// -> color
    background-color: none,
    /// background image of the slide. *Optional*.
    /// -> image
    background-img: none,
    body
  ) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, align(horizon, body))
})


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
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.


#let matrix-slide(columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(self: self, composer: components.checkerboard.with(columns: columns, rows: rows), ..bodies)
})


#let gqe-brochette = grid(columns: (30%, 25%,20%,20%),{
		set align(horizon + center)
		set image(height: 25pt)
		image("../assets/logo_faculte_sciences.png")
		},{
		set align(horizon + center)
		set image(height: 20pt)
		image("../assets/Logo-INRAE.svg")
		},{
		set align(horizon + center)
		set image(height: 30pt)
		image("../assets/CNRS_BIOLOGIE_DIGI_V_RVB.svg")
		},{
		set align(horizon + center)
		set image(height: 20pt)
		image("../assets/Logo_AgroParisTech.svg")
	      })

/// Sets essential presentation informations (title, author, date ..).
///
/// Example: `gqe-config-info(title: "UMR Génétique Quantitative et Evolution - Le Moulon" )`
///
/// -> content
#let gqe-config-info(
  /// The title of your presentation. *Optional*.
  /// -> content
  title: none,
  short-title: auto,
  /// The subtitle of your presentation. *Optional*.
  /// -> content
  subtitle: none,
  short-subtitle: auto,

  /// The author(s) of your presentation. *Optional*.
  /// -> content
  author: none,

  /// The date of your presentation. *Optional*.
  /// -> content
  date: none,

  /// Your institution. *Optional*.
  /// -> content
  institution: none,

  /// Name of your team to display. *Optional*.
  /// -> content
  equipe: none,

  /// Logo to display. *Required*.
  /// -> content
  logo: image("../assets/logo_gqe.svg"),

  /// Second logo to display. *Required*.
  /// -> content
  logo2: image("../assets/logo_ideev_couleur.svg"),

  /// A "brochette" of logos of images. *Required*.
  /// -> content
  brochette: gqe-brochette,
  ..args,
) = {
  assert(args.pos().len() == 0, message: "Unexpected positional arguments.")
  return (
    info: (
      title: title,
      short-title: short-title,
      subtitle: subtitle,
      short-subtitle: short-subtitle,
      author: author,
      date: date,
      institution: institution,
      logo: logo,
      logo2: logo2,
      equipe: equipe,
      brochette: brochette,
    ) + args.named(),
  )
}

/// GQE - Le Moulon presentation theme.
///
/// Example:
///
/// ```typst
/// #show: gqe-lemoulon-presentation-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
///
/// config-colors(
///   primary: gqe-color,
///   secondary: gqe-color.lighten(75%),
///   tertiary: gqe-color.lighten(90%),
///   alert: rgb("#990000"),
///  )
/// ```
#let gqe-lemoulon-presentation-theme(

  /// The font to use in slides. *Optional*.
  /// -> str
  gqe-font: "PT Sans",

  /// Aspect ratio of the slides, either "16-9" or "4-3". Default is `4-3`. *Optional*.
  /// -> str
  aspect-ratio: "4-3",
  /// Display a progress bar. Default is false. *Optional*.
  /// -> bool
  progress-bar: false,

  /// is the header of the slides. Default is `utils.display-current-heading(level: 2)`. *Optional*.
  header: utils.display-current-heading(level: 2),
  /// is the right part of the header. Default is `self.info.logo`. *Optional*.
  header-right: self => utils.display-current-heading(level: 1) + h(.3em) ,
  /// is the columns of the footer. Default is `(10%, 1fr, 10%)`. *Optional*.
  footer-columns: (10%, 1fr, 10%),
  /// is the left part of the footer. Default is `self.info.logo`. *Optional*.
  footer-a: self => {
    set image(height: 20pt)
    self.info.logo
  },
  /// is the middle part of the footer. Default is `self.info.equipe` and `self.info.date`. *Optional*.
  footer-b: self => {
    set align(left)
    if (self.info.equipe != none) {self.info.equipe}
    h(1em)
    self.info.date
  },
  /// is the right part of the footer. Default is slide number on total slides. *Optional*.
  footer-c: self => {
    h(1fr)
    context utils.slide-counter.display() + " / " + utils.last-slide-number
    h(1fr)
  },
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 50pt, x: 1.5em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      show-strong-with-alert: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: gqe-font, fill: self.colors.neutral-darkest, size: 28pt)
        show heading: set text(fill: self.colors.neutral-darkest)
        show footnote.entry: set text(size: .8em)
  
        body
      },
      alert: alert-with-alert-color,
    ),
    
    config-colors(
      primary: gqe-color,
      secondary: gqe-color.lighten(75%),
      tertiary: gqe-color.lighten(90%),
      alert: rgb("#990000"),
    ),
    gqe-config-info(),
    // save the variables for later use
    config-store(
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )

  body
}


